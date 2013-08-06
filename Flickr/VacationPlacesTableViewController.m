//
//  VacationPlacesTableViewController.m
//  Flickr
//
//  Created by Junbae Yoo on 2013-03-15.
//  Copyright (c) 2013 Junbae Yoo. All rights reserved.
//

#import "VacationPlacesTableViewController.h"
#import "VacationHelper.h"
#import "Photo.h"
#import "FlickrFetcher.h"
#import "PhotosViewController.h"

@interface VacationPlacesTableViewController ()
//@property (nonatomic, strong) UIManagedDocument *document;
@property (nonatomic, strong) NSSet *photos;
@property (nonatomic, strong) NSMutableDictionary *indexPathForCell;
@end

@implementation VacationPlacesTableViewController

-(NSMutableDictionary *) indexPathForCell
{
    if(!_indexPathForCell) {
        _indexPathForCell = [NSMutableDictionary dictionary];
    }
    return _indexPathForCell;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [VacationHelper openVacation:self.vacation usingBlock:^(UIManagedDocument *vacation) {
        NSFetchRequest *request= [NSFetchRequest fetchRequestWithEntityName:@"Place"];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:vacation.managedObjectContext  sectionNameKeyPath:nil
                                                                                       cacheName:nil];
        NSLog(@"[Places viewWillAppear]: fetchedObjects = %u", [self.fetchedResultsController.fetchedObjects count]);
        NSLog(@"[Places viewWillAppear]: numPhotos = %u", [[[self.fetchedResultsController.fetchedObjects lastObject] photos]count]);
    }];
    

}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"Itinerary Photo";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if(!cell) 
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Itinerary Photo"];
    }
    
    Place *place = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = place.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d photos", [place.photos count]];
    NSLog(@"[VacationPlacesVC cellForRowAtIndexPath] : place = %@, place.photos count = %u]", place.name, [place.photos count]);
    if(place && cell.textLabel.text) [self.indexPathForCell setObject:indexPath forKey:cell.textLabel.text];
//    NSLog(@"%@ %@", cell.textLabel.text, [self.indexPathForCell objectForKey:cell.textLabel.text]);
    
    
    return cell;
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.indexPathForCell objectForKey:[sender textLabel].text];
//    NSLog(@"%@", [sender textLabel].text);
//    NSLog(@"%@", indexPath);
    
    if([segue.identifier isEqualToString:@"showVacationFromPlaces"])
    {
        Place *place = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
       // NSArray *photosInCoreData = [self createArrayFromPhotos:place.photos];
      //  [segue.destinationViewController setPhotosInFlickr:photosInCoreData];
        [segue.destinationViewController setVacationPlace:place];
        [segue.destinationViewController setVacation:self.vacation];
      //  NSLog(@"VacationPlaces: place.photos = %@", photosInCoreData);
    }
}

@end
