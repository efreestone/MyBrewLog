// Elijah Freestone
// My Brew Log V1.0
// May 7th, 2015
//
//  SettingsViewController.m
//  MyBrewLog
//
//  Created by Elijah Freestone on 5/7/15.
//  Copyright (c) 2015 Elijah Freestone. All rights reserved.
//

#import "SettingsViewController.h"
#import "MyRecipeViewController.h"
#import <Parse/Parse.h>

@interface SettingsViewController ()

@end

@implementation SettingsViewController {
    MyRecipeViewController *myRecipes;
    PFUser *currenUser;
    NSUserDefaults *userDefaults;
}

@synthesize autoSyncSwitch, editRecipeSwitch, publicSwitch, unitsSegment;

- (void)viewDidLoad {
    //Grab user defaults and set elements accordingly
    userDefaults = [NSUserDefaults standardUserDefaults];
    
    int unitIndex = 0;
    if ([userDefaults boolForKey:@"isMetric"]) {
        NSLog(@"isMetric");
        unitIndex = 1;
    }
    
    //Check edit bool and set to yes if it doesn't exist
    if ([userDefaults objectForKey:@"Edit"]) {
        [userDefaults setBool:YES forKey:@"Edit"];
        [userDefaults synchronize];
    }
    
    //Check private bool and set to no if it doesn't exist
    if ([userDefaults objectForKey:@"Private"] == nil) {
        NSLog(@"Private bool nil");
        [userDefaults setBool:NO forKey:@"Private"];
        [userDefaults synchronize];
    }
    
    //Check private bool in user defaults, if yes turn public switch to off
    if ([userDefaults boolForKey:@"Private"]) {
        [publicSwitch setOn:NO];
    } else {
        [publicSwitch setOn:YES];
    }
    
    unitsSegment.selectedSegmentIndex = unitIndex;
    
    currenUser = [PFUser currentUser];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Grab public switch state and set Public/Private accordingly
-(IBAction)publicSwitchSet:(UISwitch *)sender {
    NSString *publicMessage = @"All recipes, incuding any new ones you create will be PUBLIC. This can be changed on individual recipes by using the Public switch on their details page.";
    PFACL *acl = [PFACL ACL];
    PFQuery *privateQuery = [PFQuery queryWithClassName:@"newRecipe"];
    BOOL isPrivate = NO;
    [privateQuery whereKey:@"createdBy" equalTo:[PFUser currentUser].username];
    if (![publicSwitch isOn]) {
        NSLog(@"Public Switch is off");
        publicMessage = @"All recipes, incuding any new ones you create will be PRIVATE. This can be changed on individual recipes by using the Public switch on their details page.";
        [acl setReadAccess:YES forUser:[PFUser currentUser]];
        [acl setWriteAccess:YES forUser:[PFUser currentUser]];
        [acl setPublicReadAccess:false];
        isPrivate = YES;
        [PFACL setDefaultACL:acl withAccessForCurrentUser:YES];
        [userDefaults setBool:YES forKey:@"Private"];
    } else {
        isPrivate = NO;
        [acl setPublicReadAccess:true];
        [acl setPublicWriteAccess:true];
        [PFACL setDefaultACL:acl withAccessForCurrentUser:YES];
        [userDefaults setBool:NO forKey:@"Private"];
    }
    //Save in background with new acl
    [privateQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error) {
            for (PFObject *object in objects) {
                //Set bool to not public
                object[@"Private"] = [NSNumber numberWithBool:isPrivate];
                //Change ACL of the recipe
                [object setACL:acl];
                [object saveInBackgroundWithBlock:^(BOOL success, NSError *error){
                    if (!error) {
                        NSLog(@"Save successful - public");
                    } else {
                        NSLog(@"Error saving object - public");
                    }
                }];
            } //for close
            [self showPublicAlert:publicMessage];
        }
    }];
}

//Grab edit switch state and set Edit accordingly
-(IBAction)editSwitchSet:(id)sender {
    NSString *editMessage = @"Edit is on. The edit button for recipes will function as normal.";
    if ([editRecipeSwitch isOn]) {
        NSLog(@"Edit YES");
        [userDefaults setBool:YES forKey:@"Edit"];
    } else {
        NSLog(@"Edit NO");
        [userDefaults setBool:NO forKey:@"Edit"];
        editMessage = @"Edit is off. Selecting the Edit button for a recipe will Copy it instead. This way you can't accidentally change an existing recipe you are experimenting with";
    }
    [self showEditAlert:editMessage];
}

//Grab segment and set units of measurement accordingly
-(IBAction)unitsSegmentIndexChanged:(id)sender {
    if (unitsSegment.selectedSegmentIndex == 0) {
        NSLog(@"index 0");
        [userDefaults setBool:NO forKey:@"isMetric"];
        [userDefaults synchronize];
    } else {
        NSLog(@"index 1");
        [userDefaults setBool:YES forKey:@"isMetric"];
        [userDefaults synchronize];
    }
}

//Log user out
-(IBAction)onLogOutClick:(id)sender {
    //Change tab to My Recipes and log out user. This also triggers presenting the login screen
    [self.tabBarController setSelectedIndex:0];
    [PFUser logOut];
    
    NSLog(@"user logged out from settings");
}

//Create alert with 2 text fields for changing email and/or username
-(IBAction)onEditUserClick:(id)sender {
    NSString *emailString = [currenUser email];
    //NSLog(@"email %@", emailString);
    NSString *usernameString = [currenUser username];
    //NSLog(@"username %@", usernameString);
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Edit User"
                                                   message:@"Reset username and/or email. Please use \"Forgot Password?\" on the login screen to reset password. Requires Email"
                                                  delegate:self cancelButtonTitle:@"Cancel"
                                         otherButtonTitles:@"Save", nil];
    
    alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    [alert textFieldAtIndex:1].secureTextEntry = NO;
    if (emailString.length == 0) {
        [alert textFieldAtIndex:0].placeholder = @"Enter New Email";
    } else {
        [alert textFieldAtIndex:0].text = emailString;
    }
    if (usernameString.length == 0) {
        [alert textFieldAtIndex:1].placeholder = @"Enter New Username";
    } else {
        [alert textFieldAtIndex:1].text = usernameString;
    }
    
    [alert show];
}

#pragma mark - Alerts

//Method to create and show alert view for public switch
-(void)showPublicAlert:(NSString *)message {
    UIAlertView *publicAlert = [[UIAlertView alloc] initWithTitle:@"Alert" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    //Show alert
    [publicAlert show];
} //showAlert close

//Method to create and show alert view for edit switch
-(void)showEditAlert:(NSString *)message {
    UIAlertView *editAlert = [[UIAlertView alloc] initWithTitle:@"Alert" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    //Show alert
    [editAlert show];
} //showAlert close

//Capture text input from alertview and reset username and/or email
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *newEmail = [alertView textFieldAtIndex:0].text;
    NSString *newUsername = [alertView textFieldAtIndex:1].text;
    if (buttonIndex == 1) {
        if (newEmail.length != 0) {
            [[PFUser currentUser] setEmail:newEmail];
            [[PFUser currentUser] saveInBackground];
        }
        if (newUsername.length != 0) {
            [[PFUser currentUser] setUsername:newUsername];
            [[PFUser currentUser] saveInBackground];
        }
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
