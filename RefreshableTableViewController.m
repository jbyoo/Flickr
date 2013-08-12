//
//  RefreshableTableViewController.m
//  Flickr
//
//  Created by Junbae Yoo on 2013-07-10.
//  Copyright (c) 2013 Junbae Yoo. All rights reserved.
//

//  This is a general Refreshable UITableViewController from which ViewControllers with a tableview may subclass.
//  ViewControllers which inherits from this class must implement retrieveData class
//  Inside of retrieveData class, you must call didEndRetrievingData class when data loading is finished.
//  If the data is getting fetched in another thread, i.e. it is an asynchronous call, put didEndRetrievingData in its completion block

#import "RefreshableTableViewController.h"

@interface RefreshableTableViewController ()
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@end

@implementation RefreshableTableViewController

-(void) viewDidLoad
{
    [super viewDidLoad];
    [self setupRefreshControl];
}

-(void) setupRefreshControl
{
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self
                       action:@selector(refreshControlRequest)
             forControlEvents:UIControlEventValueChanged];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Updating table.."];
    [self setRefreshControl:refreshControl];
}

-(void)refreshControlRequest
{
    [self performSelector:@selector(updateTableView)];
}

-(void) updateTableView
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, h:mm:ss a"];
    NSString *lastUpdate = [NSString stringWithFormat:@"Last updated on date: %@", [formatter stringFromDate:[NSDate date]]];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdate];
    [self retrieveData];
    [self.refreshControl endRefreshing];
}

//  Child VC must override this method to refresh the data
//  Must stop spinners and Network Activity Indicator here (started in [self viewWillAppear])
-(void) retrieveData
{
    //abstract
}

#define SPINNER_SIDE_LENGTH 40

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //  Add spinner and start animating
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.frame = CGRectMake(self.tableView.bounds.size.width/2 - SPINNER_SIDE_LENGTH/2,
                               self.tableView.bounds.size.height/2 - SPINNER_SIDE_LENGTH/2,
                               SPINNER_SIDE_LENGTH,
                               SPINNER_SIDE_LENGTH);
    [self.spinner startAnimating];
    [self.tableView addSubview:self.spinner];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self retrieveData];
}

-(void)didEndRetrievingData:(UITableView *)tableView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.spinner stopAnimating];
    [tableView reloadData];
}


@end
