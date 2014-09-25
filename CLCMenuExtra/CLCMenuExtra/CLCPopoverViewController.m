//
//  CLCPopoverViewController.m
//  chinese lunar calendar
//
//  Created by Zhengfa DANG on 9/25/14.
//  Copyright (c) 2014 Zhengfa. All rights reserved.
//

#import "CLCPopoverViewController.h"

@interface CLCPopoverViewController ()

@end

@implementation CLCPopoverViewController

@synthesize popover;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        self.popover = [[NSPopover alloc] init];
        self.popover.contentViewController = self;
    }
    return self;
}



@end
