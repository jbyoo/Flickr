//
//  PhotosViewController.h
//  Flickr
//
//  Created by Junbae Yoo on 2013-02-02.
//  Copyright (c) 2013 Junbae Yoo. All rights reserved.
//

#import "TopPlacesViewController.h"
#import "RefreshableTableViewController.h"
#import "CoreDataTableViewController.h"
#import "Place.h"
#import "Tag.h"

/*
    This VC follows standard refreshable tableview behavior that is implemented throughout the app.
    This VC shows list of photos for different occasions based on values of the properties.
    1.  From TopPlacesVC: shows photos given information about the place.
        List of photos is fetched dynamically over the network.
    2.  From VacationPlacesTableVC: shows photos taken at given place in current vacation document
    3.  From VacationTagsTableVC: shows photos with given tags in current vacation document
    
    In any of the cases, latency is expected as we are fetching data over network or accessing core data using UIManagedDocument.
 */

#define RECENT_PHOTOS_KEY @"PhotosViewController.RecentPhotos"
@interface PhotosViewController : RefreshableTableViewController
@property (nonatomic, strong) NSDictionary *place;
@property (nonatomic, strong) Place *vacationPlace;
@property (nonatomic, strong) Tag *vacationTag;
@property (nonatomic, strong) NSString *vacation;

@end
