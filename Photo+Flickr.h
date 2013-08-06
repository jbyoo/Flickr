//
//  Photo+Flickr.h
//  Flickr
//
//  Created by Junbae Yoo on 2013-03-09.
//  Copyright (c) 2013 Junbae Yoo. All rights reserved.
//

#import "Photo.h"

@interface Photo (Flickr)

+(NSArray *) createArrayFromPhotos:(NSArray *)photos;
+(NSArray *) photosInManagedObjectContext:(NSManagedObjectContext *)context;
+(NSArray *) matchingPhotos :(NSDictionary *)photoInfo inManagedObjectContext :(NSManagedObjectContext *)context;
+(NSArray *) getCurrentPhotosForManagedObject:(id)entity InManagedObjectContext:(NSManagedObjectContext *)context;
+(void) insertPhoto :(NSDictionary *)photoInfo inManagedObjectContext :(NSManagedObjectContext *)context;
+(void) removePhoto :(NSDictionary *)photoInfo inManagedObjectContext :(NSManagedObjectContext *)context;
@end
