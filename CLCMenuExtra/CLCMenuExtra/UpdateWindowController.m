//
//  UpdateWindowController.m
//  chinese lunar calendar
//
//  Created by Zhengfa DANG on 2015-2-28.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import "UpdateWindowController.h"
#import "AFURLSessionManager.h"
#import "NSAttributedString+Hyperlink.h"
#import <WebKit/WebKit.h>

@interface UpdateWindowController ()

@property (strong) NSString *appSupportDir;
- (NSString*) readVersion:(NSString*) file;
- (void) update_delayed;

@end

@implementation UpdateWindowController

@synthesize webView;

- (NSString*) readVersion:(NSString*) file {
    NSError *error;
    NSString* fileContents = [NSString stringWithContentsOfFile:[self.appSupportDir stringByAppendingPathComponent:file]
                                                       encoding:NSUTF8StringEncoding
                                                          error:&error];
    if(fileContents != nil) {
        // separate by new line
        NSArray* allLinedStrings = [fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];

        // find first line
        if([allLinedStrings count] > 0){
            NSString* firstLine = [allLinedStrings objectAtIndex:0];
            NSString* version = [[[firstLine stringByReplacingOccurrencesOfString:@"/" withString:@""]
                                  stringByReplacingOccurrencesOfString:@"Version:" withString:@""]
                                 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//            NSLog(@"%@: version = [%@]", file, version);
            return version;
        }
    } else {
        NSLog(@"Failed to read file: %@", [error localizedDescription]);
    }

    return @"0";
}

- (void)windowDidLoad {
    [super windowDidLoad];

    // add hyperlink to textview
    [self.txtHoliday setAllowsEditingTextAttributes: YES];
    [self.txtHoliday setSelectable: YES];
    NSURL* url = [NSURL URLWithString:@"https://raw.githubusercontent.com/zfdang/chinese-lunar-calendar-for-mac/master/CLCMenuExtra/CLCMenuExtra/Resources/vendors/holidays.js"];
    NSMutableAttributedString* string = [[NSMutableAttributedString alloc] init];
    [string appendAttributedString: [NSAttributedString hyperlinkFromString:@"holidays.js" withURL:url]];
    [self.txtHoliday setAttributedStringValue: string];
    
    // 0. initialize appSupportDir
    // find app support directory: "~/Library/Application Support/com.zfdang.calendar"
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    self.appSupportDir = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"com.zfdang.calendar"];

    // 1. start progressbar1 animation
    [self.progressBar1 setIndeterminate:YES];
    [self.progressBar1 setUsesThreadedAnimation:YES];
    [self.progressBar1 startAnimation:nil];

    // 2. read local verison from holidays.js, and update the dialog
    self.localVersion.stringValue = [self readVersion:@"holidays.js"];

    // 3. start async task to download holidays.js, and save it as holidays.new.js
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURL *URL = [NSURL URLWithString:@"https://raw.githubusercontent.com/zfdang/chinese-lunar-calendar-for-mac/master/CLCMenuExtra/CLCMenuExtra/Resources/vendors/holidays.js"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];

    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        // download file URL
        NSString *downloadFile = [self.appSupportDir stringByAppendingPathComponent:@"holidays.new.js"];
        NSFileManager *fm = [NSFileManager defaultManager];
        if ([fm isReadableFileAtPath:downloadFile] ) {
            [fm removeItemAtPath:downloadFile error:nil];
        }
        return [NSURL fileURLWithPath:downloadFile];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            // complete handler
            if(error != nil) {
                NSLog(@"Failed to download file: %@", [error localizedDescription]);
            } else {
                NSLog(@"File downloaded to: %@", filePath);
            }

            // stop progressbar1 animation
            [self.progressBar1 stopAnimation:nil];
            [self.progressBar1 setHidden:YES];

            // read remote version
            self.remoteVersion.stringValue = [self readVersion:@"holidays.new.js"];
            [self.remoteVersion setHidden:NO];

            // enable buttons
            if([self.remoteVersion.stringValue compare:self.localVersion.stringValue options:NSNumericSearch] == NSOrderedDescending ){
                // remote version is bigger than local version
                [self.updateButton setHidden:NO];
            } else {
                [self.closeButton setHidden:NO];
            }
    }];

    [downloadTask resume];
}

- (IBAction)update:(id)sender {
    [self.localVersion setHidden:YES];

    // 1. start progressbar2 animation
    [self.progressBar2 setHidden:NO];
    [self.progressBar2 setIndeterminate:YES];
    [self.progressBar2 setUsesThreadedAnimation:YES];
    [self.progressBar2 startAnimation:nil];

    // mv holidays.new.js holidays.js
    NSError *error;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *downloadFile = [self.appSupportDir stringByAppendingPathComponent:@"holidays.new.js"];
    NSString *targetFile = [self.appSupportDir stringByAppendingPathComponent:@"holidays.js"];
    if( [fm removeItemAtPath:targetFile error:&error] != YES){
        NSLog(@"Unable to remove file: %@", [error localizedDescription]);
    }
    if ([fm moveItemAtPath:downloadFile toPath:targetFile error:&error] != YES){
        NSLog(@"Unable to move file: %@", [error localizedDescription]);
    }

    // sleep 1s, then execute the rest part; to make this action feels better
    [self performSelector:@selector(update_delayed) withObject:nil afterDelay:1.0f];
}

- (void) update_delayed {
    // stop progressbar2 animation
    [self.progressBar2 stopAnimation:nil];
    [self.progressBar2 setHidden:YES];

    // update localversion and show it again
    self.localVersion.stringValue = [self readVersion:@"holidays.js"];
    [self.localVersion setHidden:NO];

    // switch buttons
    [self.updateButton setHidden:YES];
    [self.closeButton setHidden:NO];

    // reload webview
    [self.webView reloadFromOrigin:nil];
}

- (IBAction)close:(id)sender {
    [self close];
}
@end
