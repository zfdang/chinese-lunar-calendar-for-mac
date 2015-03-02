//
//  CLCPopController.h
//  chinese lunar calendar
//
//  Created by Zhengfa DANG on 9/25/14.
//  Copyright (c) 2014 Zhengfa. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class WebView;

@interface CLCPopController : NSViewController

@property (weak) IBOutlet WebView *webView;
- (IBAction)showMenu:(id)sender;
@property (weak) IBOutlet NSButton *showAboutMenu;
@property (strong) IBOutlet NSMenu *aboutMenu;
- (IBAction)showHelp:(id)sender;
- (IBAction)showVersion:(id)sender;
- (IBAction)contactAuthor:(id)sender;
- (IBAction)updateHolidays:(id)sender;

@end
