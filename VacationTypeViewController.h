//
//  VacationTypeViewController.h
//  Flickr
//
//  Created by Junbae Yoo on 2013-03-01.
//  Copyright (c) 2013 Junbae Yoo. All rights reserved.
//

#import <UIKit/UIKit.h>
/*
    Static tableview. Vacation is set from previous VC in the navigation stack. 
    User can choose to click to view the list of places or tags available in the vacation.
 */
@interface VacationTypeViewController : UITableViewController
@property (nonatomic, strong) NSString *vacation;
@end
