//
//  CalendarHelper.h
//
//  Created by hanson on 12/1/12.
//  Copyright (c) 2012 com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalendarHelper : NSObject

+(void)AddDateEventIntoDefaultCalendar:(NSString *)agendaID withStartDateStr:(NSString *)startDateStr withEndTateStr:(NSString *)endDateStr withTitle:(NSString *)title withLocation:(NSString *)location withRemark:(NSString *)remark;

+(void)RemoveDateEventFromDefaultCalendar:(NSString *)agendaID;

@end
