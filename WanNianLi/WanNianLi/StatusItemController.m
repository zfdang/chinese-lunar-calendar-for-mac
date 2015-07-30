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
        _statusItemView = [[StatusItemView alloc] initWithStatusItem:_statusItem];
        // use hardcoded image as calendar background
        _statusItemView.image = [NSImage imageNamed:@"background"];
//        _statusItemView.action = @selector(togglePanel:);
    }
    return self;
}

- (void)dealloc
{
    [[NSStatusBar systemStatusBar] removeStatusItem:self.statusItem];
}


#pragma mark -
#pragma mark Public accessors

- (NSStatusItem *)statusItem
{
    return self.statusItemView.statusItem;
}

#pragma mark -

- (BOOL)hasActiveIcon
{
    return self.statusItemView.isHighlighted;
}

- (void)setHasActiveIcon:(BOOL)flag
{
    self.statusItemView.isHighlighted = flag;
}


@end
