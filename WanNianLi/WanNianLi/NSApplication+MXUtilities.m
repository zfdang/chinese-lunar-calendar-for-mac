//
//  NSApplication+MXUtilities.m
//  Mixim
//
//  Created by Joe Rickerby on 15/09/2014.
//  Copyright (c) 2014 Mixim Technology Ltd. Released under BSD Licence.
//

#import "NSApplication+MXUtilities.h"

@implementation NSApplication (MXUtilities)

- (BOOL)launchAtLogin
{
    LSSharedFileListItemRef loginItem = [self loginItem];
    BOOL result = loginItem ? YES : NO;

    if (loginItem) {
        CFRelease(loginItem);
    }
    
    return result;
}

- (void)setLaunchAtLogin:(BOOL)launchAtLogin
{
    if (launchAtLogin == self.launchAtLogin) {
        return;
    }

    LSSharedFileListRef loginItemsRef = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);

    if (launchAtLogin) {
        CFURLRef appUrl = (__bridge CFURLRef)[[NSBundle mainBundle] bundleURL];
        LSSharedFileListItemRef itemRef = LSSharedFileListInsertItemURL(loginItemsRef, kLSSharedFileListItemLast, NULL,
                                                                        NULL, appUrl, NULL, NULL);
        if (itemRef) CFRelease(itemRef);
    } else {
        LSSharedFileListItemRef loginItem = [self loginItem];
        
        LSSharedFileListItemRemove(loginItemsRef, loginItem);
        if (loginItem != nil) CFRelease(loginItem);
    }
    
    if (loginItemsRef) CFRelease(loginItemsRef);
}

#pragma mark Private

- (LSSharedFileListItemRef)loginItem
{
    NSURL *bundleURL = [[NSBundle mainBundle] bundleURL];

    LSSharedFileListRef loginItemsRef = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    
    if (!loginItemsRef) {
        return NULL;
    }

    NSArray *loginItems = CFBridgingRelease(LSSharedFileListCopySnapshot(loginItemsRef, nil));
    
    LSSharedFileListItemRef result = NULL;
    
    for (id item in loginItems) {
        LSSharedFileListItemRef itemRef = (__bridge LSSharedFileListItemRef)item;
        CFURLRef itemURLRef;

        if (LSSharedFileListItemResolve(itemRef, 0, &itemURLRef, NULL) == noErr) {
            NSURL *itemURL = (__bridge NSURL *)itemURLRef;

            if ([itemURL isEqual:bundleURL]) {
                result = itemRef;
                break;
            }
        }
    }

    if (result != nil) {
        CFRetain(result);
    }
    
    CFRelease(loginItemsRef);
    
    return result;
}

@end