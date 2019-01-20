//
//  MyThread.m
//  LearnRunLoop
//
//  Created by tang on 2019/1/20.
//  Copyright © 2019 genghaowan. All rights reserved.
//

#import "MyThread.h"

@implementation MyThread

- (void)dealloc
{
    NSLog(@"[%@ %@]: %@", [self class], NSStringFromSelector(_cmd), self.name);
}

@end
