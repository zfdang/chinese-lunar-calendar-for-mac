//
//  AppDelegate.m
//  WanNianLi
//
//  Created by Zhengfa DANG on 2015-7-30.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import "AppDelegate.h"
#import "StatusItemController.h"
#import "PFMoveApplication.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // https://github.com/potionfactory/LetsMove
    // move app into application folder ?
    PFMoveToApplicationsFolderIfNecessary();

    // Install icon into the menu bar
    self.statusItemController = [[StatusItemController alloc] init];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
