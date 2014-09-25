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

@synthesize webView;

- (void)viewDidLoad {
//    [super viewDidLoad];
    // Do view setup here.
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}


- (IBAction)goSource:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/zfdang/chinese-lunar-calendar-for-mac"]];
}


@end
