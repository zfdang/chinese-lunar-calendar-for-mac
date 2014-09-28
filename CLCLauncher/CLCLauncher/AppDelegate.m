//
//  AppDelegate.m
//  CLCLauncher
//
//  Created by Zhengfa DANG on 9/24/14.
//  Copyright (c) 2014 Zhengfa. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // quit application since this app is used to launch MenuExtra only
    [NSApp terminate:nil];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

-(void)awakeFromNib{
    // launch MenuCracker first
    NSString *menuExtraCrackerPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"MenuCracker.menu"];
//    NSLog(@" Path of menuCracker: %@", menuExtraCrackerPath);
    CFURLRef url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)menuExtraCrackerPath, kCFURLPOSIXPathStyle, NO);
    // Do not check the return value as it is always going to return an error
    unsigned int outExtra;
    CoreMenuExtraAddMenuExtra(url, 0, 0, nil, 0, &outExtra);
    CFRelease(url);
    
    // launch our calender now
    NSString *menuExtraCLCPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"CLCMenuExtra.menu"];
//    NSLog(@" Path of menuCracker: %@", menuExtraCLCPath);
    url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)menuExtraCLCPath, kCFURLPOSIXPathStyle, NO);
    // Do not check the return value as it is always going to return an error
    CoreMenuExtraAddMenuExtra(url, 0, 0, nil, 0, &outExtra);
    CFRelease(url);
}

@end
