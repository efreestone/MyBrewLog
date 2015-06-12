// Elijah Freestone
// My Brew Log V1.0
// May 7th, 2015

//
//  CustomQuantityPickerDelegate.h
//  MyBrewLog
//
//  Created by Elijah Freestone on 5/7/15.
//  Copyright (c) 2015 Elijah Freestone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActionSheetCustomPickerDelegate.h"
#import "NewRecipeViewController.h"

@protocol CustomQuantityPickerDelegate <NSObject>

-(void)quantityPicked:(NSString *)formattedQuantity;

@end

@interface CustomQuantityPickerDelegate : NSObject <ActionSheetCustomPickerDelegate>

@property (nonatomic,strong) NewRecipeViewController *myRecipeVC;

@end
