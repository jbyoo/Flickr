//
//  VacationPlacesTableViewController.h
//  Flickr
//
//  Created by Junbae Yoo on 2013-03-15.
//  Copyright (c) 2013 Junbae Yoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"


@interface VacationPlacesTableViewController : CoreDataTableViewController
@property (nonatomic, strong) NSString *vacation;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@end
