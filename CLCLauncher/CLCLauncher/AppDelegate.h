//
//  AppDelegate.h
//  CLCLauncher
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

@property (weak) IBOutlet NSWindow *window;
- (IBAction)menuA:(id)sender;
- (IBAction)menuQuit:(id)sender;
- (IBAction)menuExtra:(id)sender;

@end

