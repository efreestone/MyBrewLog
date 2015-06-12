// Elijah Freestone
// My Brew Log V1.0
// May 7th, 2015

//
//  CustomTimerPickerDelegate.m
//  MyBrewLog
//
//  Created by Elijah Freestone on 5/7/15.
//  Copyright (c) 2015 Elijah Freestone. All rights reserved.
//

#import "CustomTimerPickerDelegate.h"

@implementation CustomTimerPickerDelegate {
    NSString *monthString;
    NSString *weekString;
    NSString *dayString;
    NSString *formattedTime;
}

- (id)init {
    if (self = [super init]) {
        //Init arrays and fill
        monthArray = [[NSMutableArray alloc] init];
        weekArray = [[NSMutableArray alloc] init];
        dayArray = [[NSMutableArray alloc] init];
        
        for(int i = 0; i < 13; i++) {
            NSString *stringVal = [NSString stringWithFormat:@"%d", i];
            //Create array with 12 months
            if (i < 13)
            {
                [monthArray addObject:stringVal];
            }
            //Create array with 4 weeks
            if (i < 5) {
                [weekArray addObject:stringVal];
            }
            //Create array with 7 days
            if (i < 8) {
                [dayArray addObject:stringVal];
            }
        }
        
        //Set strings to defaults
        monthString = @"0";
        weekString = @"0";
        dayString = @"0";
    }
    return self;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 6;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    // Returns
    switch (component) {
        case 0:
            return [monthArray count];
        case 1:
            return 1;
        case 2:
            return [weekArray count];
        case 3:
            return 1;
        case 4:
            return [dayArray count];
        case 5:
            return 1;
        default:
            break;
    }
    return 0;
}

// returns width of column and height of row for each component.
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    switch (component) {
        case 0:
            return 35.0f;
        case 1:
            return 50.0f;
        case 2:
            return 35.0f;
        case 3:
            return 50.0f;
        case 4:
            return 40.0f;
        case 5:
            return 55.0f;
        default:break;
    }
    return 0;
}

//Set title for component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    [pickerView sizeToFit];
    switch (component) {
        case 0:
            return monthArray[row];
        case 1:
            return @"-M-";
        case 2:
            return weekArray[row];
        case 3:
            return @"-W-";
        case 4:
            return dayArray[row];
        case 5:
            return @"-D-";
        default:
            break;
    }
    return nil;
}

//On done set default i needed and pass time back to New Recipe
- (void)actionSheetPickerDidSucceed:(AbstractActionSheetPicker *)actionSheetPicker origin:(id)origin {
    NSString *fullTimer;
    //Get numbers from string
    NSString *numberString = [NSString stringWithFormat:@"%@%@%@", monthString, weekString, dayString];
    NSLog(@"number string = %@", numberString);
    //Check if picker was selected, set default to 1 if not.
    if ([numberString isEqualToString:@"000"]) {
        fullTimer = @"0 Months, 0 Weeks, 1 Days";
    } else {
        fullTimer = formattedTime;
    }
    
    if (self.myRecipeVC != nil) {
        NSLog(@"Timer delegate MyRecipe");
        //Call method on NewRecipe with formatted quantity passed
        [self.myRecipeVC timerPicked:fullTimer];
    }
    
    if (self.timersVC != nil) {
        NSLog(@"Timer delegate Timer");
        //Call method on Timer with formatted quantity passed
        [self.timersVC timerPicked:fullTimer];
    }
    
    //self.timersVC.countdownSeconds
}

//Grab selections
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSLog(@"Row %li selected in component %li", (long)row, (long)component);
    
    //Grab inputs for each component. Using if statements instead of case due to out of range crash selecting numbers. This is most efficient fix while that still allows any selectiong order for each component.
    if (component == 0) {
        monthString = monthArray[row];
    }
    if (component == 2) {
        weekString = weekArray[row];
    }
    if (component == 4) {
        dayString = dayArray[row];
    }
    
    formattedTime = [NSString stringWithFormat:@"%@ Months, %@ Weeks, %@ Days", monthString, weekString, dayString];
    NSLog(@"formatted # = %@", formattedTime);
    
}

@end
