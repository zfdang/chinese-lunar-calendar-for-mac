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
    NSRect calRect;
    
    NSMutableParagraphStyle *style;
    
    NSImage *imageIcon;
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
    if(calRect.size.height == 0)
    {
        // init rect
        calRect = NSMakeRect(2, 2, rect.size.width - 4, rect.size.height - 9);
        
        // init string drawing attr
        style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [style setAlignment:kCTTextAlignmentCenter];
        
        NSString *resourcesPath = [_menuExtra.bundle resourcePath];
        NSString *iconPath = [resourcesPath stringByAppendingString:@"/icon.png"];
        imageIcon = [[NSImage alloc]initWithContentsOfFile:iconPath];
    }

    // draw background of calendar icon
    [imageIcon drawInRect:rect];

    // draw day of month
    NSDictionary *attr;
    if(self.active)
    {
        attr = [NSDictionary  dictionaryWithObjectsAndKeys:
                [NSColor brownColor], NSForegroundColorAttributeName,
                [NSFont systemFontOfSize:11], NSFontAttributeName,
                style, NSParagraphStyleAttributeName,
                nil];
        [[NSColor blackColor] set];
    } else {
        attr = [NSDictionary  dictionaryWithObjectsAndKeys:
                [NSColor blackColor], NSForegroundColorAttributeName,
                [NSFont systemFontOfSize:11], NSFontAttributeName,
                style, NSParagraphStyleAttributeName,
                nil];
        [[NSColor blackColor] set];
    }
    NSString *strDay = [NSString stringWithFormat:@"%ld", [self.calendar getDay:nil]];
    [strDay drawInRect:calRect withAttributes:attr];
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
