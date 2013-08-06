//
//  AddVacationViewController.h
//  Flickr
//
//  Created by Junbae Yoo on 2013-07-18.
//  Copyright (c) 2013 Junbae Yoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VacationHelper.h"



@interface AddVacationViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSString *vacation;
@end
