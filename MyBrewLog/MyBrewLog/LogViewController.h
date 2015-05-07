// Elijah Freestone
// My Brew Log V1.0
// May 7th, 2015

//
//  LogViewController.h
//  MyBrewLog
//
//  Created by Elijah Freestone on 5/7/15.
//  Copyright (c) 2015 Elijah Freestone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "RecipeDetailsViewController.h"

@interface LogViewController : UIViewController

@property (strong, nonatomic) NSString *titleString;
@property (strong, nonatomic) NSString *notesString;
@property (strong, nonatomic) PFObject *passedObject;
@property (strong, nonatomic) RecipeDetailsViewController *detailsVC;

@property (strong, nonatomic) IBOutlet UINavigationBar *navBar;
@property (strong, nonatomic) IBOutlet UITextView *notesTextView;

-(IBAction)doneClicked:(id)sender;
-(IBAction)dismissKeyboard:(id)sender;

@end
