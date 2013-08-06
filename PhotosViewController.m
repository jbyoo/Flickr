//
//  PhotosViewController.m
//  Flickr
//
//  Created by Junbae Yoo on 2013-02-02.
//  Copyright (c) 2013 Junbae Yoo. All rights reserved.
//

#import "PhotosViewController.h"
#import "FlickrFetcher.h"
#import "Photo+Flickr.h"
#import "PhotoViewerViewController.h"
#import "VacationHelper.h"

@interface PhotosViewController ()
@property (nonatomic, strong) NSMutableDictionary *idForRow;        //(NSIndexPath *) indexPath : (NSString *) photoID

@property (nonatomic, strong) NSArray *photosInFlickr; //of most popular spots in Flickr
@end

@implementation PhotosViewController

#define MAX_NUM_PHOTOS 50

-(NSMutableDictionary *)idForRow
{
    if(!_idForRow) {
        _idForRow = [[NSMutableDictionary alloc] init];
    }
    return _idForRow;
}


-(void) retrieveData
{
    //  Fetch array of photos of given place from Flickr server.
    //  ParentVC == TopPlacesVC.
    if(self.place) {
        dispatch_queue_t queue = dispatch_queue_create("photos", DISPATCH_QUEUE_SERIAL);
        dispatch_async(queue, ^{
            NSArray *photos = [FlickrFetcher photosInPlace:self.place maxResults:MAX_NUM_PHOTOS];
            dispatch_async(dispatch_get_main_queue(), ^{
                if([photos count] == 0) { NSLog(@"[PhotosViewController retrieveData] :Error fetching top places from Flickr.");}
                self.photosInFlickr = photos;
                [self didEndRetrievingData:self.tableView];
            });
            
        });
    } else {
        // Load array of photos from core data.
        //  Fetch predicate depends on how we arrived at this VC.
        //  If parentVC == VacationPlacesVC in the navigation controller stack, self.vacationPlace is set.
        //  If parentVC == VacationTagVC                                        self.vacationTag is set
        NSManagedObject *obj;
        if(self.vacationPlace) {
            obj = self.vacationPlace;
        } else if (self.vacationTag) {
            obj = self.vacationTag;
        }
        [VacationHelper openVacation:self.vacation usingBlock:^(UIManagedDocument *vacation) {
            NSArray *photos = [Photo getCurrentPhotosForManagedObject:obj InManagedObjectContext:vacation.managedObjectContext];
            self.photosInFlickr = [Photo createArrayFromPhotos:photos];
            NSLog(@"[PhotosVC retrieveData]: %@", self.photosInFlickr);
            if(![self.photosInFlickr count]) {
                UIAlertView *msg = [[UIAlertView alloc] initWithTitle:@"No photos to display." message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [msg show];
            }
            [self didEndRetrievingData:self.tableView];
        }];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.vacationPlace.name) {
        self.title = self.vacationPlace.name;
    } else if (self.vacationTag.name) {
        self.title = self.vacationTag.name;
    } else if ([self.place valueForKey:FLICKR_PLACE_NAME])  {
        NSArray *listOfSubstrings = [[self.place valueForKey:FLICKR_PLACE_NAME] componentsSeparatedByString:@","];
        self.title =  [listOfSubstrings objectAtIndex:0];
    } else {
        self.title = @"Photos";
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.photosInFlickr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Photo Details";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell..
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Photo Details"];
    }
    self.idForRow[indexPath] = self.photosInFlickr[indexPath.row][FLICKR_PHOTO_ID];
    
    //  Set text for title and subtitle of the cell.
    cell.textLabel.text = [[self.photosInFlickr objectAtIndex:indexPath.row] objectForKey:FLICKR_PHOTO_TITLE];
    cell.detailTextLabel.text = [[self.photosInFlickr objectAtIndex:indexPath.row] valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
    
    if([cell.textLabel.text length] == 0) {
        cell.textLabel.text = cell.detailTextLabel.text;
        if([cell.detailTextLabel.text length] == 0) {
            cell.textLabel.text = @"Unknown";
        }
    }
    return cell;
}


#pragma mark - Table view delegate

//Save photos about to be displayed to in recent photos array in NSUserDefaults

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *recentPhotos = [[defaults objectForKey:RECENT_PHOTOS_KEY] mutableCopy];
    if(!recentPhotos) recentPhotos = [NSMutableArray array];
    BOOL duplicatePhoto = NO;
    
    if(!self.idForRow[indexPath]) {
        NSLog(@"[PhotosViewVC tableViewDidSelectRowAtIndexPath] : No photoID for indexPath of selected cell.");
    }
    
    //see if duplicate ID exists in recent photos array in NSUserDefaults
    for(NSDictionary *photoInfo in recentPhotos) {
        if([photoInfo[FLICKR_PHOTO_ID] isEqualToString:self.idForRow[indexPath]])
        {
            duplicatePhoto = YES;
        }
    }
    //Update recent photos array in NSUserDefaults
    if(!duplicatePhoto && self.photosInFlickr[indexPath.row]) {
        [recentPhotos insertObject:self.photosInFlickr[indexPath.row] atIndex:0];
        [defaults setObject:[recentPhotos copy] forKey:RECENT_PHOTOS_KEY];
    } else if(duplicatePhoto){
        NSLog(@"[PhotosViewVC tableViewDidSelectRowAtIndexPath] :Photo already exists in recents tab.");
    }
    [defaults synchronize];
}


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Show Image"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        [segue.destinationViewController setPhoto:[self.photosInFlickr objectAtIndex:indexPath.row]];
        NSString *seguedVacation = self.vacation;
        if(!seguedVacation) {
            //Fetch vacation from NSUserDefaults
            seguedVacation = [[NSUserDefaults standardUserDefaults] objectForKey:NSUSERDEFAULT_CURR_VACATION_KEY];
            if(!seguedVacation) {
                //If vacation is not saved in NSUserDefaults either, then we create a new vacation.
                seguedVacation = DEFAULT_VACATION;
                [VacationHelper saveVacation:seguedVacation usingBlock:^(UIManagedDocument *vacation) {
                    [segue.destinationViewController setVacation:seguedVacation];
                    [[NSUserDefaults standardUserDefaults] setObject:seguedVacation forKey:NSUSERDEFAULT_CURR_VACATION_KEY];
                }];
            } else {
                [segue.destinationViewController setVacation:seguedVacation];
            }
        }
    }
}


@end
