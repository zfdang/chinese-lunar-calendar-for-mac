//
//  CLCCalendar.h
//  chinese lunar calendar
//
//  Created by Zhengfa DANG on 9/25/14.
//  Copyright (c) 2014 Zhengfa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CLCCalendar : NSObject

- (int) getDay:(NSDate *)date;
- (NSString*) getChineseDay:(NSDate *)date;

@end
