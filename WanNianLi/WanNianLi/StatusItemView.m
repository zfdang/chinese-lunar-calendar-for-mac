//
//  StatusItemView.m
//  CLCStatusItem
//
//  Created by Zhengfa DANG on 2015-7-30.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import "StatusItemView.h"

@implementation StatusItemView
{
    BOOL _isLeftMenuOn;
    BOOL _isRightMenuOn;

    NSMutableParagraphStyle *_style;
}

@synthesize statusItem = _statusItem;

@synthesize image = _image;
@synthesize alternateImage = _alternateImage;
@synthesize menu = _menu;
@synthesize rightMenu = _rightMenu;



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
    return self;
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

//    iToday = 30;
    NSString *strDay = [NSString stringWithFormat:@"%02ld", 30];
    NSRect calRect = NSMakeRect(2, 3, self.bounds.size.width - 4, self.bounds.size.height - 9);

    [strDay drawInRect:calRect withAttributes:attr];
    
    
//    BOOL highlighted = _isMouseDown || _isMenuVisible;
//    
//    // Draw status bar background, highlighted if menu is showing
//    [_statusItem drawStatusBarBackgroundInRect:[self bounds] withHighlight:highlighted];
//    
//    NSRect imageRect = NSInsetRect(self.bounds, RHStatusItemViewImageHPadding, RHStatusItemViewImageVPadding);
//    imageRect.origin.y++; //move it up one pix
//    
//    if (highlighted){
//        [self.alternateImage drawInRect:imageRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
//    } else {
//        [self.image drawInRect:imageRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
//    }
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

- (void)setAlternateImage:(NSImage *)newImage
{
    if (_alternateImage != newImage) {
        _alternateImage = newImage;
        if (self.isHighlighted) {
            [self setNeedsDisplay:YES];
        }
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
    _isLeftMenuOn = YES;
    if(self.delegate && [self.delegate respondsToSelector:@selector(leftClickOnStatusItem)] ){
        [self.delegate leftClickOnStatusItem];
    } else {
        [self popUpMenu];
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
    if(self.delegate && [self.delegate respondsToSelector:@selector(rightClickOnStatusItem)] ){
        [self.delegate rightClickOnStatusItem];
    } else {
        [self popUpRightMenu];
    }
    [self setNeedsDisplay:YES];
}


#pragma mark - Menu showing
-(void)popUpMenu{
    [self popUpMenu:self.menu];
}

-(void)popUpRightMenu{
    [self popUpMenu:self.rightMenu];
}

-(void)popUpMenu:(NSMenu*)menu{
    if (menu){
        //register for menu did open and close notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuWillOpen:) name:NSMenuDidBeginTrackingNotification object:menu];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuDidClose:) name:NSMenuDidEndTrackingNotification object:menu];
        
        [_statusItem popUpStatusItemMenu:menu];
    }
}


#pragma mark - NSMenuDidBeginTrackingNotification
-(void)menuWillOpen:(NSNotification *)notification{
    [self setNeedsDisplay:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSMenuDidBeginTrackingNotification object:notification.object];
}


#pragma mark - NSMenuDidEndTrackingNotification
-(void)menuDidClose:(NSNotification *)notification{
    [self setNeedsDisplay:YES];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSMenuDidEndTrackingNotification object:notification.object];
}

@end
