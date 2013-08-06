//
//  RecentsViewController.m
//  Flickr
//
//  Created by Junbae Yoo on 2013-01-31.
//  Copyright (c) 2013 Junbae Yoo. All rights reserved.
//

#import "RecentsViewController.h"
#import "FlickrFetcher.h"
#import "PhotoViewerViewController.h"
#import "VacationHelper.h"
#import "PhotosViewController.h"

@interface RecentsViewController ()

@property (nonatomic, strong) NSArray *recentPhotos;
@property (nonatomic, strong) NSString *vacation;
@end

@implementation RecentsViewController


- (void) viewWillAppear:(BOOL)animated
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *recents = [defaults objectForKey:RECENT_PHOTOS_KEY];
    if(!recents) recents = [NSMutableArray array];
    self.recentPhotos = [recents copy];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
    [super viewWillAppear:animated];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSInteger count = [self.recentPhotos count];
    return count > 20? 20 : count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Recent Photo";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [[self.recentPhotos objectAtIndex:indexPath.row] objectForKey:FLICKR_PHOTO_TITLE];
    
    
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = [[self.recentPhotos objectAtIndex:indexPath.row] objectForKey:FLICKR_PHOTO_TITLE];
    cell.detailTextLabel.text = [[self.recentPhotos objectAtIndex:indexPath.row] valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
 
    if([cell.textLabel.text length] == 0) {
        cell.textLabel.text = cell.detailTextLabel.text;
        if([cell.detailTextLabel.text length] == 0) {
            cell.textLabel.text = @"Unknown";
        }
    } 
    return cell;
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    //NSLog(@"%@", [self.photos objectAtIndex:indexPath.row]);
    
    [segue.destinationViewController setPhoto:[self.recentPhotos objectAtIndex:indexPath.row]];
    if(!self.vacation) {
        //Fetch vacation from NSUserDefaults
        self.vacation = [[NSUserDefaults standardUserDefaults] objectForKey:NSUSERDEFAULT_CURR_VACATION_KEY];
        if(!self.vacation) {
            //If vacation is not saved in NSUserDefaults either, then we create a new vacation.
            self.vacation = DEFAULT_VACATION;
            [VacationHelper saveVacation:_vacation usingBlock:^(UIManagedDocument *vacation) {
                [segue.destinationViewController setVacation:self.vacation];
                [[NSUserDefaults standardUserDefaults] setObject:DEFAULT_VACATION forKey:NSUSERDEFAULT_CURR_VACATION_KEY];
            }];
        } else {
            [segue.destinationViewController setVacation:self.vacation];
        }
    }
}

@end
