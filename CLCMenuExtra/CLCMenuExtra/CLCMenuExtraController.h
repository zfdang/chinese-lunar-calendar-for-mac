//
//  CLCMenuExtraController.h
//  chinese lunar calendar
//
//  Created by Zhengfa DANG on 9/25/14.
//  Copyright (c) 2014 Zhengfa. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CLCPopoverViewController;
@class CLCMenuExtra;

@interface CLCMenuExtraController : NSObject
{
//    BOOL active;
//    CLCPopoverViewController *popControl;
//    CLCMenuExtra *menulet;
}

@property BOOL active;
@property (retain) CLCPopoverViewController *popControl;
@property (weak) CLCMenuExtra *menulet;

- (void)clickStatusItem;

@end
