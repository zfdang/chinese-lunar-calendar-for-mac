//
//  CLCMenuExtra.m
//  chinese lunar calendar
//
//  Created by Zhengfa DANG on 9/24/14.
//  Copyright (c) 2014 Zhengfa. All rights reserved.
//

#import "CLCMenuExtra.h"
#import "CLCMenuExtraView.h"
#import "CLCMenuExtraController.h"


@implementation CLCMenuExtra
- (id)initWithBundle:(id)bundle
{
    self = [super initWithBundle:bundle];
    if(self == nil)
        return nil;
    
    // MenuExtraView
    theView = [[CLCMenuExtraView alloc] initWithFrame:[[self view] frame] menuExtra:self];
    [self setView:theView];

    // MenuExtraController
    theControl = [[CLCMenuExtraController alloc] init];
    [theControl setMenulet:self];
    [self setAction:@selector(clickStatusItem)];
    [self setTarget:theControl];
    
    return self;
}



- (void)dealloc
{
}

@end
