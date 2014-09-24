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
    // Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

-(void)awakeFromNib{
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setMenu:self.statusMenu];
    [statusItem setTitle:@"Status"];
    [statusItem setHighlightMode:YES];

    NSString *menuExtraCrackerPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"MenuCracker.menu"];
    NSLog(@" Path of menuCracker: %@", menuExtraCrackerPath);
    CFURLRef url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)menuExtraCrackerPath, kCFURLPOSIXPathStyle, NO);
    // Do not check the return value as it is always going to return an error
    unsigned int outExtra;
    CoreMenuExtraAddMenuExtra(url, 0, 0, nil, 0, &outExtra);
    CFRelease(url);
    
    NSString *menuExtraCLCPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"CLCMenuExtra.menu"];
    NSLog(@" Path of menuCracker: %@", menuExtraCLCPath);
    url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)menuExtraCLCPath, kCFURLPOSIXPathStyle, NO);
    // Do not check the return value as it is always going to return an error
    CoreMenuExtraAddMenuExtra(url, 0, 0, nil, 0, &outExtra);
    CFRelease(url);
    
}


- (IBAction)menuA:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setFloatingPanel:YES];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:YES];
    NSInteger i = [panel runModal];

    if (i == NSOKButton)
    {
        NSArray *results = [panel URLs];
        NSEnumerator *enmu = [results objectEnumerator];
        id obj;
        while(obj = [enmu nextObject])
        {
            NSLog(@"%@", [obj absoluteString]);
        }
    }
    
}

- (IBAction)menuQuit:(id)sender {
    [NSApp terminate:sender];
}


- (IBAction)menuExtra:(id)sender {
    NSString *menuExtraCrackerPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"MenuCracker.menu"];
    NSLog(@" Path of menuCracker: %@", menuExtraCrackerPath);
    CFURLRef url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)menuExtraCrackerPath, kCFURLPOSIXPathStyle, NO);
    // Do not check the return value as it is always going to return an error
    unsigned int outExtra;
    CoreMenuExtraAddMenuExtra(url, 0, 0, nil, 0, &outExtra);
    CFRelease(url);
    
    NSString *menuExtraCLCPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"CLCMenuExtra.menu"];
    NSLog(@" Path of menuCracker: %@", menuExtraCLCPath);
    url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)menuExtraCLCPath, kCFURLPOSIXPathStyle, NO);
    // Do not check the return value as it is always going to return an error
    CoreMenuExtraAddMenuExtra(url, 0, 0, nil, 0, &outExtra);
    CFRelease(url);
}

@end
