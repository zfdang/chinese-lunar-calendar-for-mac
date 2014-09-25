//
//  CLCPopController.m
//  chinese lunar calendar
//
//  Created by Zhengfa DANG on 9/25/14.
//  Copyright (c) 2014 Zhengfa. All rights reserved.
//

#import "CLCPopController.h"
#import <WebKit/WebKit.h>


@interface CLCPopController ()

@end

@implementation CLCPopController

@synthesize  webview;

- (void)viewDidLoad {
//    [super viewDidLoad];
    // Do view setup here.
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        //刷新网页
//        if (![[self popover] isShown])
        {
            NSString *resourcesPath = [[NSBundle mainBundle] resourcePath];
            NSString *htmlPath = [resourcesPath stringByAppendingString:@"/calendarHTML/test.html"];
            [[self.webview mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:htmlPath]]];
            [self.webview setDrawsBackground:NO];
        }

    }
    
    return self;
}


@end
