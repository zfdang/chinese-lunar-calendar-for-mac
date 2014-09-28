//
//  CLCMenuExtraView.m
//  chinese lunar calendar
//
//  Created by Zhengfa DANG on 9/24/14.
//  Copyright (c) 2014 Zhengfa. All rights reserved.
//

#import "CLCMenuExtraView.h"
#import "CLCPopController.h"
#import "CLCCalendar.h"
#import <WebKit/WebKit.h>

@interface CLCMenuExtraView()
{
    id _popoverTransiencyMonitor;
    NSRect upRect;
    NSRect calRect;
    
    NSMutableParagraphStyle *style;
    NSDictionary *attr;
}
@end


@implementation CLCMenuExtraView

@synthesize popover;
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
        [[NSColor brownColor] set];
    } else {
        [[NSColor blackColor] set];
    }
    
    if(upRect.size.height == 0)
    {
        // init rect
        upRect = NSMakeRect(2, rect.size.height - 4, rect.size.width - 4, 2);
        calRect = NSMakeRect(2, 2, rect.size.width - 4, rect.size.height - 7);
        
        // init string drawing attr
        style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [style setAlignment:kCTTextAlignmentCenter];
        attr = [NSDictionary  dictionaryWithObjectsAndKeys:
                              [NSColor whiteColor], NSForegroundColorAttributeName,
                              [NSFont systemFontOfSize:11], NSFontAttributeName,
                              style, NSParagraphStyleAttributeName,
                              nil];
    }

    // draw background of calendar icon
    [[NSBezierPath bezierPathWithRect:upRect] fill];
    [[NSBezierPath bezierPathWithRoundedRect:calRect xRadius:2 yRadius:2] fill];
    
    // draw date
    NSString *str = [NSString stringWithFormat:@"%ld", [self.calendar getDay:nil]];
    [str drawInRect:calRect withAttributes:attr];
}


- (void)updateViewFrame
{
    // load calendar html page
    if ([[self popover] isShown])
    {
        NSString *resourcesPath = [_menuExtra.bundle resourcePath];
        NSString *htmlPath = [resourcesPath stringByAppendingString:@"/calendar.htm"];
//        NSLog(@"updateViewFrame, htmlPath is %@", htmlPath);
        WebView *webView = [(CLCPopController*)self.popover.contentViewController webView];
        [[webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:htmlPath]]];
        [webView setDrawsBackground:NO];
        [[[webView mainFrame] frameView] setAllowsScrolling:NO];
    }
    
    // refresh
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

- (void) setupPopover
{
    if(! self.popover)
    {
        self.popover = [[NSPopover alloc] init];
        self.popover.contentViewController = [[CLCPopController alloc]  initWithNibName:@"CLCPopController" bundle:_menuExtra.bundle];
    }
}

- (void) showPopover
{
    self.active = true;
    
    [self setupPopover];

    [self.popover showRelativeToRect:[self bounds]
                              ofView:self
                       preferredEdge:NSMinYEdge];

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
    
    [self.popover performClose:nil];
    
    // remove the monitor
    [NSEvent removeMonitor:_popoverTransiencyMonitor];

    // repaint
    [self updateViewFrame];
}


@end
