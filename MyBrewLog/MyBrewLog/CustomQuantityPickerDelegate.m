// Elijah Freestone
// My Brew Log V1.0
// May 7th, 2015

//
//  CustomQuantityPickerDelegate.m
//  MyBrewLog
//
//  Created by Elijah Freestone on 5/7/15.
//  Copyright (c) 2015 Elijah Freestone. All rights reserved.
//

#import "CustomQuantityPickerDelegate.h"

@implementation CustomQuantityPickerDelegate {
    NSArray *measurementArray;
    NSArray *imperialMeasurementArray;
    NSArray *metricMeasurementArray;
    NSArray *ingredientArray;
    NSMutableArray *amountHundreds;
    NSMutableArray *amountTens;
    NSMutableArray *amountOnes;
    NSMutableArray *amountTenths;
    NSString *selectedHundreds;
    NSString *selectedTens;
    NSString *selectedOnes;
    NSString *selectedMeasurement;
    NSString *formattedQuantity;
    
    NSString *measurementKey;
}

//Init and build arrays
- (id)init {
    if (self = [super init]) {
        //Create default arrays
        //measurementArray = [NSArray arrayWithObjects:@"qt", @"cup", @"gal", @"oz", @"lbs", nil];
        measurementKey = @"isMetric";
        
        imperialMeasurementArray = [NSArray arrayWithObjects:@"teaspoon", @"tablespoon", @"cup", @"fluid oz", @"pint", @"ounce", @"pound", @"quart", @"gallon", nil];
        
        metricMeasurementArray = [NSArray arrayWithObjects:@"teaspoon", @"tablespoon", @"cup", @"milliliter", @"liter", @"gram", @"kilogram", nil];
        
        //Grab user defaults and check if measurement set to metric, setting array accordingly
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        if ([userDefaults valueForKey:measurementKey] != nil) {
            BOOL isMetric = [userDefaults boolForKey:measurementKey];
            if (!isMetric) {
                NSLog(@"NOT isMetric");
                measurementArray = [NSArray arrayWithArray:imperialMeasurementArray];
            } else {
                NSLog(@"isMetric");
                measurementArray = [NSArray arrayWithArray:metricMeasurementArray];
            }
        } else {
            NSLog(@"isMetric didn't exist, setting default to NO");
            [userDefaults setBool:NO forKey:measurementKey];
            [userDefaults synchronize];
            measurementArray = [NSArray arrayWithArray:imperialMeasurementArray];
        }
        
        amountHundreds = [[NSMutableArray alloc] init];
        amountTens = [[NSMutableArray alloc] init];
        amountOnes = [[NSMutableArray alloc] init];
        
        for(int i = 0; i < 10; i++) {
            NSString *stringVal = [NSString stringWithFormat:@"%d", i];
            [amountHundreds addObject:stringVal];
            [amountTens addObject:stringVal];
            [amountOnes addObject:stringVal];
            [amountTenths addObject:stringVal];
        }
        
        NSLog(@"meas: %lu", (unsigned long)[measurementArray count]);
        
        //Set defaults of picker selections
        selectedHundreds = @"0";
        selectedTens = @"0";
        selectedOnes = @"0";
        selectedMeasurement = measurementArray[0];
        formattedQuantity = @"000 qt";
    }
    return self;
}

#pragma mark - UIPickerViewDataSource Implementation

//Set number of components
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 4;
}

//Set number of rows
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    //Returns
    switch (component) {
        case 0:
            return [amountHundreds count];
        case 1:
            return [amountTens count];
        case 2:
            return [amountOnes count];
        case 3:
            return [measurementArray count];
        default:break;
    }
    return 0;
}

#pragma mark UIPickerViewDelegate Implementation

//Returns width of column and height of row for each component.
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    switch (component) {
        case 0:
            return 30.0f;
        case 1:
            return 30.0f;
        case 2:
            return 30.0f;
        case 3:
            return 200.0f;
        default:break;
    }
    return 0;
}

//Set content for components
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    switch (component) {
        case 0:
            return amountHundreds[(NSUInteger) row];
        case 1:
            return amountTens[(NSUInteger) row];
        case 2:
            return amountOnes[(NSUInteger) row];
        case 3:
            return measurementArray[(NSUInteger) row];
        default:break;
    }
    return nil;
}

- (void)actionSheetPickerDidSucceed:(AbstractActionSheetPicker *)actionSheetPicker origin:(id)origin {
    NSString *fullQuantity;
    //Get numbers from string
    NSString *numberString = [formattedQuantity substringToIndex:3];
    //Check if picker was selected, set default to 1 qt if not.
    if ([numberString isEqualToString:@"000"]) {
        fullQuantity = [NSString stringWithFormat:@"1 %@", selectedMeasurement];
    } else {
        fullQuantity = formattedQuantity;
    }
    
    //Strip leading zeros off
    NSRange range = [fullQuantity rangeOfString:@"^0*" options:NSRegularExpressionSearch];
    fullQuantity = [fullQuantity stringByReplacingCharactersInRange:range withString:@""];
    //Call method on NewRecipe with formatted quantity passed
    [self.myRecipeVC quantityPicked:fullQuantity];
}

//Grab selections
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSLog(@"Row %li selected in component %li", (long)row, (long)component);
    
    //Grab inputs for each component. Using if statements instead of case due to out of range crash selecting numbers. This is most efficient fix while that still allows any selectiong order for each component.
    if (component == 0) {
        selectedHundreds = amountHundreds[row];
    }
    if (component == 1) {
        selectedTens = amountTens[row];
    }
    if (component == 2) {
        selectedOnes = amountOnes[row];
    }
    if (component == 3) {
        selectedMeasurement = measurementArray[row];
    }
    
    formattedQuantity = [NSString stringWithFormat:@"%@%@%@ %@", selectedHundreds, selectedTens, selectedOnes, selectedMeasurement];
    NSLog(@"formatted # = %@", formattedQuantity);
    
}

@end
