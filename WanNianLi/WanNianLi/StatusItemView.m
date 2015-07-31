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
    NSString *calendarURL;
    NSMutableParagraphStyle *_style;
    long iToday;
    
    NSEvent *_popoverTransiencyMonitor;
}

@synthesize statusItem = _statusItem;
@synthesize image = _image;


- (id)initWithStatusItem:(NSStatusItem *)statusItem
{
    self = [super initWithFrame:NSZeroRect];
    if (self != nil) {
        _statusItem = statusItem;
        _statusItem.view = self;
    }
    
    self.calendar = [[CLCCalendar alloc] init];
    [self initCalendarResources];
    
    // create timer to refresh icon every 5 seconds
    [NSTimer scheduledTimerWithTimeInterval:5
                                     target:self
                                   selector:@selector(updateDateIcon)
                                   userInfo:nil
                                    repeats:YES];

    return self;
}

- (int) readVersion:(NSString*) filename
{
    int version = 0;
    NSFileHandle *vFile = [NSFileHandle fileHandleForReadingAtPath:filename];
    if (vFile != nil) {
        NSString *data = [[NSString alloc] initWithData:[vFile readDataToEndOfFile] encoding:NSUTF8StringEncoding];
        version = [data intValue];
        [vFile closeFile];
    } else {
        NSLog(@"Failed to read version in file: %@", filename);
    }
    NSLog(@"Version %d in %@", version, filename);
    
    return version;
}

// copy calendar resources from app package to personal folder
- (void) initCalendarResources {
    // prepare calendarURL
    // source directory in app package
    NSString *sourceDir = [[NSBundle mainBundle] resourcePath];
    calendarURL = [sourceDir stringByAppendingPathComponent:@"calendar.htm"];
    
    // find application support directory: "~/Library/Application Support/"
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    if([paths count] == 1){
        // app support directory for calendar: "~/Library/Application Support/com.zfdang.calendar"
        NSString *appSupportDir = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"com.zfdang.calendar"];
        
        // create app support directory if necessary
        BOOL isDir = NO;
        NSFileManager *fm = [NSFileManager defaultManager];
        if(!([fm fileExistsAtPath:appSupportDir isDirectory:&isDir] && isDir)){
            NSLog(@"create app support folder: %@", appSupportDir);
            [fm createDirectoryAtPath:appSupportDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        // find VERISON in source and support separately
        int supportVersion = [self readVersion:[appSupportDir stringByAppendingPathComponent:@"VERSION"]];
        int sourceVersion = [self readVersion:[sourceDir stringByAppendingPathComponent:@"VERSION"]];
        NSLog(@"Versions: source = %d, support = %d", sourceVersion, supportVersion);
        
        // copy calendar files from source directory if necessary
        if(sourceVersion > supportVersion){
            NSLog(@"copy all files from %@ to %@", sourceDir, appSupportDir);
            NSArray *files = [fm contentsOfDirectoryAtPath:sourceDir error:nil];
            for (NSString *file in files) {
                NSString *sourceFile = [sourceDir stringByAppendingPathComponent:file];
                NSString *destFile = [appSupportDir stringByAppendingPathComponent:file];
                NSLog(@"Copy file %@", file);
                if ([fm isReadableFileAtPath:sourceFile] ) {
                    [fm removeItemAtPath:destFile error:nil];
                    [fm copyItemAtPath:sourceFile toPath:destFile error:nil];
                }
            }
        } else {
            NSLog(@"version in support dir is ok, skip copying files");
        }
        
        // check version in support folder again
        supportVersion = [self readVersion:[appSupportDir stringByAppendingPathComponent:@"VERSION"]];
        
        // if version in support folder is OK, we will use calendar.htm in support folder
        if(supportVersion > 0){
            calendarURL = [appSupportDir stringByAppendingPathComponent:@"calendar.htm"];
        }
    } // if([paths count] == 1)
    
    NSLog(@"Calendar URL: %@", calendarURL);
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
    [self.statusItem drawStatusBarBackgroundInRect:dirtyRect withHighlight:self.active];
    
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

- (void)setImage:(NSImage *)newImage
{
    if (_image != newImage) {
        _image = newImage;
        [self setNeedsDisplay:YES];
    }
}


#pragma mark - Click Events

// Left Mouse Down, trigger left click action
-(void)mouseDown:(NSEvent *)theEvent {
//    NSLog(@"left mouse Down");
    [self togglePopover];
}

- (void)mouseUp:(NSEvent *)event {
//    NSLog(@"left mouse Up");
}

// Right Mouse Down, trigger right click action
-(void)rightMouseDown:(NSEvent *)theEvent{
//    NSLog(@"right mouse Down");
    [self togglePopover];
}

-(void)rightMouseUp:(NSEvent *)theEvent{
//    NSLog(@"right mouse Up");
}


// show or hide popover, and update calendar icon in menubar
- (void) togglePopover {
    if( !self.popover.shown )
    {
        [self showPopover];
    } else {
        [self hidePopover];
    }
    [self setNeedsDisplay:YES];
}

- (void) setupPopover
{
    if(! self.popover)
    {
        self.popover = [[NSPopover alloc] init];
        self.popover.contentViewController = [[CLCPopController alloc]  initWithNibName:@"CLCPopController" bundle:nil];
        self.popover.animates = YES;
        // The system will close the popover when the user interacts with a user interface element outside the popover.
        // it seems this does not work well
//        self.popover.behavior = NSPopoverBehaviorTransient;
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
    _popoverTransiencyMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:NSLeftMouseDownMask|NSRightMouseDownMask
                                                                           handler:^(NSEvent* event)
    {
        [self hidePopover];
        [self setNeedsDisplay:YES];
        [NSEvent removeMonitor:_popoverTransiencyMonitor];
        _popoverTransiencyMonitor = nil;
    }];

    // repaint
    [self updateViewFrame];

    // activate the calendar view
    // 这个应该是可配置的，有些人可能更喜欢popover不干扰其他窗口
    [NSApp activateIgnoringOtherApps:YES];
}

- (void) hidePopover
{
    self.active = false;
    [self.popover performClose:nil];
}


// methods from NSPopoverDelegate
- (void)popoverDidClose:(NSNotification *)notification{

}

- (void)updateViewFrame
{
    // load calendar html page
    if ([[self popover] isShown])
    {
        //        NSString *resourcesPath = [_menuExtra.bundle resourcePath];
        //        NSString *htmlPath = [resourcesPath stringByAppendingString:@"/calendar.htm"];
        //        NSLog(@"updateViewFrame, calendar URL is %@", calendarURL);
        WebView *webView = [(CLCPopController*)self.popover.contentViewController webView];
        [[webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:calendarURL]]];
        [webView setDrawsBackground:NO];
        [[[webView mainFrame] frameView] setAllowsScrolling:NO];
    }
    
    // refresh
    [self setNeedsDisplay:YES];
}

@end
