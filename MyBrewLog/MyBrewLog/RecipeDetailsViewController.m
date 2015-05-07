// Elijah Freestone
// My Brew Log V1.0
// May 7th, 2015

//
//  RecipeDetailsViewController.m
//  MyBrewLog
//
//  Created by Elijah Freestone on 5/7/15.
//  Copyright (c) 2015 Elijah Freestone. All rights reserved.
//

#import "RecipeDetailsViewController.h"
#import "NewRecipeViewController.h"
#import "TimersViewController.h"
#import "LogViewController.h"
#import "AppDelegate.h"
#import <Social/Social.h>

@interface RecipeDetailsViewController () <UITextViewDelegate, UIActionSheetDelegate> {
    NSInteger countdownSeconds;
    TimersViewController *timersViewController;
    BOOL isCopy;
    BOOL isActive;
    BOOL isPrivate;
    BOOL canEdit;
    AppDelegate *appDelegate;
    PFACL *objectACL;
}

@end

@implementation RecipeDetailsViewController

//Synthesize for getters/setters
@synthesize nameLabel, ingredientsTV, instructionsTV;
@synthesize passedObject, passedName, passedType, passedIngredients, passedUsername, passedInstructions, passedNotes, passedObjectID;
@synthesize activeSwitch, publicSwitch;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    appDelegate = [[UIApplication sharedApplication] delegate];
    //Grab timers view controller to start timers from textview
    timersViewController = (TimersViewController*)[[self.tabBarController viewControllers] objectAtIndex:2];
    //set timers app delegate
    timersViewController.appDelegate = appDelegate;
    
    //Grab ACL of the current recipe. Used for Public switch
    objectACL = [PFACL ACL];
    
    //Grab userDefaults and set edit accordingly. Edit to no means selecting edit for the recipe will copy instead
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    canEdit = [userDefaults boolForKey:@"Edit"];
    
    //Get active bool and set switch accordingly
    isActive = [passedObject valueForKey:@"Active"];
    if (isActive) {
        NSLog(@"is active");
        [activeSwitch setOn:YES];
    } else {
        NSLog(@"not active");
        [activeSwitch setOn:NO];
    }
    
    //Get private bool and set switch accordingly
    isPrivate = [passedObject valueForKey:@"Private"];
    if (isPrivate) {
        NSLog(@"not public");
        [publicSwitch setOn:NO];
    } else {
        NSLog(@"is public");
        [publicSwitch setOn:YES];
    }
    
    //Set textviews with passed data
    nameLabel.text = passedName;
    ingredientsTV.text = passedIngredients;
    instructionsTV.text = passedInstructions;
    
    //Set rounded corners on ing and inst textviews
    [[ingredientsTV layer] setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [[ingredientsTV layer] setBorderWidth:0.5];
    [[ingredientsTV layer] setCornerRadius:7.5];
    
    [[instructionsTV layer] setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [[instructionsTV layer] setBorderWidth:0.5];
    [[instructionsTV layer] setCornerRadius:7.5];
    
    //Grab string and change to NSAttributedString
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc]initWithString:passedInstructions];
    NSArray *words=[self.instructionsTV.text componentsSeparatedByString:@"\n"];
    //Add url attribute to lines that start with Timer:
    for (NSString *word in words) {
        if ([word hasPrefix:@"Timer:"]) {
            NSRange range=[self.instructionsTV.text rangeOfString:word];
            //Add URL attribute. This is captured later to trigger Timer code
            [string addAttribute:NSLinkAttributeName value:@"Timer://timer" range:range];
        }
    }
    [self.instructionsTV setAttributedText:string];
    
    [ingredientsTV flashScrollIndicators];
    [instructionsTV flashScrollIndicators];
    
    //Override link color
    instructionsTV.linkTextAttributes = @{NSForegroundColorAttributeName:[UIColor redColor]};
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Dismiss view. Used to dismiss from new recipe edit upon saving
-(void)pressBackButton {
    [self.navigationController popViewControllerAnimated:YES];
}

# pragma mark - AlertViews

//Method to create and show alert view if timer format does not match
-(void)showNoMatchAlert {
    NSString *noMatchString = @"Sorry, the timer does not match the format and can't be started. The accepted formats are \"HH:MM\" for under 24 hours and \"0 Months, 0 Weeks, 0 Days\" for over 24 hours. Please check the format and try again";
    UIAlertView *noMatchAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:noMatchString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    //Show alert
    [noMatchAlert show];
} //showAlert close

//Method to create and show alert view with text input for timers
-(void)showTimerAlert:(NSString *)alertMessage {
    NSString *formattedString = [NSString stringWithFormat:@"%@ \nPlease enter a discription for the new timer. Over 24 hours will be calendar entries.", alertMessage];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Start Timer"
                                                    message:formattedString
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Start", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = 100;
    [alert show];
} //showAlert close

//Method to create and show alert view if timer format does not match
-(void)showDeleteConfrimAlert {
    NSString *deleteConfirmString = @"Are you sure you want to delete this recipe? It can not be undone.";
    UIAlertView *deleteConfrimAlert = [[UIAlertView alloc] initWithTitle:@"Delete Recipe?" message:deleteConfirmString delegate:self cancelButtonTitle:@"No, Cancel" otherButtonTitles:@"Yes, Delete", nil];
    deleteConfrimAlert.tag = 200;
    //Show alert
    [deleteConfrimAlert show];
} //showAlert close

//Grab text entered into alertview and start timer
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *description = [alertView textFieldAtIndex:0].text;

    if (alertView.tag == 100) {
        NSLog(@"tag 100, timer alert");
        if (description.length == 0) {
            description = @"No Description";
        }
        [timersViewController startTimerFromDetails:countdownSeconds withDetails:description];
        //timersViewController.oneView.hidden = NO;
    }
    if (alertView.tag == 200) {
        if (buttonIndex == 1) {
            NSLog(@"tag 200 index 1, yes delete");
            [self deleteObject];
        } else {
            NSLog(@"tag 200 other index, cancel");
        }
    }
}

# pragma mark - ActionSheet (menu)

//Create and show action sheet
-(IBAction)showMenuActionSheet:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"What would you like to do with this recipe?"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Edit", @"Copy", @"Share", @"Delete", nil];
    
    [actionSheet showInView:self.view];
}

//Get tag for action sheet but selected and process accordingly
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: //Edit
            NSLog(@"0");
            //Set copy BOOL based on Edit userDefaults
            if (canEdit) {
                isCopy = NO;
            } else {
                isCopy = YES;
            }
            
            [self performSegueWithIdentifier:@"Edit" sender:self];
            break;
        case 1: //Copy
            NSLog(@"1");
            //Set copy BOOL
            isCopy = YES;
            [self performSegueWithIdentifier:@"Edit" sender:self];
            break;
        case 2: //Share
            NSLog(@"2");
            [self createActivityViewForShare];
            break;
        case 3: //Delete
            NSLog(@"3");
            //[self deleteObject];
            [self showDeleteConfrimAlert];
            break;
        default:
            NSLog(@"Other clicked");
            break;
    }
}

//Create activity view controller to Facebook or Twitter
-(void)createActivityViewForShare {
    NSString *text = [NSString stringWithFormat:@"Check out my %@ recipe on @My_Brew_Log (insert link) called %@", passedType, passedName];
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[text] applicationActivities:nil];
    
    //Ignore all share options but facebook and twitter
    activityController.excludedActivityTypes = @[UIActivityTypePostToWeibo,
                                         UIActivityTypeMessage,
                                         UIActivityTypeMail,
                                         UIActivityTypePrint,
                                         UIActivityTypeCopyToPasteboard,
                                         UIActivityTypeAssignToContact,
                                         UIActivityTypeSaveToCameraRoll,
                                         UIActivityTypeAddToReadingList,
                                         UIActivityTypePostToFlickr,
                                         UIActivityTypePostToVimeo,
                                         UIActivityTypePostToTencentWeibo,
                                         UIActivityTypeAirDrop];
    
    [self presentViewController:activityController animated:YES completion:nil];
}

//Delete object
-(void)deleteObject {
    // Delete the object from the data source
    [passedObject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        //[self loadObjects];
        [self pressBackButton];
    }];
}

#pragma mark - UISwitch

//Public switch changed
-(IBAction)publicSwitchChanged:(id)sender {
    //Set ACL to public
    if ([publicSwitch isOn]) {
        NSLog(@"Switch is on");
        [objectACL setPublicReadAccess:true];
        [objectACL setPublicWriteAccess:true];
        //Set bool to represent if it is public or not. Much easier than trying to read ACL settings
        passedObject[@"Private"] = [NSNumber numberWithBool:NO];
    } else {
    //Set ACL to private
        NSLog(@"Switch is off");
        [objectACL setReadAccess:YES forUser:[PFUser currentUser]];
        [objectACL setWriteAccess:YES forUser:[PFUser currentUser]];
        [objectACL setPublicReadAccess:false];
        //Set bool to not public
        passedObject[@"Private"] = [NSNumber numberWithBool:YES];
    }
    //Change ACL of the recipe and save
    [passedObject setACL:objectACL];
    [passedObject saveInBackgroundWithBlock:^(BOOL success, NSError *error){
        if (!error) {
            NSLog(@"Save successful - public");
        } else {
            NSLog(@"Error saving object - public");
        }
    }];
}

//Active switch changed
-(IBAction)activeSwitchChanged:(id)sender {
    //Check switch status
    if ([activeSwitch isOn]) {
        NSLog(@"Switch is on");
        passedObject[@"Active"] = [NSNumber numberWithBool:YES];
    } else {
        NSLog(@"Switch is off");
        passedObject[@"Active"] = [NSNumber numberWithBool:NO];
    }
    //Save object with Active set
    [passedObject saveInBackgroundWithBlock:^(BOOL success, NSError *error){
        if (!error) {
            NSLog(@"Save successful - active");
        } else {
            NSLog(@"Error saving object - active");
        }
    }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Edit"]) {
        //Get VC and set items for passed object
        NewRecipeViewController *newRecipeVC = segue.destinationViewController;
        newRecipeVC.passedName = passedName;
        newRecipeVC.passedType = passedType;
        newRecipeVC.passedIngredients = passedIngredients;
        newRecipeVC.passedInstructions = passedInstructions;
        newRecipeVC.passedUsername = passedUsername;
        newRecipeVC.passedObjectID = passedObjectID;
        newRecipeVC.passedObject = passedObject;
        newRecipeVC.isCopy = isCopy;
        
        newRecipeVC.recipeDetailsVC = self;
    }
    
    if ([segue.identifier isEqualToString:@"Log"]) {
        LogViewController *logViewController = segue.destinationViewController;
        logViewController.titleString = passedName;
        logViewController.notesString = passedNotes;
        logViewController.passedObject = passedObject;
        logViewController.detailsVC = self;
    }
}

//Grab URL click in TextView and start timer, return NO to stop browser from opening
-(BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    NSString *rangeString = [textView.text substringWithRange:characterRange];
    NSLog(@"%@", rangeString);
    
    //Remove "Timer:" from string for easier processing
    NSString *timeString = [rangeString substringFromIndex:7];
    //Check format with regex. Under searches for 0:00 or 00:00 format
    NSString *under24Pattern = @"^([0-9]|0[0-9]|1?[0-9]|2[0-3]):([0-5][0-9]\\s?)$";
    NSPredicate *predicateOne = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", under24Pattern];
    //Check for 0 Months, 0 Weeks, 0 Days format. double digit for any of the numbers is accepted too
    NSString *over24Pattern = @"^[0-9]{1,2} [mM](onths)?(,)? [0-9]{1,2} [wW](eeks)?(,)? [0-9]{1,2} [dD](ays)?$";
    NSPredicate *predicateTwo = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", over24Pattern];
    //Check for 0 Hours 0 Minutes (double digits ok). This is to account for the old format of under 24 timers
    NSString *altUnder24Pattern = @"^[0-9]{1,2} [hH](ours)?(,)? [0-9]{1,2} [mM](inutes)?$";
    NSPredicate *predicateThree = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", altUnder24Pattern];
    
    //NSLog(@"timerString =%@-", timeString);
    
    //If matches 0:00 or 00:00 formats
    if ([predicateOne evaluateWithObject:timeString]) {
        NSLog(@"00:00 matches");
        //Add extra zero at beginning if hours is only one digit
        if (timeString.length == 5) {
            timeString = [NSString stringWithFormat:@"0%@", timeString];
            NSLog(@"timerString = %@ %lu", timeString, (unsigned long)timeString.length);
        }
        //Seperate string into array at comma
        NSArray *numbersArray = [timeString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":"]];
        //Grab int values form array
        NSInteger hoursFromString = [numbersArray[0] intValue];
        NSInteger hoursInt = 0;
        NSInteger minuteFromString = [numbersArray[1] intValue];
        NSInteger minutesInt = 0;
        
        //Make sure times aren't 00 and get seconds
        if (hoursFromString != 00) {
            hoursInt = hoursFromString * 3600;
        }
        if (minuteFromString != 00) {
            minutesInt = minuteFromString * 60;
        }
        countdownSeconds = hoursInt + minutesInt;
        NSLog(@"Countdown = %ld in under 24", (long)countdownSeconds);
    //Matches 0 Months, 0 Weeks, 0 Days (double digit ok too)
    } else if ([predicateTwo evaluateWithObject:timeString]) {
        NSLog(@"Months, Weeks, Days matches");
        //Seperate string into array at comma
        NSArray *numbersArray = [timeString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
        //Grab int values from array
        NSInteger monthsFromString = [numbersArray[0] intValue];
        NSInteger monthsInt = 0;
        NSInteger weeksFromString = [numbersArray[2] intValue];
        NSInteger weeksInt = 0;
        NSInteger daysFromString = [numbersArray[4] intValue];
        NSInteger daysInt = 0;
        
        //Make sure times aren't 00 and get seconds
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
    //Alternative under 24 matches 0 Hours 0 Minutes (double digits ok). This was the original format
    } else if ([predicateThree evaluateWithObject:timeString]) {
        NSLog(@"0 Hours 0 Minutes matches");
        NSArray *numbersArray = [timeString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
        NSInteger hoursFromString = [numbersArray[0] intValue];
        NSInteger hoursInt = 0;
        NSInteger minuteFromString = 0;
        if (numbersArray.count >= 2) {
            minuteFromString = [numbersArray[2] intValue];
        }
        NSInteger minutesInt = 0;
        
        //Make sure times aren't 00 and get seconds
        if (hoursFromString != 00) {
            hoursInt = hoursFromString * 3600;
        }
        if (minuteFromString != 00) {
            minutesInt = minuteFromString * 60;
        }
        countdownSeconds = hoursInt + minutesInt;
        NSLog(@"Countdown = %ld in Alt under 24", (long)countdownSeconds);
    //No format matches
    } else {
        NSLog(@"NO matches");
        [self showNoMatchAlert];
        return NO;
    }
    
    [self showTimerAlert:rangeString];
    return NO;
}

@end
