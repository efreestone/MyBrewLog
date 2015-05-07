// Elijah Freestone
// My Brew Log V1.0
// May 7th, 2015

//
//  MyRecipeViewController.m
//  MyBrewLog
//
//  Created by Elijah Freestone on 5/7/15.
//  Copyright (c) 2015 Elijah Freestone. All rights reserved.
//

#import "MyRecipeViewController.h"
#import "CustomTableViewCell.h"
#import "AppDelegate.h"
#import "NewRecipeViewController.h"
#import "RecipeDetailsViewController.h"
#import <ParseUI/ParseUI.h>
#import "CustomPFLoginViewController.h"
#import "CustomPFSignUpViewController.h"
#import "AppDelegate.h"

#import "TimersViewController.h"

@interface MyRecipeViewController () <UITableViewDelegate, UITableViewDataSource, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, UIActionSheetDelegate, UISearchBarDelegate, UISearchResultsUpdating>

-(void)requestEventsAccess;

@end

//Create sort enum
typedef enum {
    SortDefault,
    SortActive,
    SortName,
    SortType,
    SortNewest,
    SortOldest
}sortEnum;

@implementation MyRecipeViewController {
    NSArray *recipesArray;
    NSArray *imageArray;
    NSString *parseClassName;
    
    NSString *selectedName;
    NSString *selectedIngredients;
    NSString *selectedInstructions;
    NSString *selectedType;
    NSString *selectedNotes;
    NSString *selectedObjectID;
    PFObject *selectedPFObject;
    NSString *usernameString;
    sortEnum toSort;
    
    PFQuery *newItemQuery;
    AppDelegate *appDelegate;
    UIView *noRecipesView;
    UITextField *searchTextField;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //Grab timer VC and alloc sound
    TimersViewController *timerVC = (TimersViewController *)[[self.navigationController.tabBarController viewControllers] objectAtIndex:2];
    // Construct URL to sound file
    NSString *path = [NSString stringWithFormat:@"%@/bell.mp3", [[NSBundle mainBundle] resourcePath]];
    NSURL *soundUrl = [NSURL fileURLWithPath:path];
    timerVC.alarmPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:nil];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
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
    
    //Grab app delegate
    appDelegate = [[UIApplication sharedApplication] delegate];
    
    //Set default ACL according to isPublic settings switch
    PFACL *defaultACL = [PFACL ACL];
    if ([userDefaults boolForKey:@"Private"]) {
        NSLog(@"Private ACL");
        [defaultACL setReadAccess:YES forUser:[PFUser currentUser]];
        [defaultACL setWriteAccess:YES forUser:[PFUser currentUser]];
        [defaultACL setPublicReadAccess:false];
        [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    } else {
        NSLog(@"Public ACL");
        [defaultACL setPublicReadAccess:YES];
        [defaultACL setPublicWriteAccess:YES];
        [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    }
    
    parseClassName = @"newRecipe";
    
    //Set seperators. Not sure why but they disappeared after hooking up Parse
    self.myTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    //Grab user and username
    PFUser *user = [PFUser currentUser];
    usernameString = [user objectForKey:@"username"];
    
    if ([PFUser currentUser]) {
        //Log username if user is logged in
        NSLog(@"%@ is logged in", usernameString);
//        //Request push notifications
//        [self requestPushAccess];
        
        //Request access to device events. A delay is required in order for events kit to initialize
        [self performSelector:@selector(requestEventsAccess) withObject:nil afterDelay:0.5];
    }
    
    noRecipesView = [[UIView alloc] initWithFrame:self.view.frame];
    noRecipesView.backgroundColor = [UIColor clearColor];
    //Create and set no recpices label
    UILabel *noRecipesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, noRecipesView.frame.size.width, 200)];
    noRecipesLabel.font = [UIFont boldSystemFontOfSize:18];
    noRecipesLabel.numberOfLines = 1;
    noRecipesLabel.textColor = [UIColor darkGrayColor];
    noRecipesLabel.shadowOffset = CGSizeMake(0, 1);
    //noRecipesLabel.backgroundColor = [UIColor clearColor];
    noRecipesLabel.textAlignment = NSTextAlignmentCenter;
    noRecipesLabel.text = @"No Recipes to Show";
    //Hide no recipe view by default. Is shown if no recipes are available to show
    noRecipesView.hidden = YES;
    [noRecipesView addSubview:noRecipesLabel];
    [self.tableView insertSubview:noRecipesView belowSubview:self.tableView];
    
    //Test parse
    //    PFObject *testObject = [PFObject objectWithClassName:@"TestObject"];
    //    testObject[@"foo"] = @"bar";
    //    [testObject saveInBackground];
    
    //Create and set up search bar and related
    self.recipeSearchResults = [[NSMutableArray alloc] init];
    self.recipeSearchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.recipeSearchController.searchBar.delegate = self;
    self.recipeSearchController.dimsBackgroundDuringPresentation = NO;
    self.recipeSearchController.searchResultsUpdater = self;
    
    self.recipeSearchController.searchBar.frame = CGRectMake(self.recipeSearchController.searchBar.frame.origin.x, self.recipeSearchController.searchBar.frame.origin.y, self.recipeSearchController.searchBar.frame.size.width, 44.0);
    self.recipeSearchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    
    self.tableView.tableHeaderView = self.recipeSearchController.searchBar;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.definesPresentationContext = YES;
}

-(void)viewWillAppear:(BOOL)animated {
    [self refreshTable];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //Check if user is logged in, in viewDidAppear to be checked whenever this tab is shown
    //This is used to present the login again after the user logs out on settings
    [self isUserLoggedIn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Request access to eventkit for use with calendars
-(void)requestEventsAccess {
    //Request access
    [appDelegate.eventManager.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL access, NSError *error) {
        if (!error) {
            //Store access BOOL
            appDelegate.eventManager.accessGranted = access;
            //Request push notifications used for active timers when app is backgrounded. These background timers use local notifications to do so
            [self requestPushAccess];
        } else {
            //Error, log description
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
}

//Request Push Access for timers in background
-(void)requestPushAccess {
    //Check and request push notification
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeSound categories:nil]];
    }
}

//Alloc new recipe and ptresent
-(IBAction)showNewRecipeView:(id)sender {
    UIStoryboard *storyBoard = [self storyboard];
    NewRecipeViewController *newRecipeViewController = [storyBoard instantiateViewControllerWithIdentifier:@"NewRecipe"];
    newRecipeViewController.myRecipeVC = self;
    //[self.navigationController popoverPresentationController:newRecipeViewController animated:true];
    [self presentViewController:newRecipeViewController animated:YES completion:nil];
}

//Check if user is logged in, present login if not
-(void)isUserLoggedIn {
    NSLog(@"isUserLoggedIn called");
    if (![PFUser currentUser]) { // No user logged in
        NSLog(@"No user logged in");
        // Create the log in view controller
        CustomPFLoginViewController *logInViewController = [[CustomPFLoginViewController alloc] init];
        
        [logInViewController setDelegate:self]; // Set ourselves as the delegate
        
        // Create the sign up view controller
        CustomPFSignUpViewController *signUpViewController = [[CustomPFSignUpViewController alloc] init];
        [signUpViewController setDelegate:self]; // Set ourselves as the delegate
        
        // Assign our sign up controller to be displayed from the login controller
        [logInViewController setSignUpController:signUpViewController];
        
        // Present the log in view controller
        [self presentViewController:logInViewController animated:YES completion:NULL];
    } else {
        NSLog(@"User is logged in from isUserLoggedIn");
    }
}

#pragma mark - PFQueryTableViewController

//Use initWithCoder instead of initWithStyle to use my own stroyboard.
//This was not working in project 2 because parseClassName wasn't being set properly
- (id)initWithCoder:(NSCoder *)aCoder {
    self = [super initWithCoder:aCoder];
    if (self) {
        // Customize the table
        // The className to query on
        self.parseClassName = @"newRecipe";
        // The key of the PFObject to display in the label of the default cell style
        self.textKey = @"text";
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        // The title for this table in the Navigation Controller.
        //self.title = @"My Contacts";
    }
    return self;
}

#pragma mark - Table view data source

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

//Set up cells and apply objects from Parse
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *cellID = @"MyRecipeCell";
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    CustomTableViewCell *cell = (CustomTableViewCell *) [tableView dequeueReusableCellWithIdentifier:cellID];
    
    //If browseSearchResults exists, populate table with search results
    if (self.recipeSearchResults.count >= 1) {
        //NSLog(@"Search results controller");
        //Get object from recipeSearchResults array instead of regular query
        PFObject *searchedObject = [self.recipeSearchResults objectAtIndex:indexPath.row];
        NSString *recipeType = [searchedObject objectForKey:@"Type"];
        NSString *imageName;
        //Set the icon based on recipe type. "Other" is the default
        if ([recipeType isEqualToString:@"Beer"]) {
            imageName = @"beer-bottle.png";
        } else if ([recipeType isEqualToString:@"Wine"]) {
            imageName = @"wine-glass.png";
        } else {
            imageName = @"other-icon.png";
        }
        
        //Grab date and set on table
        NSDate *updated = [object valueForKey:@"updatedByUser"];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"MM-dd-yy"];
        NSString *createdAtString = [NSString stringWithFormat:@"Created %@",[dateFormat stringFromDate:updated]];
        
        cell.recipeNameLabel.text = [searchedObject objectForKey:@"Name"];
        cell.detailsLabel.text = createdAtString;
        cell.cellImage.image = [UIImage imageNamed:imageName];
    } else {
    //Not search, populate in regular manner
        //NSLog(@"ELSE Search results controller");
        NSString *recipeType = [object objectForKey:@"Type"];
        NSString *imageName;
        //Set the icon based on recipe type. "Other" is the default
        if ([recipeType isEqualToString:@"Beer"]) {
            imageName = @"beer-bottle.png";
        } else if ([recipeType isEqualToString:@"Wine"]) {
            imageName = @"wine-glass.png";
        } else {
            imageName = @"other-icon.png";
        }
        
        //NSDate *updated = [object updatedAt];
        NSDate *updated = [object valueForKey:@"updatedByUser"];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"MM-dd-yy"];
        //cell.detailTextLabel.text = [NSString stringWithFormat:@"Lasted Updated: %@", [dateFormat stringFromDate:updated]];
        NSString *createdAtString = [NSString stringWithFormat:@"Created %@",[dateFormat stringFromDate:updated]];
        
        cell.recipeNameLabel.text = [object objectForKey:@"Name"];
        cell.detailsLabel.text = createdAtString;
        cell.cellImage.image = [UIImage imageNamed:imageName];
    }
    
    //Override to remove extra seperator lines after the last cell
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectMake(0,0,0,0)]];
    
    return cell;
} //cellForRowAtIndexPath close

-(void)refreshTable {
    [self loadObjects];
}

//Override query to set cache policy an change sort
- (PFQuery *)queryForTable {
    //Make sure parseClassName is set
    if (!self.parseClassName) {
        self.parseClassName = @"newRecipe";
    }
    //Grab objects
    newItemQuery = [PFQuery queryWithClassName:self.parseClassName];
    //Include only recipes for current user.
    //This does not work correctly if using usernameString for equalTo. Not sure why
    if ([PFUser currentUser]) {
        [newItemQuery whereKey:@"createdBy" equalTo:[PFUser currentUser].username];
    }

    //Set sort, toSort is set out of range of enum to start
    switch (toSort) {
        case 1: //Active
            [newItemQuery whereKey:@"Active" equalTo:[NSNumber numberWithBool:YES]];
            break;
        case 2: //Name
            [newItemQuery orderByAscending:@"Name"];
            break;
        case 3: //Type
            [newItemQuery orderByAscending:@"Type"];
            break;
        case 4: //Newest
            [newItemQuery orderByDescending:@"updatedByUser"];
            //[self refreshTable];
            break;
        case 5://Oldest
            [newItemQuery orderByAscending:@"updatedByUser"];
            //[self refreshTable];
            break;
        default:
            //[newItemQuery orderByDescending:@"updatedByUser"];
            break;
    }
    return newItemQuery;
} //queryForTable close

//Sort action sheet
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    //Add 1 to button index. toSort case 0 is default, first real case is 1
    toSort = (int) buttonIndex + 1;
    [self refreshTable];
}

//Set number of rows in the tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (self.recipeSearchResults.count == 0) {
        //Show/hide no recipes view based on count
        if (self.objects.count == 0) {
            noRecipesView.hidden = NO;
        } else {
            noRecipesView.hidden = YES;
        }
        return self.objects.count;
    } else {
        //Show/hide no recipes view based on count
        if (self.recipeSearchResults.count == 0) {
            noRecipesView.hidden = NO;
        } else {
            noRecipesView.hidden = YES;
        }
        return self.recipeSearchResults.count;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        PFObject *object;
        //Get the row from the data source.
        if (self.recipeSearchResults != nil && self.recipeSearchResults.count > 0) {
            //Search is active, object is from recipeSearchResults
            object = [self.recipeSearchResults objectAtIndex:indexPath.row];
            NSLog(@"Search delete");
        } else {
            //No search, object is from standard query
            object = [self.objects objectAtIndex:indexPath.row];
            NSLog(@"NOT Search delete");
        }
        //Delete the row on Parse
        [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                NSLog(@"Delete successful");
            } else {
                NSLog(@"Error deleting - %@", error.description);
            }
            
            [self.recipeSearchController setActive:NO];
            [self loadObjects];
            self.recipeSearchResults = nil;
        }];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

//Fired whenever a tableview cell is selected, including when search active
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *selectedObject;
    //If recipeSearchResults exists, process as search table
    if (self.recipeSearchResults.count >= 1) {
        //NSLog(@"indexpath at search tableview is: %ld", (long)indexPath.row);
        selectedObject = [self.recipeSearchResults objectAtIndex:indexPath.row];
        selectedName = [selectedObject objectForKey:@"Name"];
        selectedType = [selectedObject objectForKey:@"Type"];
        selectedIngredients = [selectedObject objectForKey:@"Ingredients"];
        selectedInstructions = [selectedObject objectForKey:@"Instructions"];
        selectedNotes = [selectedObject objectForKey:@"Notes"];
        selectedObjectID = [NSString stringWithFormat:@"%@", selectedObject.objectId];
        selectedPFObject = selectedObject;
    } else {
        //Not search, process as standard selection
        //NSLog(@"indexpath at orignal tableview is: %@", [indexPath description]);
        selectedObject = [self objectAtIndexPath:indexPath];
        selectedName = [selectedObject objectForKey:@"Name"];
        selectedType = [selectedObject objectForKey:@"Type"];
        selectedIngredients = [selectedObject objectForKey:@"Ingredients"];
        selectedInstructions = [selectedObject objectForKey:@"Instructions"];
        selectedNotes = [selectedObject objectForKey:@"Notes"];
        selectedObjectID = [NSString stringWithFormat:@"%@", selectedObject.objectId];
        selectedPFObject = selectedObject;
    }
    
    //Grab destination view controller
    UIStoryboard *storyBoard = [self storyboard];
    RecipeDetailsViewController *detailsViewController = [storyBoard instantiateViewControllerWithIdentifier:@"RecipeDetails"];
    
    //Pass details over to be displayed
    if (detailsViewController != nil) {
        detailsViewController.passedName = selectedName;
        detailsViewController.passedType = selectedType;
        detailsViewController.passedIngredients = selectedIngredients;
        detailsViewController.passedInstructions = selectedInstructions;
        detailsViewController.passedUsername = usernameString;
        detailsViewController.passedNotes = selectedNotes;
        detailsViewController.passedObjectID = selectedObjectID;
        detailsViewController.passedObject = selectedPFObject;
    }
    //Manually push details view
    [self.navigationController pushViewController:detailsViewController animated:YES];
}

# pragma mark - ActionSheet (sort)

//Create and sort action sheet
-(IBAction)showSortActionSheet:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Sort Recipes by:"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Active", @"Name", @"Type", @"Newest", @"Oldest", nil];
    
    [actionSheet showInView:self.view];
}

#pragma mark - PFLogInViewControllerDelegate

//These are defualt delegate methods for the Parse Login and are essentially unmodified. Added to get basic use of the login/signup framework Parse provides
// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    // Check if both fields are completed
    if (username && password && username.length && password.length) {
        [self performSelector:@selector(requestEventsAccess) withObject:nil afterDelay:0.5];
        return YES; // Begin login process
    }
    
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil) message:NSLocalizedString(@"Make sure you fill out all of the information!", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    return NO; // Interrupt login process
}

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in...");
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    NSLog(@"User dismissed the logInViewController");
}

#pragma mark - PFSignUpViewControllerDelegate

//These are defualt delegate methods for the Parse Signup and are essentially unmodified. Added to get basic use of the login/signup framework Parse provides
// Sent to the delegate to determine whether the sign up request should be submitted to the server.
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    BOOL informationComplete = YES;
    // loop through all of the submitted data
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if (!field || !field.length) { // check completion
            informationComplete = NO;
            break;
        }
    }
    
    // Display an alert if a field wasn't completed
    if (!informationComplete) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil) message:NSLocalizedString(@"Make sure you fill out all of the information!", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    }
    
    return informationComplete;
}

// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"Failed to sign up...");
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"User dismissed the signUpViewController");
}

#pragma mark - Search

//Delegate method triggered when search text is entered
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchString = searchController.searchBar.text;
    //Make sure somethinf was entered before attempting to filter results
    if (![searchString isEqualToString:@""]) {
        [self filterResults:searchString];
    }
}

//Filter query with search terms
-(void)filterResults:(NSString *)searchTerm {
    NSLog(@"filterResults");
    //Check if array exists, clear out if it does and alloc if not
    if (self.recipeSearchResults != nil) {
        //Clear out search results array
        [self.recipeSearchResults removeAllObjects];
    } else {
        self.recipeSearchResults = [[NSMutableArray alloc] init];
    }
    
    //Query with search term
    PFQuery *query = [PFQuery queryWithClassName: parseClassName];
    [query whereKey:@"createdBy" equalTo:[PFUser currentUser].username];
    //[query whereKey:@"Name" containsString:searchTerm];
    //Create case-insensitive query, "i" modifier sets this in regex
    [query whereKey:@"Name" matchesRegex:searchTerm modifiers:@"i"];
    
    //Grab searchbar textfield to apply color and border when no results found
    for (id object in [[[self.recipeSearchController.searchBar subviews] objectAtIndex:0] subviews]) {
        if ([object isKindOfClass:[UITextField class]]) {
            searchTextField = (UITextField *)object;
            break;
        }
    }
    
    //Query Parse in background for objects matching the search term
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error) {
            //Change color of serch textfield if no items match search
            if (objects.count == 0) {
                searchTextField.textColor = [UIColor redColor];
                searchTextField.layer.borderColor = [[UIColor redColor] CGColor];
                searchTextField.layer.borderWidth = 1.0;
            } else {
                searchTextField.textColor = [UIColor blackColor];
                searchTextField.layer.borderColor = [[UIColor whiteColor] CGColor];
                searchTextField.layer.borderWidth = 0.0;
            }
            //NSLog(@"Success in search query");
            NSLog(@"Success in search query, filterResults %lu", (unsigned long)objects.count);
            [self.recipeSearchResults addObjectsFromArray:objects];
            [self.tableView reloadData];
        } else {
            NSLog(@"search query error");
        }
    }];
}

//Cancel button on search bar clicked
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"Cancel button clicked");
    //Clear out search results array and resign first responder before reloading table
    [self.recipeSearchResults removeAllObjects];
    self.recipeSearchResults = nil;
    [searchBar resignFirstResponder];
    [self loadObjects];
    
    //Reset searchbar colors in case search produced no results.
    searchTextField.textColor = [UIColor blackColor];
    searchTextField.layer.borderColor = [[UIColor whiteColor] CGColor];
    searchTextField.layer.borderWidth = 0.0;
}

#pragma mark - Navigation
//didSelectRowAtIndexPath is used instead of prepare for segue

@end
