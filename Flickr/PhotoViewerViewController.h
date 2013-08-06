//
//  PhotoViewerViewController.h
//  Flickr
//
//  Created by Junbae Yoo on 2013-02-04.
//  Copyright (c) 2013 Junbae Yoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChooseVacationViewController.h"
@interface PhotoViewerViewController : UIViewController <UIAlertViewDelegate, ChooseVacationViewControllerDelegate>
@property (nonatomic, strong) NSDictionary *photo;
@property (nonatomic, strong) NSString *vacation;
@end
