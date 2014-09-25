//
//  CLCMenuExtraView.m
//  chinese lunar calendar
//
//  Created by Zhengfa DANG on 9/24/14.
//  Copyright (c) 2014 Zhengfa. All rights reserved.
//

#import "CLCMenuExtraView.h"
#import "CLCPopoverViewController.h"

@interface CLCMenuExtraView()
{
    int status;
    id _popoverTransiencyMonitor;
}
@end


@implementation CLCMenuExtraView

@synthesize control;
@synthesize active;

- (void)drawRect:(CGRect)rect
{
    
    // init the status item popup
    if(self.active)
    {
        [[NSColor selectedMenuItemTextColor] set];
    } else {
        [[NSColor yellowColor] set];
    }
    NSRect smallerRect = NSMakeRect(2, 3, rect.size.width - 4 , rect.size.height - 6);
    [[NSBezierPath bezierPathWithRect:smallerRect] fill];

    NSString *str = [NSString stringWithFormat:@"%d", status];

    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:kCTTextAlignmentCenter];
    NSDictionary *attr = [NSDictionary dictionaryWithObject:style forKey:NSParagraphStyleAttributeName];
    [str drawInRect:smallerRect withAttributes:attr];
}


- (void)updateViewFrame
{
//    CGFloat width = MAX(MAX(kMinViewWidth, self.alternateImage.size.width), self.image.size.width);
//    CGFloat height = [NSStatusBar systemStatusBar].thickness;
//    
//    NSRect frame = NSMakeRect(0, 0, width, height);
//    self.frame = frame;
    
    [self setNeedsDisplay:YES];
}


- (void)mouseDown:(id)arg1
{
    if( !self.active )
    {
        [self showPopover];
    } else {
        [self hidePopover];
    }
}


- (void) showPopover
{
    self.active = true;
    
    if(!self.control)
    {
        self.control = [[CLCPopoverViewController alloc] initWithNibName:@"CLCPopoverViewController" bundle:nil];
    }
    if(self.control && self.control.popover)
    {
//        [self.control.popover showRelativeToRect:[self bounds] ofView:self preferredEdge:NSMaxYEdge];
    }
    
    
    // if user click area outside of our menulet, hide the popover
    _popoverTransiencyMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:NSLeftMouseDownMask|NSRightMouseDownMask handler:^(NSEvent* event) {
        [self hidePopover];
    }];
    
    // repaint
    [self updateViewFrame];
}

- (void) hidePopover
{
    self.active = false;
    
    // remove the monitor
    [NSEvent removeMonitor:_popoverTransiencyMonitor];

    // repaint
    [self updateViewFrame];
}


@end
