//
//  CLCMenuExtraView.m
//  chinese lunar calendar
//
//  Created by Zhengfa DANG on 9/24/14.
//  Copyright (c) 2014 Zhengfa. All rights reserved.
//

#import "CLCMenuExtraView.h"

@implementation CLCMenuExtraView

- (void)drawRect:(CGRect)rect
{
    if([_menuExtra isMenuDown])
    {
        [[NSColor selectedMenuItemTextColor] set];
    } else {
        [[NSColor blackColor] set];
    }
    
    NSRect smallerRect = NSMakeRect(4, 4, rect.size.width - 8 , rect.size.height-8);
    [[NSBezierPath bezierPathWithRect:smallerRect] fill];
}


@end
