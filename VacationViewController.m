//
//  VacationViewController.m
//  Flickr
//
//  Created by Junbae Yoo on 2013-02-28.
//  Copyright (c) 2013 Junbae Yoo. All rights reserved.
//

#import "VacationViewController.h"
#import "VacationHelper.h"
#import "FlickrFetcher.h"
#import "VacationTypeViewController.h"
#import "AddVacationViewController.h"

@interface VacationViewController ()
@property (nonatomic, strong) NSArray *vacationsList;
@end

@implementation VacationViewController


// Only access managedObjectContext in PerformBlock or the same thread!!(not relevent to this assignment)
// Don't forget prepareForDeletion when deleting objects in core data
// Make sure theres no strong pointer when object is deleted
// Problems might occur when schema is changed after launching. Delete the app and restart
// in Visit button make sure to save my saveToURL:forSaveOperation...
// When user unvisits on 'vacation' make sure to pop the current view controller

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateVacations];
}


-(void)viewDidLoad
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(Add:)];
}

-(IBAction)Add:(id)sender
{
    [self performSegueWithIdentifier:@"AddVacation" sender:self];
}

-(void) updateVacations
{
    [VacationHelper getVacationsUsingBlock:^(NSArray *vacationList) {
        _vacationsList = vacationList;
        [self.tableView reloadData];
    }];
}

-(NSArray *) vacationsList{
    if(!_vacationsList) {
        _vacationsList = [NSArray array];
    }
    return _vacationsList;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.vacationsList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"Vacation Item";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    // Configure the cell...
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [self.vacationsList objectAtIndex:[indexPath row]];
    return cell;
}
#pragma mark - Table view delegate


//Persistence Lecture : Best way to send the string(or doc) over pushed VCs?
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell *)sender
{
    NSString *vacation = [self.vacationsList objectAtIndex:[[self.tableView indexPathForCell:sender] row]];
    [[NSUserDefaults standardUserDefaults] setObject:vacation forKey:NSUSERDEFAULT_CURR_VACATION_KEY];
    [segue.destinationViewController setVacation:vacation];
    
}

@end
