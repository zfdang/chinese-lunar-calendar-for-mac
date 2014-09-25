//
//  CLCMenuExtraController.m
//  chinese lunar calendar
//
//  Created by Zhengfa DANG on 9/25/14.
//  Copyright (c) 2014 Zhengfa. All rights reserved.
//

#import "CLCMenuExtraController.h"
#import "CLCPopoverViewController.h"
#import "CLCMenuExtra.h"

@implementation CLCMenuExtraController

@synthesize active;
@synthesize popControl;
@synthesize menulet;

- (id)init
{
    if(self = [super init])
    {
        self.active = false;
        self.popControl = [[CLCPopoverViewController alloc] init];
    }
    return self;
}

- (void)clickStatusItem
{
    self.active = !active; //每次被单击时改变 active 的值
    NSLog(@"click status is: %d", active);
    if (active) {
        //show popover
        [self.popControl.popover showRelativeToRect:[[menulet view] frame] ofView:[menulet view] preferredEdge:NSMaxXEdge];
    } else {
        //close popover
        [self.popControl.popover self];
    }
}

@end
