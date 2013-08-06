//
//  Photo+Flickr.m
//  Flickr
//
//  Created by Junbae Yoo on 2013-03-09.
//  Copyright (c) 2013 Junbae Yoo. All rights reserved.
//

#import "Photo+Flickr.h"
#import "Tag+AttachedTo.h"
#import "Place+Taken.h"
#import "FlickrFetcher.h"
#import "VacationHelper.h"


@implementation Photo (Flickr)

//Takes array of Photo instances and returns array of dictionaries of each photo's attributes.
//The resulting array will follow the format of photos fetched directly from Flickr so that we can later use them in the same manner.
+(NSArray *) createArrayFromPhotos:(NSArray *)photos
{
    NSMutableArray *arr = [NSMutableArray array];
    for(Photo *photo in photos)
    {
        NSMutableDictionary *photoInfo = [NSMutableDictionary dictionary];
        // NSMutableDictionary *description = [NSMutableDictionary dictionary];
        [photoInfo setObject:photo.title forKey:FLICKR_PHOTO_TITLE];
        //[description setObject:photo.subtitle forKey:@"_content"];
        [photoInfo setObject:photo.subtitle forKey:FLICKR_PHOTO_DESCRIPTION];
        [photoInfo setObject:photo.unique forKey:FLICKR_PHOTO_ID];
        [arr addObject:photoInfo];
        
    }
    NSLog(@"Places createArrayFromPhotos: arr = %@", arr);
    return arr;
}

+(NSArray *) photosInManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    //place.insertdate instead of title?
    NSSortDescriptor *desc = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:desc];
    NSError *error;
    NSArray *photos = [context executeFetchRequest:request error:&error];
    if(error) {
        NSLog(@"Photo + Flickr: Core Data Error! %@", error);
        return 0;
    }
    NSLog(@"[Photo + Flickr photos]: %u photos found", [photos count]);
    return photos;
}

+(NSArray *) matchingPhotos:(NSDictionary *)photoInfo inManagedObjectContext:(NSManagedObjectContext *)context{
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", [photoInfo objectForKey:FLICKR_PHOTO_ID]];
    NSSortDescriptor *desc = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:desc];
    //Handle Data integrity Errors here
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];

    if(error) {
        NSLog(@"Photo + Flickr: Core Data Error! %@", error);
        return 0;
    }
    NSLog(@"[Photo + Flickr matchingPhotos]: %u match(es) found", [matches count]);
    return matches;
}

+(NSArray *) getCurrentPhotosForManagedObject:(id)entity InManagedObjectContext:(NSManagedObjectContext *)context {
    NSArray *resultArr = [NSArray array];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    if([entity isKindOfClass:[Place class]]) {
        Place *place = (Place *)entity;
        request.predicate = [NSPredicate predicateWithFormat:@"takenAt.name == %@", place.name];
    } else if([entity isKindOfClass:[Tag class]]) {
        Tag *tag = (Tag *)entity;
        //*********fetch all the photos with tagSet which includes tag.name
        request.predicate = [NSPredicate predicateWithFormat:@"ANY tags.name == %@", tag.name];
    }
    NSSortDescriptor *desc = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:desc];
    NSError *error;
    resultArr = [context executeFetchRequest:request error:&error];
    NSLog(@"Photo + Flickr: %u match(es) found", [resultArr count]);
    return resultArr;
}



+(void) insertPhoto :(NSDictionary *)photoInfo inManagedObjectContext:(NSManagedObjectContext *)context
{
    //Check to see if photo already exists in CoreData
    NSArray *matches = [Photo matchingPhotos:photoInfo inManagedObjectContext:context];
    
    //if photo is not in core data, INSERT photo
    if ([matches count] == 0){
        Photo *photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
        photo.title = [photoInfo objectForKey:FLICKR_PHOTO_TITLE];
        photo.subtitle = [photoInfo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
        photo.unique = [photoInfo objectForKey:FLICKR_PHOTO_ID];
        //tags. must not have a colon
        NSMutableSet *tagSet = [[NSMutableSet alloc] init];
        NSArray *tags = [[photoInfo objectForKey:FLICKR_TAGS] componentsSeparatedByString:@" "];
        for (NSString *tag in tags)
        {
            //Tag must not have a colon
            //Tag must not be empty.
            if ([tag rangeOfString:@":"].location == NSNotFound && ![tag isEqualToString:@""]) {
                [tagSet addObject:tag];
            }
        }
        //insert refined tags to coreData
        NSLog(@"[Photo+Flickr insertPhoto]:setOfTags name: %@", tagSet);
        for (NSString *tag in tagSet) {
            Tag *tagObj = [Tag insertTag:tag inManagedObjectContext:context];
            [photo addTagsObject:tagObj];
        }
        
        //Insert place
        photo.takenAt = [Place insertPlace:[photoInfo objectForKey:FLICKR_PHOTO_PLACE_NAME] inManagedObjectContext:context];
        NSLog(@"[Photo + Flickr insertPhoto] Photo  successfully inserted :%@", photo);
    } else {
        NSLog(@"Photo + Flickr insertPhoto] Photo already exists :%@", photoInfo);
    }
}

+(void) removePhoto :(NSDictionary *)photoInfo inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSArray *matches = [Photo matchingPhotos:photoInfo inManagedObjectContext:context];
    
    if ([matches count] == 1){
        Photo *photo = [matches lastObject];
        //Remove tag from core data if tag has no other photo attached
        NSSet *tags = photo.tags;
        for(Tag *tag in tags) {
            if ([tag.photosWithTag count] == 1) {
                [Tag removeTag:tag inManagedObjectContext:context];
            }
        }
        //Remove place from core data if place has no photo attached
        Place *place = photo.takenAt;
        if([place.photos count] == 1) {
            [Place removePlace:place inManagedObjectContext:context];
        }
        [context deleteObject:photo];
        NSLog(@"[Photo + Flickr removePhoto] Photo Removed :%@", [matches lastObject]);
    } else {
        NSLog(@"[Photo + Flickr removePhoto] Failed to remove from coreData");
    }
   
}


@end
