//
//  RefreshableTableViewController.h
//  Flickr
//
//  Created by Junbae Yoo on 2013-07-10.
//  Copyright (c) 2013 Junbae Yoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RefreshableTableViewController : UITableViewController

-(void)retrieveData;    //  abstract. Implement data fetching activities in here from subclasses.
-(void)didEndRetrievingData:(UITableView *)tableView;   //  This class must be called by the subclass when data fetching is finished.
                                                        //  Pass in the tableview pointer to reload the table
@end
