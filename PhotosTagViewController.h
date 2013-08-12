//
//  PhotosTagViewController.h
//  Flickr
//
//  Created by Junbae Yoo on 2013-02-28.
//  Copyright (c) 2013 Junbae Yoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"


/*
 This VC shows all the tags associated with photos in given vacation document.
 See CoreDataTableViewController for details on how fetching works.
 */
@interface PhotosTagViewController : CoreDataTableViewController
@property (nonatomic, strong) NSString *vacation;
@end
