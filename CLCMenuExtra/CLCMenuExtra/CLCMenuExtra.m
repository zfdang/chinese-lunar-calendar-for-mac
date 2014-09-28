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
    
    // MenuExtraView
    theView = [[CLCMenuExtraView alloc] initWithFrame:[[self view] frame] menuExtra:self];
//    [theView setImage:[NSImage imageNamed:@"cloud"]];
//    [theView setAlternateImage:[NSImage imageNamed:@"cloudgrey"]];
    [theView setActive:false];
    
    [self setView:theView];
    
    // create menu, but we don't use menu in this app
    // if you want to use menu, please also uncomment - (NSMenu *)menu
//    theMenu = [[NSMenu alloc] initWithTitle: @""];
//    [theMenu setAutoenablesItems: NO];
//    [theMenu addItemWithTitle: @"Useless item 1"
//                       action: nil
//                keyEquivalent: @""];
//    [theMenu addItem:[NSMenuItem separatorItem]];
//     NSMenuItem *menuItem = [theMenu addItemWithTitle:@"Less useless item 2"
//                                              action:nil
//                                       keyEquivalent:@""];
//    [menuItem setTarget:self];


    return self;
}

//- (NSMenu *)menu
//{
//    return theMenu;
//}

@end
