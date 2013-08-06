//
//  Place+Taken.h
//  Flickr
//
//  Created by Junbae Yoo on 2013-03-12.
//  Copyright (c) 2013 Junbae Yoo. All rights reserved.
//

#import "Place.h"

@interface Place (Taken)
+(Place *) insertPlace:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context;
+(void) removePlace:(Place *) place inManagedObjectContext:(NSManagedObjectContext *)context;
@end
