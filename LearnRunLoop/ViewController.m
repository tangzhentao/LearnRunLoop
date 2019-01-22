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

@end

@implementation Foo

- (void)print
{
    NSLog(@"[%@ %@]", [self class], NSStringFromSelector(_cmd));
}

- (void)dealloc
{
    NSLog(@"[%@ %@]", [self class], NSStringFromSelector(_cmd));
}

@end

@interface ViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;

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
    
    self.textView.delegate = self;
    
    MyThread *thread = [[MyThread alloc] initWithTarget:self selector:@selector(enableRunLoop) object:nil];
    _myThread = thread;
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
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(printRunLoopMode) userInfo:nil repeats:YES];
    self.timer = timer;
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
    NSLog(@"%@: current run loop mode: %@, will be change to %@", [NSThread currentThread].name, runLoopMode, mode);
    self.runLoopMode = mode;
}

- (void)printRunLoopMode
{
    NSThread *thread = [NSThread currentThread];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    
    NSLog(@"%@: %@", thread.name, runLoop.currentMode);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
    NSLog(@"timer: %@", self.timer);
//    static int count = 1;
//    if (NSDefaultRunLoopMode == _runLoopMode) {
//        _runLoopMode = UITrackingRunLoopMode;
//    } else {
//        _runLoopMode = NSDefaultRunLoopMode;
//    }
//    [self performSelector:@selector(printRunLoopMode) onThread:_myThread withObject:nil waitUntilDone:YES];
//
//    if (10 == count) {
//        _shouldStopRunLoop = YES;
//    }
//    ++count;

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"[%@ %@]", [self class], NSStringFromSelector(_cmd));
    if (self.runLoopMode != UITrackingRunLoopMode)
    {
        [self performSelector:@selector(changeMyThreadRunLoopMode) onThread:self.myThread withObject:nil waitUntilDone:NO];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    //拖拽结束会调用这个方法，如果还有拖拽后的滑动动画就不做操作
    if (!decelerate) {
        //如果没有后续动画了就切换Mode为NSDefaultRunLoopMode
        if (self.runLoopMode != NSDefaultRunLoopMode) {
            //断点1
            [self performSelector:@selector(changeSubThreadRunLoopMode:) onThread:self.myThread withObject:NSDefaultRunLoopMode waitUntilDone:NO];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    //拖拽后的后续滑动动画结束（如果有才会到这，没有就不会到这个函数里面）
    //也就是说上面那个函数如果切换了Mode就不会走这里，否则说明需要在这里切换Mode
    //切换Mode为NSDefaultRunLoopMode
    if (self.runLoopMode != NSDefaultRunLoopMode) {
        //断点2
        [self performSelector:@selector(changeSubThreadRunLoopMode:) onThread:self.myThread withObject:NSDefaultRunLoopMode waitUntilDone:NO];
    }
}


@end
