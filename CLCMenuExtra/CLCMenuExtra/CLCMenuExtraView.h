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

@interface CLCMenuExtraView : NSMenuExtraView
{
}

@property(strong, nonatomic) CLCPopoverViewController *control;
@property BOOL active;

@end
