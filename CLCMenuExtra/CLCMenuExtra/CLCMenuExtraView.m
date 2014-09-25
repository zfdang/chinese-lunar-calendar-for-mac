//
//  CLCMenuExtraView.m
//  chinese lunar calendar
//
//  Created by Zhengfa DANG on 9/24/14.
//  Copyright (c) 2014 Zhengfa. All rights reserved.
//

#import "CLCMenuExtraView.h"
#import "CLCPopoverViewController.h"
#import "CLCCalendar.h"

@interface CLCMenuExtraView()
{
    int status;
    id _popoverTransiencyMonitor;
}
@end


@implementation CLCMenuExtraView

@synthesize control;
@synthesize active;
@synthesize calendar;


- (id)initWithFrame:(CGRect)arg1 menuExtra:(id)arg2
{
    self = [super initWithFrame:arg1 menuExtra:arg2];
    
    self.calendar = [[CLCCalendar alloc] init];
    return self;
}


- (void)drawRect:(CGRect)rect
{
    
    // init the status item popup
    if(self.active)
    {
        [[NSColor blueColor] set];
    } else {
        [[NSColor blackColor] set];
    }
    
    // to do: draw chinese & digits seperately; save attr for future usage
    NSRect smallerRect = NSMakeRect(0, 4, rect.size.width - 2 , rect.size.height - 8);
    [[NSBezierPath bezierPathWithRoundedRect:smallerRect xRadius:4 yRadius:4] fill];
    
    NSString *str = [NSString stringWithFormat:@"%d", [self.calendar getDay:nil]];

    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:kCTTextAlignmentCenter];
    NSDictionary *attr = [NSDictionary  dictionaryWithObjectsAndKeys:
                            [NSColor whiteColor], NSForegroundColorAttributeName,
                            [NSFont systemFontOfSize:11], NSFontAttributeName,
                            style, NSParagraphStyleAttributeName,
                            nil];
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
