//
//  VacationPlacesTableViewController.h
//  Flickr
//
//  Created by Junbae Yoo on 2013-03-15.
//  Copyright (c) 2013 Junbae Yoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"


/*
    This VC shows all the places associated with photos in given vacation document.
    See CoreDataTableViewController for details on how fetching works.
 */
@interface VacationPlacesTableViewController : CoreDataTableViewController
@property (nonatomic, strong) NSString *vacation;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@end
