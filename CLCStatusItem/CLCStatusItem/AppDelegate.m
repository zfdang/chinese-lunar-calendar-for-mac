//
//  AppDelegate.m
//  CLCStatusItem
//
//  Created by Zhengfa DANG on 9/24/14.
//  Copyright (c) 2014 Zhengfa. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

-(void)awakeFromNib
{
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setMenu:self.statusMenu];
    [statusItem setTitle:@"Status"];
    [statusItem setHighlightMode:YES];
}

- (IBAction)menuQuit:(id)sender {
    [NSApp terminate:sender];
}
@end
