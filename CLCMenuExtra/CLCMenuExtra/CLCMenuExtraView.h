//
//  CLCMenuExtraView.h
//  chinese lunar calendar
//
//  Created by Zhengfa DANG on 9/24/14.
//  Copyright (c) 2014 Zhengfa. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSMenuExtra.h"
#import "NSMenuExtraView.h"
@class CLCPopoverViewController;
@class CLCCalendar;

@interface CLCMenuExtraView : NSMenuExtraView <NSPopoverDelegate>
{
}

@property(strong, nonatomic) NSPopover *popover;
@property(strong, nonatomic) CLCCalendar *calendar;
@property BOOL active;

- (void) updateDateIcon;
@end
