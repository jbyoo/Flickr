//
//  TopPlacesViewController.m
//  Flickr
//
//  Created by Junbae Yoo on 2013-01-30.
//  Copyright (c) 2013 Junbae Yoo. All rights reserved.
//

#import "TopPlacesViewController.h"
#import "FlickrFetcher.h"
#import "PhotosViewController.h"
#import "VacationHelper.h"

@interface TopPlacesViewController ()
@property (nonatomic, strong) NSMutableDictionary *placeForCellIndexPath;       // { (NSIndexPath *) indexpath : (NSDictionary *) placeInfo }
                                                                                // Maps place information to indexpath of the cell to pass it over in prepareForSegue
@end

@implementation TopPlacesViewController


-(NSMutableDictionary *) placeForCellIndexPath
{
    if(!_placeForCellIndexPath) _placeForCellIndexPath = [NSMutableDictionary dictionary];
    return _placeForCellIndexPath;
}


#pragma mark - ViewController Life Cycle

-(void)viewDidLoad
{
    [super viewDidLoad];
    if(![[NSUserDefaults standardUserDefaults] objectForKey:NSUSERDEFAULT_CURR_VACATION_KEY]) {
        //If vacation is not saved in NSUserDefaults either, then we create a new vacation.
        [[NSUserDefaults standardUserDefaults] setObject:DEFAULT_VACATION forKey:NSUSERDEFAULT_CURR_VACATION_KEY];
    }
}

-(void) retrieveData
{
    //Load array of places from Flickr
    dispatch_queue_t queue = dispatch_queue_create("place", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        self.places = [FlickrFetcher topPlaces];
        dispatch_async(dispatch_get_main_queue(), ^{
            if([self.places count] == 0) { NSLog(@"[TopPlacesViewController retrieveData]: Error fetching the top places from Flickr.");}
            //Sort the array
            if([self.places count] >1) {
                self.places = [self.places sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                    NSString *first = [a objectForKey:FLICKR_PLACE_NAME];
                    NSString *second = [b objectForKey:FLICKR_PLACE_NAME];
                    return [first compare:second];
                }];
            }
            [self didEndRetrievingData:self.tableView];
        });
        
    });
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.places count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"Popular Place Description";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary *placeInfo = self.places[indexPath.row];
    [self.placeForCellIndexPath setObject:placeInfo forKey:indexPath];
    NSString *place = [placeInfo objectForKey:FLICKR_PLACE_NAME];
    
    //Edit place name for title and subtitle of the cell
    NSArray *listOfSubstrings = [place componentsSeparatedByString:@","];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Popular Place Description"];
    }
    cell.textLabel.text = [listOfSubstrings objectAtIndex:0];
    cell.detailTextLabel.text = [place substringFromIndex:[cell.textLabel.text length]+2];
    
    return cell;
}

#pragma mark - Table view delegate

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Show List of Photos"]) {
            NSIndexPath *indexpath = [self.tableView indexPathForCell:sender];
            NSDictionary *place = [self.placeForCellIndexPath objectForKey:indexpath];
           [segue.destinationViewController setPlace:place];
    }
}

@end
