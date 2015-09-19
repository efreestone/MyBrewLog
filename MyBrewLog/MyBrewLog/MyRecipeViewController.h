// Elijah Freestone
// My Brew Log V1.0
// May 7th, 2015

//
//  MyRecipeViewController.h
//  MyBrewLog
//
//  Created by Elijah Freestone on 5/7/15.
//  Copyright (c) 2015 Elijah Freestone. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <ParseUI/ParseUI.h>

@interface MyRecipeViewController : PFQueryTableViewController

//Declare table view
@property (strong, nonatomic) IBOutlet UITableView *myTableView;

@property (nonatomic, strong) UISearchController *recipeSearchController;
@property (nonatomic, strong) NSMutableArray *recipeSearchResults;

-(void)refreshTable;
-(void)checkIngredientsForUpdate;

@end
