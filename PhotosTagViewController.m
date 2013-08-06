//
//  PhotosTagViewController.m
//  Flickr
//
//  Created by Junbae Yoo on 2013-02-28.
//  Copyright (c) 2013 Junbae Yoo. All rights reserved.
//

#import "PhotosTagViewController.h"
#import "PhotosViewController.h"
#import "VacationHelper.h"
#import "FlickrFetcher.h"
#import "Photo.h"

@interface PhotosTagViewController ()
@property (nonatomic, strong) NSMutableDictionary *indexPathForCell;
@end

@implementation PhotosTagViewController
@synthesize indexPathForCell = _indexPathForCell;

-(NSMutableDictionary *) indexPathForCell
{
    if(!_indexPathForCell) {
        _indexPathForCell = [NSMutableDictionary dictionary];
    }
    return _indexPathForCell;
}

-(void) setupFetchedResultsController
{
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [VacationHelper openVacation:self.vacation usingBlock:^(UIManagedDocument *vacation) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:vacation.managedObjectContext
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
        NSLog(@"[TagVC setupFetchedResultsController]: %u", [self.fetchedResultsController.fetchedObjects count]);
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"Tagged Photo";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Tagged Photo"];
    }
    Tag *tag = [self.fetchedResultsController objectAtIndexPath:indexPath];
    //Format : Capitalize first letter, exclude any tags with a colon in them
    if([tag.name length] && [tag.name rangeOfString:@":"].location == NSNotFound) {
        cell.textLabel.text = [tag.name stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[tag.name substringToIndex:1] uppercaseString]];
    }
    NSLog(@"%@", tag);
    cell.detailTextLabel.text = [NSString stringWithFormat:(@"%d photos"), [tag.photosWithTag count]];
    if(tag && cell.textLabel.text) [self.indexPathForCell setObject:indexPath forKey:cell.textLabel.text];
    return cell;
}


////Takes set of Photo instances and returns array of dictionaries of each photo's attributes.
//-(NSArray *) createArrayFromPhotos:(NSSet *)photos
//{
//    NSMutableArray *arr = [NSMutableArray array];
//    for(Photo *photo in photos)
//    {
//        NSMutableDictionary *photoInfo = [NSMutableDictionary dictionary];
//        // NSMutableDictionary *description = [NSMutableDictionary dictionary];
//        [photoInfo setObject:photo.title forKey:FLICKR_PHOTO_TITLE];
//        //[description setObject:photo.subtitle forKey:@"_content"];
//        [photoInfo setObject:photo.subtitle forKey:FLICKR_PHOTO_DESCRIPTION];
//        [photoInfo setObject:photo.unique forKey:FLICKR_PHOTO_ID];
//        [arr addObject:photoInfo];
//        
//    }
//    NSLog(@"[PhotosTagVC createArrayFromPhotos]: arr = %@", arr);
//    return arr;
//}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.indexPathForCell objectForKey:[sender textLabel].text];
    //    NSLog(@"%@", [sender textLabel].text);
    //    NSLog(@"%@", indexPath);
    
    if([segue.identifier isEqualToString:@"showPhotoFromTag"])
    {
        Tag *tag = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
//        NSArray *photosInCoreData = [self createArrayFromPhotos:tag.photosWithTag];
//        [segue.destinationViewController setPhotosInFlickr:photosInCoreData];
        [segue.destinationViewController setVacationTag:tag];
        [segue.destinationViewController setVacation:self.vacation];
//        NSLog(@"VacationPlaces: tag.photos = %@", photosInCoreData);
    }
}



@end
