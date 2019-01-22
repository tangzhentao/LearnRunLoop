//
//  ThreadViewController.m
//  LearnRunLoop
//
//  Created by tang on 2019/1/20.
//  Copyright © 2019 genghaowan. All rights reserved.
//

#import "ThreadViewController.h"
#import "MyThread.h"
#import <pthread.h>
#import "ViewController.h"

@interface ThreadViewController ()

@property (strong, nonatomic) MyThread *subthread;
@property (weak, nonatomic) MyThread *weakThread;

@end

@implementation ThreadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"thread && run loop";
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (MyThread *)subthread
{
    if (!_subthread) {
        _subthread = [[MyThread alloc] initWithTarget:self selector:@selector(countdown) object:nil];
    }
    
    return _subthread;
}
- (IBAction)printProcessInfo:(id)sender
{
    NSProcessInfo * processInfo = [NSProcessInfo processInfo];
    NSLog(@"processInfo:");
    NSLog(@"environment: %@", processInfo.environment);
    NSLog(@"arguments: %@", processInfo.arguments);
    NSLog(@"hostName: %@", processInfo.hostName);
    NSLog(@"processName: %@", processInfo.processName);
    NSLog(@"globallyUniqueString: %@", processInfo.globallyUniqueString);
    NSLog(@"processIdentifier: %d", processInfo.processIdentifier);
    int pid = getpid();
    NSLog(@"getpid: %d", pid);
    
    NSOperatingSystemVersion OSVersion = processInfo.operatingSystemVersion;
    NSLog(@"operatingSystemVersion: %ld.%ld.%ld", OSVersion.majorVersion, OSVersion.minorVersion, OSVersion.patchVersion);
    NSLog(@"operatingSystemVersionString: %@", processInfo.operatingSystemVersionString);
    NSLog(@"processorCount: %ld", processInfo.processorCount);
    NSLog(@"physicalMemory: %lld", processInfo.physicalMemory);
}

- (IBAction)startThread:(id)sender
{
    
    MyThread *thread = [[MyThread alloc] initWithTarget:self selector:@selector(countdown) object:nil];
    thread.name = @"subthread";
    
    NSLog(@"%@: will start subthread<%@> ...", [NSThread currentThread], thread.name);
    
    [thread start];
}

- (IBAction)keepAndStartThread:(id)sender
{
    self.subthread.name = @"keeped subthread";
    
    NSLog(@"%@: will start subthread<%@> ...", [NSThread currentThread], self.subthread.name);

    [self.subthread start];
}

- (IBAction)startThreadWithInfiniteLoop:(id)sender
{
    MyThread *thread = [[MyThread alloc] initWithTarget:self selector:@selector(infiniteLoop) object:nil];
    thread.name = @"infinite loop subthread";
    
    NSLog(@"%@: will start subthread<%@> ...", [NSThread currentThread], thread.name);
    
    [thread start];
}

- (IBAction)startThreadWithRunLoop:(id)sender
{
    MyThread *thread = [[MyThread alloc] initWithTarget:self selector:@selector(runWithRunLoop) object:nil];
    thread.name = @"run loop thread";
    NSLog(@"%@: will start subthread<%@> ...", [NSThread currentThread], thread.name);
    
    [thread start];
    
    // 获取线程id
    pthread_t pthread = pthread_self();
    __uint64_t pid;
    int result = pthread_threadid_np(pthread, &pid);
    if (0 == result) {
        NSLog(@"pid: %llu", pid);
    } else {
        NSLog(@"error: %d", result);
    }
    
}
- (IBAction)startThreadReceivingMsg:(id)sender
{
    MyThread *thread = [[MyThread alloc] initWithTarget:self selector:@selector(waitMessage) object:nil];
    self.weakThread = thread;
    thread.name = @"msg thread";
    
    NSLog(@"%@: will start subthread<%@> ...", [NSThread currentThread], thread.name);

    [thread start];
}

- (IBAction)startThreadWithDelayMsg:(id)sender
{
    MyThread *thread = [[MyThread alloc] initWithTarget:self selector:@selector(enableRunLoop) object:nil];
    thread.name = @"thread with delay";
    
    NSLog(@"%@: will start subthread<%@> ...", [NSThread currentThread], thread.name);

    [thread start];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (_subthread) {
        NSLog(@"thread<%@>:\n is executing ? %@\n is finished ? %@", _subthread.name, _subthread.isExecuting ? @"Yes" : @"No", _subthread.isFinished ? @"Yes" : @"No");
    }
    
    if (self.weakThread) {
        [self performSelector:@selector(printCurrentThread) onThread:self.weakThread withObject:nil waitUntilDone:NO];
    }
}

- (void)countdown
{
    for (int i = 10; i >= 0; i--)
    {
        NSLog(@"<%@>: %d", [NSThread currentThread].name, i);
        [NSThread sleepForTimeInterval:0.2];
    }
}

- (void)infiniteLoop
{
    int i = 0;
    do
    {
        NSLog(@"<%@>: %d", [NSThread currentThread].name, i++);
        [NSThread sleepForTimeInterval:1];
    } while (1);
}

- (void)runWithRunLoop
{
    NSLog(@"<%@>: task begin ...", [NSThread currentThread].name);

    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    NSPort *machPort = [NSMachPort port];
    NSLog(@"machPort address: %@", machPort);
    [runLoop addPort:machPort forMode:NSDefaultRunLoopMode];
    
    NSLog(@"runLoop: %@", runLoop);
    
    [runLoop run];
    
    NSLog(@"<%@>: task end.", [NSThread currentThread].name);
}


- (void)waitMessage
{
    NSLog(@"<%@>: task begin ...", [NSThread currentThread].name);
    
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    
    [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
    
    /*
     runLoop在收到一条消息后就会结束运行循环，此后线程也会推出。
     */
    [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    
    NSLog(@"<%@>: task end.", [NSThread currentThread].name);
}

- (void)printCurrentThread
{
    NSLog(@"current thread: %@", [NSThread currentThread]);
}

- (void)enableRunLoop
{
    NSLog(@"<%@>: task begin ...", [NSThread currentThread].name);
    
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    
    /*
     不需要使用以下方法添加输入源也能运行起来run loop：
     [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
     因为会想run loop中加入一个Timer，输入源或Timer二者有其一就能运行期run loop
     */
    
    NSTimeInterval interval = 2;
    NSLog(@"perform funtion greet, delay %f s", interval);
    [self performSelector:@selector(greet) withObject:nil afterDelay:interval];

    
    /*
     因为run loop中只有一个Timer，输入源，因此在Timer任务完成后，run loop就退出循环了。此后线程也就退出了。
     */
    [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    
    NSLog(@"<%@>: task end.", [NSThread currentThread].name);
}

- (void)greet
{
    NSLog(@"%@: hello, everybody!", [NSThread currentThread].name);
}

@end
