//
//  StatusItemView.h
//  CLCStatusItem
//
//  Created by Zhengfa DANG on 2015-7-30.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class CLCPopController;
@class CLCCalendar;


// StatusItemView: customized view to show icon in menubar
@interface StatusItemView : NSControl <NSPopoverDelegate> {
}

@property (nonatomic, strong, readonly) NSStatusItem *statusItem;

@property (nonatomic, retain) NSImage *image;


@property(strong, nonatomic) NSPopover *popover;
@property(strong, nonatomic) CLCCalendar *calendar;
@property BOOL active;



- (id)initWithStatusItem:(NSStatusItem *)statusItem;

- (NSRect) getCenteredRect:(NSSize)srcSize bounds:(NSRect)boundRect;
- (void) updateDateIcon;

- (void) showPopover;
- (void) hidePopover;

@end
