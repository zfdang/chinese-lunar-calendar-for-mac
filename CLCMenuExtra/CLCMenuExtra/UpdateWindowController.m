//
//  UpdateWindowController.m
//  chinese lunar calendar
//
//  Created by Zhengfa DANG on 2015-2-28.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import "UpdateWindowController.h"
#import "AFURLSessionManager.h"

@interface UpdateWindowController ()
@property (strong) NSString *appSupportDir;
- (NSString*) readVersion:(NSString*) file;
@end

@implementation UpdateWindowController

- (NSString*) readVersion:(NSString*) file{
    NSFileHandle *vFile = [NSFileHandle fileHandleForReadingAtPath:[self.appSupportDir stringByAppendingPathComponent:file]];
    if (vFile != nil){
        NSString *data = [[NSString alloc] initWithData:[vFile readDataToEndOfFile] encoding:NSUTF8StringEncoding];
        [vFile closeFile];
    }

    return @"2015-03-01";
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
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
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURL *URL = [NSURL URLWithString:@"https://raw.githubusercontent.com/zfdang/chinese-lunar-calendar-for-mac/master/CLCMenuExtra/CLCMenuExtra/Resources/vendors/holidays.js"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];

    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        // download file URL
        NSString *downloadFile = [self.appSupportDir stringByAppendingPathComponent:@"holidays.new.js"];
//        NSLog(@"destination file: %@", downloadFile);
        return [NSURL fileURLWithPath:downloadFile];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        // complete handler
//        NSLog(@"File downloaded to: %@", filePath);

        // stop progressbar1 animation
        [self.progressBar1 stopAnimation:nil];
        [self.progressBar1 setHidden:YES];

        // read remote version
        self.remoteVersion.stringValue = [self readVersion:@"holidays.new.js"];
        [self.remoteVersion setHidden:NO];

        if([self.remoteVersion.stringValue compare:self.localVersion.stringValue] == NSOrderedSame ){
            // two versions are the same
            [self.closeButton setHidden:NO];
        } else {
            // two versions are different
            [self.updateButton setHidden:NO];
        }
    }];

    [downloadTask resume];
}

- (IBAction)update:(id)sender {
    self.localVersion.stringValue = @"";

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

    // sleep
    [NSThread sleepForTimeInterval:1];

    // stop progressbar2 animation
    [self.progressBar2 stopAnimation:nil];
    [self.progressBar2 setHidden:YES];

    // update localversion and show it again
    self.localVersion.stringValue = [self readVersion:@"holidays.js"];

    // switch buttons
    [self.updateButton setHidden:YES];
    [self.closeButton setHidden:NO];
}
- (IBAction)close:(id)sender {
    [self close];
}
@end
