//
//  UpdateWindowController.h
//  chinese lunar calendar
//
//  Created by Zhengfa DANG on 2015-2-28.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class WebView;

@interface UpdateWindowController : NSWindowController
@property (weak) IBOutlet NSProgressIndicator *progressBar1;
@property (weak) IBOutlet NSProgressIndicator *progressBar2;

@property (weak) IBOutlet NSTextField *remoteVersion;
@property (weak) IBOutlet NSTextField *localVersion;
@property (weak) IBOutlet NSTextField *txtHoliday;

@property (weak) IBOutlet NSButton *updateButton;
- (IBAction)update:(id)sender;
@property (weak) IBOutlet NSButton *closeButton;
- (IBAction)close:(id)sender;

@property (weak) WebView *webView;

@end
