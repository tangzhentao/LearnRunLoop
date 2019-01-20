//
//  ThreadViewController.m
//  LearnRunLoop
//
//  Created by tang on 2019/1/20.
//  Copyright © 2019 genghaowan. All rights reserved.
//

#import "ThreadViewController.h"
#import "MyThread.h"

@interface ThreadViewController ()

@property (strong, nonatomic) MyThread *subthread;

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
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"thread<%@>:\n is executing ? %@\n is finished ? %@", _subthread.name, _subthread.isExecuting ? @"Yes" : @"No", _subthread.isFinished ? @"Yes" : @"No");
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

@end
