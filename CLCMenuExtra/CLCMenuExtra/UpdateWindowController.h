//
//  UpdateWindowController.h
//  chinese lunar calendar
//
//  Created by Zhengfa DANG on 2015-2-28.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface UpdateWindowController : NSWindowController
@property (weak) IBOutlet NSProgressIndicator *progressBar;
@property (weak) IBOutlet NSTextField *remoteVersion;
@property (weak) IBOutlet NSTextField *localVersion;
@property (weak) IBOutlet NSButton *updateButton;
- (IBAction)update:(id)sender;

@end
