// Elijah Freestone
// My Brew Log V1.0
// May 7th, 2015

//
//  BrowseDetailsViewController.m
//  MyBrewLog
//
//  Created by Elijah Freestone on 5/7/15.
//  Copyright (c) 2015 Elijah Freestone. All rights reserved.
//

#import "BrowseDetailsViewController.h"
#import "NewRecipeViewController.h"
#import <Social/Social.h>

@interface BrowseDetailsViewController () {
    NSArray *recipesArray;
    NSArray *listItems;
    NSString *usernameString;
}

@end

@implementation BrowseDetailsViewController

//Synthesize for getters/setters
@synthesize nameLabel, usernameLabel, ingredientsTV, instructionsTV;
@synthesize passedObject, passedName, passedType, passedIngredients, passedUsername, passedInstructions, passedObjectID, passedIsFavorite, passedSortInt;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //Set textviews with passed data
    nameLabel.text = passedName;
    ingredientsTV.text = passedIngredients;
    instructionsTV.text = passedInstructions;
    //Grab username and display
    usernameString = [passedObject objectForKey:@"createdBy"];
    usernameLabel.text = [NSString stringWithFormat:@"By: %@", usernameString];
    
    if (passedIsFavorite) {
        [self.favoriteButton setTitle:@"Is Fav" forState:UIControlStateNormal];
    }
    
    //Set rounded corners on ing and inst textviews
    [[ingredientsTV layer] setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [[ingredientsTV layer] setBorderWidth:0.5];
    [[ingredientsTV layer] setCornerRadius:7.5];
    
    [[instructionsTV layer] setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [[instructionsTV layer] setBorderWidth:0.5];
    [[instructionsTV layer] setCornerRadius:7.5];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Share button clicked
-(IBAction)shareClicked:(id)sender {
    [self createActivityViewForShare];
}

//Method to create and show alert view
-(void)showAlert:(NSString *)alertMessage withTitle:(NSString *)titleString {
    UIAlertView *copyAlert = [[UIAlertView alloc] initWithTitle:titleString message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    //Show alert
    [copyAlert show];
}

//Set object to favorites when fav selected
-(IBAction)favoriteSelected:(id)sender {
    PFQuery *favQuery = [PFQuery queryWithClassName:@"newRecipe"];
    [favQuery getObjectInBackgroundWithId:passedObjectID block:^(PFObject *favObject, NSError *error) {
        NSLog(@"passed ID = %@", passedObjectID);
        if (!error) {
            //Is not fav, add it
            if (!passedIsFavorite) {
                [favObject addUniqueObject:[PFUser currentUser].objectId forKey:@"favorites"];
                [favObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        NSLog(@"Favorited Success");
                        //Create and show an alert
                        NSString *titleString = @"Favorite Recipe";
                        NSString *alertMessage = @"Recipe added to favorites. Select Favorite in the Browse Sort to see your Favorite Recipes";
                        [self showAlert:alertMessage withTitle:titleString];
                        //Set fav button and BOOL
                        [self.favoriteButton setTitle:@"Is Fav" forState:UIControlStateNormal];
                        passedIsFavorite = YES;
                    } else {
                        NSLog(@"Favorited add ERROR");
                    }
                }];
            } else {
            //Recipe is already fav, remove it
                [favObject removeObject:[PFUser currentUser].objectId forKey:@"favorites"];
                [favObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (!error) {
                        NSLog(@"Favorited Success");
                        //Create and show an alert
                        NSString *titleString = @"Favorite Recipe";
                        NSString *alertMessage = @"Recipe removed from favorites";
                        [self showAlert:alertMessage withTitle:titleString];
                        //Set fav button and BOOL
                        [self.favoriteButton setTitle:@"Favorite" forState:UIControlStateNormal];
                        passedIsFavorite = NO;
                        //Refresh browse table. This is to clear fav sort of unfavorited recipes.
                        [self.browseVC refreshTable:passedSortInt];
                    } else {
                        NSLog(@"Favorited remove ERROR");
                    }
                }];
            }
        } //!error close
    }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"DetailsCopy"]) {
        //Get VC and set items for passed object
        NewRecipeViewController *newRecipeVC = segue.destinationViewController;
        newRecipeVC.passedName = passedName;
        newRecipeVC.passedType = passedType;
        newRecipeVC.passedIngredients = passedIngredients;
        newRecipeVC.passedInstructions = passedInstructions;
        newRecipeVC.passedUsername = usernameString;
        newRecipeVC.passedObjectID = passedObjectID;
        newRecipeVC.passedObject = passedObject;
        newRecipeVC.isCopy = YES;
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


@end
