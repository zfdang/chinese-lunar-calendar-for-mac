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
        [self.goSourceButton setRefusesFirstResponder:TRUE];
    }
    
    return self;
}


- (IBAction)goSource:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://calendar.zfdang.com"]];
}

- (void)keyDown:(NSEvent *)theEvent {
//    NSLog(@"%d", [theEvent keyCode]);
    switch ([theEvent keyCode]) {
        case 123:  // left arrow, previous year
            [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName(\"BUTTON\")[0].click(); "];
            break;
        case 124:  // right arrow, next year
            [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName(\"BUTTON\")[3].click(); "];
            break;
        case 125:  // down arrow, next month
            [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName(\"BUTTON\")[2].click(); "];
            break;
        case 126:  // up arrow, previous month
            [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName(\"BUTTON\")[1].click(); "];
            break;
        case 36:  // return, back to today
            [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName(\"BUTTON\")[4].click(); "];
            break;

        default:
            break;
    }
}

@end
