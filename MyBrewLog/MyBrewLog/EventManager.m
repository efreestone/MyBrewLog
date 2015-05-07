// Elijah Freestone
// My Brew Log V1.0
// May 7th, 2015

//
//  EventManager.m
//  MyBrewLog
//
//  Created by Elijah Freestone on 5/7/15.
//  Copyright (c) 2015 Elijah Freestone. All rights reserved.
//

#import "EventManager.h"

@implementation EventManager {
    NSString *accessKey;
}

-(instancetype)init {
    self = [super init];
    
    accessKey = @"eventsAccessGranted";
    
    if (self) {
        self.eventStore = [[EKEventStore alloc] init];
    }
    
    NSString *recipeTitle = @"My Brew Log Calendar";
    
    //Grab user defaults to check if access was granted
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //Check if access has been granted
    if ([userDefaults valueForKey:accessKey] != nil) {
        // The value exists, so assign it to the property.
        self.accessGranted = [[userDefaults valueForKey:accessKey] intValue];
        //Check if calendar exists, create if it doesn't
        if (![self checkForCalendar:recipeTitle]) {
            NSLog(@"Calendar does NOT exist");
            [self createCalendar:recipeTitle];
        } else {
            NSLog(@"Calendar exists");
        }
    } else {
        // Set the default value.
        self.accessGranted = NO;
    }
    return self;
}

//Override setter for accessGranted
-(void)setAccessGranted:(BOOL)accessGranted {
    //Grab and set auto synthesized BOOL
    _accessGranted = accessGranted;

    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:accessGranted] forKey:accessKey];
}

-(BOOL)checkForCalendar:(NSString *)calendarName {
    //get an array of the user's calendar using your instance of the eventStore
    NSArray *calendarArray = [self.eventStore calendarsForEntityType:EKEntityTypeEvent];
    
    EKCalendar *calendar;
    
    for (int i = 0; i < [calendarArray count]; i++) {
        calendar = [calendarArray objectAtIndex:i];
        NSString *calTitle = [calendar title];
        
        //if the calendar is found, return YES
        if ([calTitle isEqualToString:calendarName]) {
            //Set calendar for app to use
            self.recipeCalendar = calendar;
            return YES;
        }
    }
    // Calendar name was not found, return NO;
    return NO;
}

//Create calendar on device. Can't find the root of the issue but calendar doesn't show up on my ipad if I don't have icloud calendar sync turned on
-(void)createCalendar:(NSString *)title {
    self.recipeCalendar = [EKCalendar calendarForEntityType:EKEntityTypeEvent eventStore:self.eventStore];
    self.recipeCalendar.title = title;
    
    // Find the proper source type value.
    for (int i = 0; i < self.eventStore.sources.count; i++) {
        EKSource *source = (EKSource *)[self.eventStore.sources objectAtIndex:i];
        EKSourceType currentSourceType = source.sourceType;
        
        if (currentSourceType == EKSourceTypeLocal) {
            self.recipeCalendar.source = source;
            break;
        }
    }
    
    NSError *error;
    [self.eventStore saveCalendar:self.recipeCalendar commit:YES error:&error];
    
    // If no error occurs then turn the editing mode off, store the new calendar identifier and reload the calendars.
    if (!error) {
        NSLog(@"Calendar created successfully");
    } else {
        //Error, log description
        NSLog(@"%@", [error localizedDescription]);
    }
}

@end
