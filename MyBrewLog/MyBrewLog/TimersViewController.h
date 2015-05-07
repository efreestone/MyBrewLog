// Elijah Freestone
// My Brew Log V1.0
// May 7th, 2015

//
//  TimersViewController.h
//  MyBrewLog
//
//  Created by Elijah Freestone on 5/7/15.
//  Copyright (c) 2015 Elijah Freestone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>

@interface TimersViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *timerOneLabel;
@property (strong, nonatomic) IBOutlet UILabel *oneDescriptionLabel;
@property (strong, nonatomic) IBOutlet UILabel *timerTwoLabel;
@property (strong, nonatomic) IBOutlet UILabel *twoDescriptionLabel;

@property (strong, nonatomic) IBOutlet UIButton *onePauseButton;
@property (strong, nonatomic) IBOutlet UIButton *oneCancelButton;
@property (strong, nonatomic) IBOutlet UIButton *twoPauseButton;
@property (strong, nonatomic) IBOutlet UIButton *twoCancelButton;

@property (strong, nonatomic) IBOutlet UIView *oneView;
@property (strong, nonatomic) IBOutlet UIView *twoView;

@property (strong, nonatomic) NSTimer *firstTimer;
@property (strong, nonatomic) NSTimer *secondTimer;
@property (strong, nonatomic) NSDate *timerDate;
@property (strong, nonatomic) NSDate *timerDateTwo;
@property (nonatomic) NSInteger countdownSeconds;
@property (nonatomic) NSInteger countdownSecondsOne;
@property (nonatomic) NSInteger countdownSecondsTwo;
@property (strong, nonatomic) AVAudioPlayer *alarmPlayer;

@property (nonatomic) AppDelegate *appDelegate;

@property (strong, nonatomic) NSString *oneDescription;
@property (strong, nonatomic) NSString *twoDescription;

-(void)startTimerFromDetails:(NSInteger)time withDetails:(NSString *)details;
-(void)startLocalNotification:(NSDate *)fire withDescription:(NSString *)description;
-(void)timerPicked:(NSString *)formattedTime;

@end
