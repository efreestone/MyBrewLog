// Elijah Freestone
// My Brew Log V1.0
// May 7th, 2015

//
//  EventManager.h
//  MyBrewLog
//
//  Created by Elijah Freestone on 5/7/15.
//  Copyright (c) 2015 Elijah Freestone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

@interface EventManager : NSObject

@property (strong, nonatomic) EKEventStore *eventStore;
@property (strong, nonatomic) EKCalendar *recipeCalendar;
@property (nonatomic) BOOL accessGranted;

@end
