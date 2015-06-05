// Elijah Freestone
// My Brew Log V1.0
// May 7th, 2015

//
//  NewRecipeViewController.h
//  MyBrewLog
//
//  Created by Elijah Freestone on 5/7/15.
//  Copyright (c) 2015 Elijah Freestone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyRecipeViewController.h"
#import "RecipeDetailsViewController.h"

@interface NewRecipeViewController : UIViewController 

-(IBAction)onCancel:(id)sender;

@property (strong, nonatomic) IBOutlet UISegmentedControl *recipeTypeSegment;
@property (strong, nonatomic) IBOutlet UISegmentedControl *addItemsSegment;
@property (strong, nonatomic) IBOutlet UIButton *ingredientButton;

@property (strong, nonatomic) IBOutlet UITextField *recipeNameTF;
@property (strong, nonatomic) IBOutlet UITextView *ingredientsTV;
@property (strong, nonatomic) IBOutlet UITextView *instructionsTV;
@property (strong, nonatomic) MyRecipeViewController *myRecipeVC;
@property (strong, nonatomic) RecipeDetailsViewController *recipeDetailsVC;

@property (strong, nonatomic) NSString *passedName;
@property (strong, nonatomic) NSString *passedType;
@property (strong, nonatomic) NSString *passedIngredients;
@property (strong, nonatomic) NSString *passedInstructions;
@property (strong, nonatomic) NSString *passedObjectID;
@property (strong, nonatomic) NSString *passedUsername;
@property (strong, nonatomic) PFObject *passedObject;
@property (nonatomic) BOOL isCopy;

@property (strong, nonatomic) NSArray *fruitsArray;
@property (strong, nonatomic) NSArray *vegetablesArray;
@property (strong, nonatomic) NSArray *grainsAndHopsArray;
@property (strong, nonatomic) NSArray *maltsAndSugarsArray;
@property (strong, nonatomic) NSArray *yeastArray;

-(void)quantityPicked:(NSString *)formattedQuantity;
-(void)timerPicked: (NSString *)formattedTime;

@end
