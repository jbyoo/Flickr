//
//  PhotoViewerViewController.h
//  Flickr
//
//  Created by Junbae Yoo on 2013-02-04.
//  Copyright (c) 2013 Junbae Yoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChooseVacationViewController.h"


/*
    This view is designed to show the image given informations from previous VC in the navigation stack.
    The imageview is processed to fit the screen size and is also scrollable.
    User can choose to save photo in a certain document by 'visit'ing the photo. 
    It will give option to use current vacation document or choose another vacation, and if so modally segue to ChooseVacationVC.
    If the photo is already 'visit'ed and stored in current vacation, BarButtonItem on the bar at the top will become 
    'unvisit'. If user clicks to 'unvisit' the photo, it will be removed from current document.
 */
@interface PhotoViewerViewController : UIViewController <UIAlertViewDelegate, ChooseVacationViewControllerDelegate>
@property (nonatomic, strong) NSDictionary *photo;
@property (nonatomic, strong) NSString *vacation;
@end
