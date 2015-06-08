// Elijah Freestone
// My Brew Log V1.0
// May 7th, 2015

//
//  TimersViewController.m
//  MyBrewLog
//
//  Created by Elijah Freestone on 5/7/15.
//  Copyright (c) 2015 Elijah Freestone. All rights reserved.
//

#import "TimersViewController.h"
#import "AppDelegate.h"
#import "CustomTimerPickerDelegate.h"
#import "ActionSheetCustomPicker.h"
#import "ActionSheetDatePicker.h"
#import <EventKitUI/EventKitUI.h>

@interface TimersViewController () <UIActionSheetDelegate> {
    int hoursInt;
    int minutesInt;
    int secondsInt;
    
    NSString *timerString;
    NSDate *pauseStart, *previousFireDate;
    NSDate *pauseStartTwo, *previousFireDateTwo;
    BOOL timerPaused, timerPausedTwo;
    
    EKCalendar *recipeCalendar;
    id buttonSender;
    NSUserDefaults *userDefaults;
}

@end

@implementation TimersViewController

//Synthesize for getters/setters
@synthesize oneDescriptionLabel, timerOneLabel, onePauseButton, oneCancelButton, oneView, oneDescription;
@synthesize twoDescriptionLabel, timerTwoLabel, twoPauseButton, twoCancelButton, twoView, twoDescription;
@synthesize firstTimer, secondTimer, timerDate, timerDateTwo, countdownSeconds, countdownSecondsOne, countdownSecondsTwo;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    userDefaults = [NSUserDefaults standardUserDefaults];
    
    //Grab app delegate and set calendar
    self.appDelegate = [[UIApplication sharedApplication] delegate];
    recipeCalendar = self.appDelegate.eventManager.recipeCalendar;
    
    //Set boarders for timer views to match textviews and textfields elsewhere
    [[self.oneView layer] setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [[self.oneView layer] setBorderWidth:0.5];
    [[self.oneView layer] setCornerRadius:7.5];
    
    [[self.twoView layer] setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [[self.twoView layer] setBorderWidth:0.5];
    [[self.twoView layer] setCornerRadius:7.5];
    
    //Set descriptions if they exist
    if (oneDescription.length != 0) {
        oneDescriptionLabel.text = oneDescription;
    }
    if (twoDescription) {
        twoDescriptionLabel.text = twoDescription;
    }
    
    //Set pause button titles if no timers active
    if (firstTimer == nil) {
        [onePauseButton setTitle:@"Start" forState:UIControlStateNormal];
    }
    if (secondTimer == nil) {
        [twoPauseButton setTitle:@"Start" forState:UIControlStateNormal];
    }
    
    //Check permissions for Push
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeSound categories:nil]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Start timer form details, also called when new timer button is used
-(void)startTimerFromDetails:(NSInteger)time withDetails:(NSString *)description {
    NSLog(@"Timer seconds = %ld", (long)time);
    countdownSeconds = time;
    //If timer is under 24 hours
    if (time <= 86340) {
        //Check if first timer is being used
        if (firstTimer == nil) {
            countdownSecondsOne = time;
            firstTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(runTimer) userInfo:nil repeats:YES];
            
            oneDescription = description;
            
            oneDescriptionLabel.text = description;
            
            timerDate = [NSDate date];
            timerDate = [timerDate dateByAddingTimeInterval:countdownSecondsOne];
            //[self startLocalNotification:timerDate];
        } else if (secondTimer == nil) {
        //First timer in use, check timer two
            countdownSecondsTwo = time;
            //Second timer
            NSLog(@"Second timer");
            secondTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(runTimerTwo) userInfo:nil repeats:YES];
            
            twoDescription = description;
            
            twoDescriptionLabel.text = description;
            
            timerDateTwo = [NSDate date];
            timerDateTwo = [timerDateTwo dateByAddingTimeInterval:countdownSecondsTwo];
        } else {
        //Both timers in use, alert user
            NSLog(@"No timers available");
            [self noTimerAvailableAlert];
        }
    } else {
        NSLog(@"Over 23:59");
        NSDate *calDate = [NSDate date];
        calDate = [calDate dateByAddingTimeInterval:countdownSeconds];
        [self createCalendarEvent:calDate withTitle:description];
    }
}

//Run timer one
-(void)runTimer {
    countdownSecondsOne = countdownSecondsOne - 1;
    
    //Calculate hours/minutes/seconds from countdownSeconds
    secondsInt = countdownSecondsOne % 60;
    minutesInt = (countdownSecondsOne / 60) % 60;
    hoursInt = (countdownSecondsOne / 3600) % 24;
    
    if (hoursInt < 1) {
        timerString = [NSString stringWithFormat:@"%.2d:%.2d left", minutesInt, secondsInt];
    } else {
        if (hoursInt < 10) {
            timerString = [NSString stringWithFormat:@"%.1d:%.2d:%.2d left", hoursInt, minutesInt, secondsInt];
        } else {
            timerString = [NSString stringWithFormat:@"%.2d:%.2d:%.2d left", hoursInt, minutesInt, secondsInt];
        }
    }
    //Display current countdown time
    timerOneLabel.text = timerString;
    
    //Play sound and invalidate once time down to zero
    if (countdownSecondsOne == 0) {
        [firstTimer invalidate];
        firstTimer = nil;
        [self.alarmPlayer play];
        NSLog(@"Timer over");
        
        [userDefaults removeObjectForKey:@"fireDateOne"];
        [userDefaults removeObjectForKey:@"countdownOne"];
        [userDefaults removeObjectForKey:@"pauseStartOne"];
    }
}

//Run timer two
-(void)runTimerTwo {
    countdownSecondsTwo = countdownSecondsTwo - 1;
    
    //Calculate hours/minutes/seconds from countdownSeconds
    secondsInt = countdownSecondsTwo % 60;
    minutesInt = (countdownSecondsTwo / 60) % 60;
    hoursInt = (countdownSecondsTwo / 3600) % 24;
    
    if (hoursInt < 1) {
        timerString = [NSString stringWithFormat:@"%.2d:%.2d left", minutesInt, secondsInt];
    } else {
        if (hoursInt < 10) {
            timerString = [NSString stringWithFormat:@"%.1d:%.2d:%.2d left", hoursInt, minutesInt, secondsInt];
        } else {
            timerString = [NSString stringWithFormat:@"%.2d:%.2d:%.2d left", hoursInt, minutesInt, secondsInt];
        }
    }
    //Display currnet countdown time
    timerTwoLabel.text = timerString;
    
    //Play sound and invalidate once time down to zero
    if (countdownSecondsTwo == 0) {
        [secondTimer invalidate];
        secondTimer = nil;
        [self.alarmPlayer play];
        NSLog(@"Timer over");
        
        [userDefaults removeObjectForKey:@"fireDateTwo"];
        [userDefaults removeObjectForKey:@"countdownTwo"];
        [userDefaults removeObjectForKey:@"pauseStartTwo"];
    }
}

//Pause timer one. This and resume were originally shared for both timers but it caused some odd behaviour when pausing both. Not as ideal but I have simply duplicated these (and related variables) to avoid any issues or conflicts between the two
-(void)pauseTimer:(NSTimer *)timer {
    pauseStart = [NSDate date];
    previousFireDate = [timer fireDate];
    [timer setFireDate:[NSDate distantFuture]];
    timerPaused = YES;
    //onePauseButton = @"Restart";
}

//Pause two.
-(void)pauseTimerTwo:(NSTimer *)timer {
    pauseStartTwo = [NSDate date];
    previousFireDateTwo = [timer fireDate];
    [timer setFireDate:[NSDate distantFuture]];
    timerPausedTwo = YES;
    //onePauseButton = @"Restart";
}

//Resume timer one
-(void)resumeTimer:(NSTimer *)timer {
    float pauseTime = -1 * [pauseStart timeIntervalSinceNow];
    [timer setFireDate:[previousFireDate initWithTimeInterval:pauseTime sinceDate:previousFireDate]];
    timerPaused = NO;
}

//Resume timer two
-(void)resumeTimerTwo:(NSTimer *)timer {
    float pauseTime = -1 * [pauseStartTwo timeIntervalSinceNow];
    [timer setFireDate:[previousFireDateTwo initWithTimeInterval:pauseTime sinceDate:previousFireDateTwo]];
    timerPausedTwo = NO;
}

//Paused clicked for timer one
-(IBAction)pauseClicked:(id)sender {
    //Check if timer exists, allow user to create if it doesn't
    if (firstTimer == nil) {
        [self showTimerPicker:sender];
        [onePauseButton setTitle:@"Pause" forState:UIControlStateNormal];
    } else {
        if (!timerPaused) {
            [self pauseTimer:firstTimer];
            [onePauseButton setTitle:@"Start" forState:UIControlStateNormal];
        } else {
            [self resumeTimer:firstTimer];
            [onePauseButton setTitle:@"Pause" forState:UIControlStateNormal];
        }
    }
}

//Pause clicked for timer two
-(IBAction)pauseClickedTwo:(id)sender {
    //Check if timer exists, allow user to create if it doesn't
    if (secondTimer == nil) {
        [self showTimerPicker:sender];
        [twoPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
    } else {
        if (!timerPausedTwo) {
            [self pauseTimerTwo:secondTimer];
            [twoPauseButton setTitle:@"Start" forState:UIControlStateNormal];
        } else {
            [self resumeTimer:secondTimer];
            [twoPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
        }
    }
}

//Cancel clicked for timer one
-(IBAction)cancelClicked:(id)sender {
    [firstTimer invalidate];
    firstTimer = nil;
    timerOneLabel.text = @"00:00";
}

//Cancel clicked for timer two
-(IBAction)cancelClickedTwo:(id)sender {
    [secondTimer invalidate];
    secondTimer = nil;
    timerTwoLabel.text = @"00:00";
}

//Start local notification when app is backgrounded, this will notify the user only if they approved Push
-(void)startLocalNotification:(NSDate *)fire withDescription:(NSString *)description {
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = fire;
    localNotification.alertBody = [NSString stringWithFormat:@"Alert for %@", description];
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    NSLog(@"Local notifiaction started");
}

//Create calendar
-(void)createCalendarEvent:(NSDate *)eventDate withTitle:(NSString *)title {
    if (title.length == 0) {
        title = @"My Brew Log Event. No Title";
    }
    
    recipeCalendar = self.appDelegate.eventManager.recipeCalendar;
    
    //Create the event, set title and calendar
    EKEvent *recipeEvent = [EKEvent eventWithEventStore:self.appDelegate.eventManager.eventStore];
    recipeEvent.title = title;
    recipeEvent.calendar = self.appDelegate.eventManager.recipeCalendar;
    
    //Set start/end date, which is set to 1 hour
    NSDate *endDate = [eventDate dateByAddingTimeInterval:3600];
    recipeEvent.startDate = eventDate;
    recipeEvent.endDate = endDate;
    [recipeEvent addAlarm:[EKAlarm alarmWithAbsoluteDate:eventDate]];
    
    //Make sure calendar exists and save event if it does
    if (recipeCalendar != nil) {
        // Save and commit the event.
        NSError *error;
        if ([self.appDelegate.eventManager.eventStore saveEvent:recipeEvent span:EKSpanFutureEvents commit:YES error:&error]) {
            NSLog(@"Event saved successfully");
        } else {
            // An error occurred, so log the error description.
            NSLog(@"%@", [error localizedDescription]);
        }
    } else {
        //no calendar exists, alert user
        NSLog(@"Calendar doesn't exist");
        [self noCalendarAvailableAlert];
    }
}

#pragma new timer

//Show Timer Picker
-(IBAction)showTimerPicker:(id)sender {
    //Pass (id)sender to be used for launching ActionSheetPicker from reg action sheet
    buttonSender = sender;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Is timer over 24 hours?"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Yes", @"No", nil];
    //Set tag and show action sheet
    actionSheet.tag = 200;
    [actionSheet showInView:self.view];
}

//Show countdown picker. Triggered from selecting No to over 24 hour ActionSheet
-(void)showCountdownPicker:(id)sender {
    //Create picker and set to timer mode
    ActionSheetDatePicker *actionSheetPicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Under 24 hours"
                                                      datePickerMode:UIDatePickerModeCountDownTimer
                                                        selectedDate:nil
                                                           doneBlock:^(ActionSheetDatePicker *picker, id dateSelected, id origin) {
                                                               NSLog(@"dateSelected: %@", dateSelected);
                                                               [self under24Hours:picker.countDownDuration element:origin];
                                                           } cancelBlock:^(ActionSheetDatePicker *picker) {
                                                               NSLog(@"Cancel clicked");
                                                           } origin:sender];
    [(ActionSheetDatePicker *) actionSheetPicker setCountDownDuration:120];
    [actionSheetPicker showActionSheetPicker];
}

//Grab input countdown time
- (void)under24Hours:(double)selectedCountdownDuration element:(id)element {
    [self showTimerAlert];
    countdownSeconds = selectedCountdownDuration;
    NSLog(@"countdown %f", selectedCountdownDuration);
}

//Show custom picker. Triggered from selecting Yes to over 24 hour ActionSheet
-(void)showCustomTimePicker:(id)sender {
    //Init custom delegate
    CustomTimerPickerDelegate *timerDelegate = [[CustomTimerPickerDelegate alloc] init];
    NSNumber *comp0 = @0;
    NSNumber *comp1 = @0;
    NSNumber *comp2 = @0;
    NSNumber *comp3 = @0;
    NSNumber *comp4 = @0;
    NSNumber *comp5 = @0;
    //Set initial selections
    NSArray *initialSelections = @[comp0, comp1, comp2, comp3, comp4, comp5];
    
    ActionSheetCustomPicker *customPicker = [[ActionSheetCustomPicker alloc] initWithTitle:@"Select Time" delegate:timerDelegate showCancelButton:YES origin:sender initialSelections:initialSelections];
    
    timerDelegate.timersVC = self;
    [customPicker showActionSheetPicker];
}

//Timer picked (over 24) formats and adds ingredients to textview. Called from Timer Delegate
-(void)timerPicked:(NSString *)formattedTime {
    NSLog(@"NewRec: %@", formattedTime);
    
    NSArray *numbersArray = [formattedTime componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
    
    NSInteger monthsFromString = [numbersArray[0] intValue];
    NSInteger monthsInt = 0;
    NSInteger weeksFromString = [numbersArray[1] intValue];
    NSInteger weeksInt = 0;
    NSInteger daysFromString = [numbersArray[2] intValue];
    NSInteger daysInt = 0;
    
    if (monthsFromString != 00) {
        monthsInt = monthsFromString * 2592000;
        NSLog(@"Months in seconds = %ld", (long)monthsInt);
    }
    if (weeksFromString != 00) {
        weeksInt = weeksFromString * 604800;
    }
    if (daysFromString != 00) {
        daysInt = daysFromString * 86400;
    }
    
    countdownSeconds = monthsInt + weeksInt + daysInt;
    [self showTimerAlert];
}

//Grab action sheet actions via delegate method
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    //Over 24 hours (Yes clicked)
    if (buttonIndex == 0) {
        NSLog(@"index 0");
        
        [self showCustomTimePicker:buttonSender];
    //Under 24 hours (No clicked)
    } else if (buttonIndex == 1) {
        NSLog(@"index 1");
        if (firstTimer != nil && secondTimer != nil) {
            [self noTimerAvailableAlert];
        } else {
            [self showCountdownPicker:buttonSender];
        }
    //Cancel clicked
    } else {
        NSLog(@"Other index");
    }
}

//Method to create and show alert view with text input
-(void)showTimerAlert {
    NSString *alertString = @"Please enter a discription for the new timer. Over 24 hours will be calendar entries.";
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Start Timer"
                                                    message:alertString
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Start", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
} //showAlert close

//Grab text entered into alertview
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *description = [alertView textFieldAtIndex:0].text;
    if (buttonIndex == 1) {
        NSLog(@"index 1");
        if (description.length == 0) {
            description = @"No Description";
        }
        
        [self startTimerFromDetails:countdownSeconds withDetails:description];
        
        //timersViewController.oneView.hidden = NO;
    } else if (buttonIndex == 0) {
        NSLog(@"AlertView index = 0");
    } else {
        NSLog(@"AlertView index = %ld", (long)buttonIndex);
    }
}

//Method to create and show alert when both timers are in use
-(void)noTimerAvailableAlert {
    NSString *alertString = @"Sorry, only two timers can be active at one time.";
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Timer Available"
                                                    message:alertString
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
} //showAlert close

//Method to create and show alert when no calendar available. This should only be the case if user did not grant calendar access to the application
-(void)noCalendarAvailableAlert {
    NSString *alertString = @"Sorry, the calendar for My Brew Log does not exist on your device so the event was not created. Please approve calendar access if you would like to use this feature.";
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Calendar Available"
                                                    message:alertString
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
} //showAlert close

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
