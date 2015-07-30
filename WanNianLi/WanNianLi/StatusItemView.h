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
@interface StatusItemView : NSControl {
    BOOL _isHighlighted;

    NSImage *_image;
}

@property (nonatomic, strong, readonly) NSStatusItem *statusItem;

@property (nonatomic, retain) NSImage *image;


@property (nonatomic, setter = setHighlighted:) BOOL isHighlighted;

@property(strong, nonatomic) NSPopover *popover;
@property(strong, nonatomic) CLCCalendar *calendar;
@property BOOL active;



- (id)initWithStatusItem:(NSStatusItem *)statusItem;

- (void) updateDateIcon;

@end
