// Elijah Freestone
// My Brew Log V1.0
// May 7th, 2015

//
//  CustomTimerPickerDelegate.h
//  MyBrewLog
//
//  Created by Elijah Freestone on 5/7/15.
//  Copyright (c) 2015 Elijah Freestone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActionSheetCustomPickerDelegate.h"
#import "NewRecipeViewController.h"
#import "TimersViewController.h"

@interface CustomTimerPickerDelegate : NSObject <ActionSheetCustomPickerDelegate> {
    NSMutableArray *monthArray;
    NSMutableArray *weekArray;
    NSMutableArray *dayArray;
    NSMutableArray *hourArray;
    NSMutableArray *minuteArray;
    
}

@property (nonatomic, assign) NSInteger monthDigits;
@property (nonatomic, assign) NSInteger weekDigits;
@property (nonatomic, assign) NSInteger dayDigits;
@property (nonatomic, strong) NewRecipeViewController *myRecipeVC;
@property (nonatomic, strong) TimersViewController *timersVC;

@end
