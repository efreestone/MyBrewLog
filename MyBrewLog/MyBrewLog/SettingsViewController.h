// Elijah Freestone
// My Brew Log V1.0
// May 7th, 2015

//
//  SettingsViewController.h
//  MyBrewLog
//
//  Created by Elijah Freestone on 5/7/15.
//  Copyright (c) 2015 Elijah Freestone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyRecipeViewController.h"

@interface SettingsViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UIButton *logOutButton;
@property (strong, nonatomic) IBOutlet UIButton *editUserButton;
@property (strong, nonatomic) IBOutlet UIButton *infoButton;

@property (strong, nonatomic) IBOutlet UISwitch *autoSyncSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *editRecipeSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *publicSwitch;
@property (strong, nonatomic) IBOutlet UISegmentedControl *unitsSegment;

-(IBAction)unitsSegmentIndexChanged:(id)sender;

@end
