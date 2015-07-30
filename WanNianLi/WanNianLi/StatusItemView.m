//
//  StatusItemView.m
//  CLCStatusItem
//
//  Created by Zhengfa DANG on 2015-7-30.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import "StatusItemView.h"
#import "CLCPopController.h"
#import "CLCCalendar.h"
#import <WebKit/WebKit.h>


@implementation StatusItemView
{
    BOOL _isLeftMenuOn;
    BOOL _isRightMenuOn;

    NSMutableParagraphStyle *_style;
    long iToday;
}

@synthesize statusItem = _statusItem;

@synthesize image = _image;



- (id)initWithStatusItem:(NSStatusItem *)statusItem
{
//    CGFloat itemWidth = [statusItem length];
//    CGFloat itemHeight = [[NSStatusBar systemStatusBar] thickness];
//    NSRect itemRect = NSMakeRect(0.0, 0.0, itemWidth, itemHeight);

    self = [super initWithFrame:NSZeroRect];
    if (self != nil) {
        _statusItem = statusItem;
        _statusItem.view = self;
    }
    
    self.calendar = [[CLCCalendar alloc] init];
    return self;
}

- (void) updateDateIcon
{
    long d = [self.calendar getDay:nil];
    if(d != iToday){
        [self setNeedsDisplay:YES];
    }
    //    NSLog(@"update date icon");
}


- (void)drawRect:(NSRect)dirtyRect
{
    [self.statusItem drawStatusBarBackgroundInRect:dirtyRect withHighlight:self.isHighlighted];
    
    // use hardcoded image as calendar background
    self.image = [NSImage imageNamed:@"background"];
    NSRect destRect = [self getCenteredRect:self.image.size bounds:self.bounds];
    // destRect = NSInsetRect(destRect, 1, 0);

    // Available in OS X v10.6 and later.
    [self.image drawInRect:destRect
                 fromRect:NSZeroRect
                operation:NSCompositeSourceOver
                 fraction:1.0];

    // init string drawing attr
    if(_style == nil) {
        _style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [_style setAlignment:NSCenterTextAlignment];
    }

    // draw day of month
    NSDictionary *attr;
    attr = [NSDictionary  dictionaryWithObjectsAndKeys:
            [NSColor blackColor], NSForegroundColorAttributeName,
            [NSFont fontWithName:@"Helvetica" size:11], NSFontAttributeName,
            _style, NSParagraphStyleAttributeName,
            nil];
    [[NSColor blackColor] set];

    iToday = [self.calendar getDay:nil];
    NSString *strDay = [NSString stringWithFormat:@"%02ld", iToday];
    NSRect calRect = NSMakeRect(2, 3, self.bounds.size.width - 4, self.bounds.size.height - 9);

    [strDay drawInRect:calRect withAttributes:attr];
}

- (NSRect) getCenteredRect:(NSSize)srcSize bounds:(NSRect)boundRect {
    CGFloat boundRatio = NSWidth(boundRect) / NSHeight(boundRect);
    CGFloat srcRatio = srcSize.width / srcSize.height;
    
    CGFloat destHeight = 0.0;
    CGFloat destWidth = 0.0;
    if(boundRatio >= srcRatio) {
        // 目标区域比源图像更宽，源图像的两边将留白
        destHeight = NSHeight(boundRect);
        destWidth = destHeight * srcRatio;
    } else {
        // 目标区域比源图像更窄，源图像的上下两边将留白
        destWidth = NSWidth(boundRect);
        destHeight = destWidth / srcRatio;
    }
    
    CGFloat xOffset = (NSWidth(boundRect) - destWidth) / 2.0;
    CGFloat yOffset = (NSHeight(boundRect) - destHeight) / 2.0;
    return NSMakeRect(xOffset, yOffset, NSWidth(boundRect) - xOffset * 2 , NSHeight(boundRect) - yOffset * 2);
}

#pragma mark - Accessors


- (void)setHighlighted:(BOOL)newFlag
{
    if (_isHighlighted == newFlag) return;
    _isHighlighted = newFlag;
    [self setNeedsDisplay:YES];
}

- (void)setImage:(NSImage *)newImage
{
    if (_image != newImage) {
        _image = newImage;
        [self setNeedsDisplay:YES];
    }
}


#pragma mark -

- (NSRect)globalRect
{
    NSRect frame = [self frame];
    return [self.window convertRectToScreen:frame];
}


#pragma mark - Click Events

// Left Mouse Down, trigger left click action
-(void)mouseDown:(NSEvent *)theEvent {
    NSLog(@"left mouse Down");
    if( !self.popover.shown )
    {
        [self showPopover];
    } else {
        [self hidePopover];
    }

    [self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)event {
}

// Right Mouse Down, trigger right click action
-(void)rightMouseDown:(NSEvent *)theEvent{
    NSLog(@"right mouse Down");
    self.isHighlighted = !self.isHighlighted;
    _isRightMenuOn = YES;
    [self setNeedsDisplay:YES];
}


- (void) setupPopover
{
    if(! self.popover)
    {
        self.popover = [[NSPopover alloc] init];
        self.popover.contentViewController = [[CLCPopController alloc]  initWithNibName:@"CLCPopController" bundle:nil];
        self.popover.animates = NO;
        // The system will close the popover when the user interacts with a user interface element outside the popover.
        self.popover.behavior = NSPopoverBehaviorTransient;
        self.popover.delegate = self;
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
    // we use popover.behavior for this purpose
    //    _popoverTransiencyMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:NSLeftMouseDownMask|NSRightMouseDownMask
    //                                                                       handler:^(NSEvent* event) {
    //        [self hidePopover];
    //    }];
    
    // repaint
//    [self updateViewFrame];
}

- (void) hidePopover
{
    self.active = false;
    
    [self.popover performClose:nil];
    
    // remove the monitor
    //    [NSEvent removeMonitor:_popoverTransiencyMonitor];
    
    // repaint
//    [self updateViewFrame];
}


// methods from NSPopoverDelegate
- (void)popoverDidClose:(NSNotification *)notification{
//    [self updateViewFrame];
}
@end
