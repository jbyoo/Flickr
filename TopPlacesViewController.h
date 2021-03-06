//
//  TopPlacesViewController.h
//  Flickr
//
//  Created by Junbae Yoo on 2013-01-30.
//  Copyright (c) 2013 Junbae Yoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RefreshableTableViewController.h"


/*
    This VC follows standard refreshable tableview behavior that is implemented throughout the app.
 */
@interface TopPlacesViewController : RefreshableTableViewController
@property (nonatomic, strong) NSArray *places; // contains 50 most popular geological spots in Flickr
@end
