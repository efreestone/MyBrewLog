// Elijah Freestone
// My Brew Log V1.0
// May 7th, 2015

//
//  BrowseViewController.h
//  MyBrewLog
//
//  Created by Elijah Freestone on 5/7/15.
//  Copyright (c) 2015 Elijah Freestone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>

@interface BrowseViewController : PFQueryTableViewController

//Declare table view
@property (strong, nonatomic) IBOutlet UITableView *browseTableView;

@property (nonatomic, strong) UISearchController *browseSearchController;
@property (nonatomic, strong) NSMutableArray *browseSearchResults;

-(void)refreshTable:(int)withSort;

@end
