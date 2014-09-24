//
//  CLCMenuExtra.m
//  chinese lunar calendar
//
//  Created by Zhengfa DANG on 9/24/14.
//  Copyright (c) 2014 Zhengfa. All rights reserved.
//

#import "CLCMenuExtra.h"
#import "CLCMenuExtraView.h"

@implementation CLCMenuExtra
- (id)initWithBundle:(id)bundle
{
    self = [super initWithBundle:bundle];
    if(self == nil)
        return nil;
    
    // we will create and set the MenuExtraView
    theView = [[CLCMenuExtraView alloc] initWithFrame:[[self view] frame] menuExtra:self];
    [self setView:theView];
    
    return self;
}

- (void)dealloc
{
    // we are using ARC, so no need to call dealloc any more
//    [theView release];
//    [super dealloc];
}

@end
