//
//  ViewController.m
//  LearnRunLoop
//
//  Created by tang on 2019/1/20.
//  Copyright © 2019 genghaowan. All rights reserved.
//

#import "ViewController.h"
#import "ThreadViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"process info";
    
    NSProcessInfo * processInfo = [NSProcessInfo processInfo];
    NSLog(@"processInfo:");
    NSLog(@"environment: %@", processInfo.environment);
    NSLog(@"arguments: %@", processInfo.arguments);
    NSLog(@"hostName: %@", processInfo.hostName);
    NSLog(@"processName: %@", processInfo.processName);
    NSLog(@"globallyUniqueString: %@", processInfo.globallyUniqueString);
    NSLog(@"processIdentifier: %d", processInfo.processIdentifier);
    NSLog(@"getpid: %d",  getpid());
    
    NSOperatingSystemVersion OSVersion = processInfo.operatingSystemVersion;
    NSLog(@"operatingSystemVersion: %ld.%ld.%ld", OSVersion.majorVersion, OSVersion.minorVersion, OSVersion.patchVersion);
    NSLog(@"operatingSystemVersionString: %@", processInfo.operatingSystemVersionString);
    NSLog(@"processorCount: %ld", processInfo.processorCount);
    NSLog(@"physicalMemory: %lld", processInfo.physicalMemory);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
//    [self.navigationController pushViewController:[ThreadViewController new] animated:YES];
}

@end
