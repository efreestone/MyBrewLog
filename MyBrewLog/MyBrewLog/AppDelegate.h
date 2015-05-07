// Elijah Freestone
// My Brew Log V1.0
// May 7th, 2015

//
//  AppDelegate.h
//  MyBrewLog
//
//  Created by Elijah Freestone on 5/7/15.
//  Copyright (c) 2015 Elijah Freestone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventManager.h"
//#import "TimersViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) EventManager *eventManager;

@end

