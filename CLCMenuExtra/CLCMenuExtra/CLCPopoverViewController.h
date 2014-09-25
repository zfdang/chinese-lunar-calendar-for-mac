//
//  CLCPopoverViewController.h
//  chinese lunar calendar
//
//  Created by Zhengfa DANG on 9/25/14.
//  Copyright (c) 2014 Zhengfa. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CLCPopoverViewController : NSViewController
{
    NSPopover *popover;
}

@property (retain) NSPopover *popover;

- (IBAction)dismissPopover:(id)sender;

@end
