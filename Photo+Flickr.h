//
//  Photo+Flickr.h
//  Flickr
//
//  Created by Junbae Yoo on 2013-03-09.
//  Copyright (c) 2013 Junbae Yoo. All rights reserved.
//

#import "Photo.h"

@interface Photo (Flickr)

/*
    This method takes array of Photo instances and returns array of dictionaries of each photo's attributes.
    The resulting array will follow the format of photos fetched directly from Flickr so that we can later use them in the same manner.
 */
+(NSArray *) createArrayFromPhotos:(NSArray *)photos;

/*
    This method fetches array of all photo instances from core data.
 */
+(NSArray *) photosInManagedObjectContext:(NSManagedObjectContext *)context;

/*
    This method returns array of photos with a certain ID given as a member of photoInfo. 
    Since the ID is unique, the count of returned NSArray is 0 or 1. 
   
    @Discussion: Does it ever return an array of size bigger than 1?
 */
+(NSArray *) matchingPhotos :(NSDictionary *)photoInfo
     inManagedObjectContext :(NSManagedObjectContext *)context;

/*
    This method returns array of photos that has a certain tag or taken at a certain place.
    The fetch request takes different predicate depending on the class of the entity(Tag or Place).
 */
+(NSArray *) getCurrentPhotosForManagedObject:(id)entity    //returns array of photos for given entity.(Tag or Place)
                       InManagedObjectContext:(NSManagedObjectContext *)context;

/*
    This method inserts a photo information into core data.
    If a photo with same ID exists in core data, do nothing.
    The argument photoInfo has title, subtitle, unique, tag and place. Null value is allowed for any input since they are all optional
 
    @Discussion: Should some of the properties be required?
 */
+(void) insertPhoto :(NSDictionary *)photoInfo inManagedObjectContext :(NSManagedObjectContext *)context;


/*
    This method removes photo from Core data. 
    If no photo with ID given in photoInfo exists, do nothing.
    It also removes associated Tag and/or Place from core data if the number of photo becomes 0 for the particular entity.
 */
+(void) removePhoto :(NSDictionary *)photoInfo inManagedObjectContext :(NSManagedObjectContext *)context;
@end
