//
//  AppDelegate.h
//  CLCStatusItem
//
//  Created by Zhengfa DANG on 9/24/14.
//  Copyright (c) 2014 Zhengfa. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    NSStatusItem *statusItem;
}

@property (weak) IBOutlet NSMenu *statusMenu;

- (IBAction)menuQuit:(id)sender;

@end

