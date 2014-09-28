//
//  CLCMenuExtra.h
//  chinese lunar calendar
//
//  Created by Zhengfa DANG on 9/24/14.
//  Copyright (c) 2014 Zhengfa. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSMenuExtra.h"
#import "NSMenuExtraView.h"

@class CLCMenuExtraView;
@class CLCMenuExtraController;

@interface CLCMenuExtra : NSMenuExtra
{
    CLCMenuExtraView __strong *theView;
}


@end