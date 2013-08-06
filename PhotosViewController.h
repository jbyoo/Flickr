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


#define RECENT_PHOTOS_KEY @"PhotosViewController.RecentPhotos"
@interface PhotosViewController : RefreshableTableViewController
@property (nonatomic, strong) NSDictionary *place;
@property (nonatomic, strong) Place *vacationPlace;
@property (nonatomic, strong) Tag *vacationTag;
@property (nonatomic, strong) NSString *vacation;

@end
