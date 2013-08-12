//
//  RecentsViewController.h
//  Flickr
//
//  Created by Junbae Yoo on 2013-01-31.
//  Copyright (c) 2013 Junbae Yoo. All rights reserved.
//

#import <UIKit/UIKit.h>


/*
    This VC displays photos that users viewed recently.
    Photos viewed recently are saved in NSUserDefaults. The table only shows the last 20. 
    The images are not prefetched. Instead, photoInfo will be sent over to destination VC. 
    Also it will set the vacation for the photoViewerVC from NSUserDefault. 
    If none, it will set the vacation using default value and save to url.
    Note that the tableview is not refreshable.
    */
@interface RecentsViewController : UITableViewController
@end
