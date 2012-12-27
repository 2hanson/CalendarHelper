//
//  CalendarHelper.m
//
//  Created by hanson on 12/1/12.
//  Copyright (c) 2012 com. All rights reserved.
//

#import "CalendarHelper.h"
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

@implementation CalendarHelper

void (^RemoveEventBlock)(EKEventStore* eventStore, NSString* eventId) = ^(EKEventStore* eventStore, NSString* eventId)
{
    EKEvent * event = [eventStore eventWithIdentifier:eventId];
    NSError *err;
    if ([eventStore removeEvent:event span:EKSpanThisEvent error:&err] == NO)
    {
        NSLog(@"event cannot be removed!");
    }
};

void (^AddEventBlock)(EKEventStore* eventStore, NSString* agendaID, NSString* title, NSString* location, NSString* remark, NSDate *startDate, NSDate *endDate) = ^(EKEventStore* eventStore, NSString* agendaID, NSString* title, NSString* location, NSString* remark, NSDate *startDate, NSDate *endDate)
{
    NSInteger remindTime = 60*10;

    // Create a new event
    EKEvent *newEvent  = [EKEvent eventWithEventStore:eventStore];
    // Set properties of the new event object
    newEvent.title     = title;
    newEvent.location = location;
    newEvent.notes = remark;
    newEvent.startDate = startDate;
    newEvent.endDate   = endDate;
    newEvent.allDay = NO;
    //
    [newEvent addAlarm:[EKAlarm alarmWithAbsoluteDate:[NSDate dateWithTimeInterval:-remindTime sinceDate:newEvent.startDate]]];
    // set event's calendar to the default calendar
    [newEvent setCalendar:[eventStore defaultCalendarForNewEvents]];
    // Create an NSError pointer
    NSError *err;
    // Save the event
    [eventStore saveEvent:newEvent span:EKSpanThisEvent error:&err];
    
    [[NSUserDefaults standardUserDefaults] setObject:newEvent.eventIdentifier forKey:agendaID];
    //[[NSUserDefaults standardUserDefaults] synchronize];
};


+(void) AddDateEventIntoDefaultCalendar:(NSString *)agendaID withStartDateStr:(NSString *)startDateStr withEndTateStr:(NSString *)endDateStr withTitle:(NSString *)title withLocation:(NSString *)location withRemark:(NSString *)remark;
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *startDate = [dateFormat dateFromString:startDateStr];
    NSDate *endDate = [dateFormat dateFromString:endDateStr];
    
    // Get the event store object
    EKEventStore *eventStore = [[EKEventStore alloc] init];
   
    //check is ios6's api
    if ([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)])
    {
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error)
         {
             // handle access here
             if (granted == YES)
             {
                 AddEventBlock(eventStore, agendaID, title, location, remark, startDate, endDate);
             }
             else
             {
                 NSLog(@"Not granted!");
             }
         }];
    }
    else//ios 5
    {
        AddEventBlock(eventStore, agendaID, title, location, remark, startDate, endDate);
    }
}

+(void) RemoveDateEventFromDefaultCalendar:(NSString *)agendaID
{
    NSString* eventId = [[NSUserDefaults standardUserDefaults] objectForKey:agendaID];
    if (eventId == nil)
    {
        NSLog(@"remove failed, no such agenda!");
    }
    EKEventStore* eventStore = [[EKEventStore alloc] init];
    
    //check is ios6's api
    if ([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)])
    {
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error)
         {
             // handle access here
             if (granted == YES)
             {
                 RemoveEventBlock(eventStore, eventId);
             }
             else
             {
                 NSLog(@"Not granted!");
             }
         }];
    }
    else//ios 5
    {
        RemoveEventBlock(eventStore, eventId);
    }
}

@end
