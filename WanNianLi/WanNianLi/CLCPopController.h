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
@property (weak) IBOutlet NSButton *menuButton;

@property (strong) IBOutlet NSMenu *aboutMenu;
@property (weak) IBOutlet NSMenuItem *calendarTopMenuItem;
@property (weak) IBOutlet NSMenuItem *autoStartMenuItem;


- (IBAction)toggleCalendarTop:(id)sender;
- (IBAction)toggleAutoStart:(id)sender;

- (IBAction)showMenu:(id)sender;
- (IBAction)showHelp:(id)sender;
- (IBAction)showVersion:(id)sender;
- (IBAction)contactAuthor:(id)sender;
- (IBAction)updateHolidays:(id)sender;
- (IBAction)quitApp:(id)sender;

@end
