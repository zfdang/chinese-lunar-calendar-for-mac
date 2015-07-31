//
//  StatusItemController.m
//  CLCStatusItem
//
//  Created by Zhengfa DANG on 2015-7-30.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import "StatusItemController.h"
#import "StatusItemView.h"

@implementation StatusItemController

@synthesize statusItem = _statusItem;
@synthesize statusItemView = _statusItemView;


- (instancetype)init
{
    self = [super init];
    if (self) {
        // Install status item into the menu bar
        _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
        // create custom view for status item
        _statusItemView = [[StatusItemView alloc] initWithStatusItem:_statusItem];
        // use hardcoded image as calendar background
        _statusItemView.image = [NSImage imageNamed:@"calendarIcon"];
    }
    return self;
}

- (void)dealloc
{
    [[NSStatusBar systemStatusBar] removeStatusItem:self.statusItem];
}

@end
