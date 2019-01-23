//
//  ViewController.m
//  LearnRunLoop
//
//  Created by tang on 2019/1/20.
//  Copyright © 2019 genghaowan. All rights reserved.
//

#import "ViewController.h"
#import "MyThread.h"
#import <objc/runtime.h>

@interface Foo : NSObject

@property (strong, nonatomic) NSString * name;

- (void)print;
- (void)printThreadInfo;

@end

@implementation Foo

- (void)print
{
    NSLog(@"[%@ %@]", [self class], NSStringFromSelector(_cmd));
}

- (void)printThreadInfo
{
    NSThread *thread = [NSThread currentThread];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    
    NSLog(@"%@: %@", thread.name, runLoop.currentMode);
}

- (void)dealloc
{
    NSLog(@"[%@ %@]", [self class], NSStringFromSelector(_cmd));
}

@end

/*
 如果不手动停止run loop的话，会导致ViewController对象不能被释放。因为myThread保持了ViewController对象
 */

@interface ViewController ()

@property (weak, nonatomic) MyThread *myThread;
@property (strong, nonatomic) NSRunLoopMode runLoopMode;
@property (assign, nonatomic) BOOL shouldStopRunLoop;
@property (weak, nonatomic) NSTimer *timer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"switch run loop mode";
    
    /*
     如果不手动停止run loop的话，会导致ViewController对象不能被释放。因为myThread保持了ViewController对象
     */
    MyThread *thread = [[MyThread alloc] initWithTarget:self selector:@selector(enableRunLoop) object:nil];
    self.myThread = thread;
    thread.name = @"my thread";

    [thread start];
}

- (void)enableRunLoop
{
    NSLog(@"%@: task begin ...", [NSThread currentThread].name);
    
    /*
     测试子线程中创建的对象在子线程退出时，会不会被释放
     答案是：会的。所以不需要手动创建 autorelease pool
     */
    Foo *foo = [Foo new];
    [foo print];
    
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
    
    //    CFRunLoopAddCommonMode(CFRunLoopGetCurrent(), (CFStringRef)UITrackingRunLoopMode);
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:1 target:foo selector:@selector(printThreadInfo) userInfo:nil repeats:YES];
    self.timer = timer;
    [runLoop addTimer:timer forMode:NSDefaultRunLoopMode];
    [runLoop addTimer:timer forMode:UITrackingRunLoopMode];
    
    _runLoopMode = NSDefaultRunLoopMode;// ;
    int count = 0;

    while (!_shouldStopRunLoop)
    {
        ++count;
        NSLog(@"");
        NSLog(@"runLoop: start %d", count);
        [runLoop runMode:_runLoopMode beforeDate:[NSDate distantFuture]];
        NSLog(@"runLoop: end %d", count);
    }
    NSLog(@"%@: task end.", [NSThread currentThread].name);
}

- (void)changeMyThreadRunLoopMode
{
    NSRunLoopMode runLoopMode = [NSRunLoop currentRunLoop].currentMode;
    NSRunLoopMode newMode = UITrackingRunLoopMode;
    if (runLoopMode == UITrackingRunLoopMode) {
        newMode = NSDefaultRunLoopMode;
    }
    NSLog(@"%@: current run loop mode: %@, will be change to %@", [NSThread currentThread].name, runLoopMode, newMode);
    self.runLoopMode = newMode;
}

- (void)printRunLoopMode
{
    NSThread *thread = [NSThread currentThread];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    
    NSLog(@"%@: %@", thread.name, runLoop.currentMode);
}
- (IBAction)stopRunLoopAction:(id)sender
{
    [self performSelector:@selector(stopRunLoop) onThread:self.myThread withObject:nil waitUntilDone:NO modes:@[NSDefaultRunLoopMode, UITrackingRunLoopMode]];
}

- (void)stopRunLoop
{
    NSThread *thread = [NSThread currentThread];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    NSLog(@"%@[%@]: [%@ %@]", thread.name, runLoop.currentMode, [self class], NSStringFromSelector(_cmd));

    self.shouldStopRunLoop = YES;
    CFRunLoopRef currentRunLoop = CFRunLoopGetCurrent();
    CFRunLoopStop( currentRunLoop );
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"timer: %@", self.timer);
    [self performSelector:@selector(changeMyThreadRunLoopMode) onThread:self.myThread withObject:nil waitUntilDone:NO modes:@[NSDefaultRunLoopMode, UITrackingRunLoopMode]];
}

- (void)dealloc
{
    NSLog(@"[%@ %@]", [self class], NSStringFromSelector(_cmd));
}

@end
