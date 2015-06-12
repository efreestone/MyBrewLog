//
//  ViewController.m
//  MyBrewLogIngredientsUpdate
//
//  Created by Elijah Freestone on 6/11/15.
//  Copyright (c) 2015 Elijah Freestone. All rights reserved.
//

#import "ViewController.h"
#import <Parse/Parse.h>

@interface ViewController () {
    NSArray *berriesArray;
    NSArray *fruitsArray;
    NSArray *vegetablesArray;
    NSArray *grainsAndHopsArray;
    NSArray *maltsAndSugarsArray;
    NSArray *yeastArray;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //Set arrays for ingredients
    berriesArray = [NSArray arrayWithObjects:@"Berries 1", @"Berries 2", @"Berries 3", @"Berries 4",  @"Other", nil];
    
    fruitsArray = [NSArray arrayWithObjects:@"Fruit 1", @"Fruit 2", @"Fruit 3", @"Fruit 4", @"Fruit 5", @"Fruit 6", @"Fruit 7", @"Fruit 8", @"Other", nil];
    
    vegetablesArray = [NSArray arrayWithObjects:@"Vegetable 1", @"Vegetable 2", @"Vegetable 3", @"Vegetable 4",  @"Other", nil];
    
    grainsAndHopsArray = [NSArray arrayWithObjects:@"Grains & Hops 1", @"Grains & Hops 2", @"Grains & Hops 3", @"Grains & Hops 4", @"Grains & Hops 5", @"Other", nil];
    
    maltsAndSugarsArray = [NSArray arrayWithObjects:@"Malts & Sugars 1", @"Malts & Sugars 2", @"Malts & Sugars 3", @"Malts & Sugars 4", @"Malts & Sugars 5", @"Malts & Sugars 6", @"Other", nil];
    
    yeastArray = [NSArray arrayWithObjects:@"Yeast 1", @"Yeast 2", @"Yeast 3", @"Other", nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)updateIngredients:(id)sender {
    PFObject *ingredientsObject = [PFObject objectWithClassName:@"Ingredients"];
    ingredientsObject[@"berriesArray"] = berriesArray;
    ingredientsObject[@"fruitsArray"] = fruitsArray;
    ingredientsObject[@"vegetablesArray"] = vegetablesArray;
    ingredientsObject[@"grainsAndHopsArray"] = grainsAndHopsArray;
    ingredientsObject[@"maltsAndSugarsArray"] = maltsAndSugarsArray;
    ingredientsObject[@"yeastArray"] = yeastArray;
    
    [ingredientsObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Ingredients saved.");
            //Dismiss add item view
            //            [self dismissViewControllerAnimated:YES completion:nil];
            //            [self.myRecipeVC refreshTable];
        } else {
            NSLog(@"%@", error);
            //Error alert
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"An error occured trying to save. Please try again.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
        }
    }];
}

@end
