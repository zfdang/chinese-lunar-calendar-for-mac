//
//  CLCCalendar.m
//  chinese lunar calendar
//
//  Created by Zhengfa DANG on 9/25/14.
//  Copyright (c) 2014 Zhengfa. All rights reserved.
//

#import "CLCCalendar.h"

@interface CLCCalendar()
{
}

@end

@implementation CLCCalendar

- (id) init
{
    if(self = [super init])
    {
    }
    return (self);
}



- (long) getDay: (NSDate *)_date
{
    NSDate *date = nil;
    if(_date)
        date = _date;
    else
        date = [NSDate date];

    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *weekdayComponents =
    [gregorian components:(NSDayCalendarUnit | NSWeekdayCalendarUnit) fromDate:date];
    NSInteger day = [weekdayComponents day];

    return day;
}

@end
