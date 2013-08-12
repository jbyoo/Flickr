//
//  Place+Taken.m
//  Flickr
//
//  Created by Junbae Yoo on 2013-03-12.
//  Copyright (c) 2013 Junbae Yoo. All rights reserved.
//

#import "Place+Taken.h"
#import "VacationHelper.h"


@implementation Place (Taken)
+(Place *) insertPlace:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context  {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Place"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
    NSSortDescriptor *asc = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:asc];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    Place *place;
    if(!matches || [matches count]> 1) {
        //handle error
        if(error) {
            NSLog(@"[Place+Taken insertPlace]: FetchRequest resulted in error, %@", error);
        } else {
            NSLog(@"[Place+Taken insertPlace]: Data is corrupted.");
        }
    }else if ([matches count] == 0) {
        //Place with given name does not exists.
        place = [NSEntityDescription insertNewObjectForEntityForName:@"Place" inManagedObjectContext:context];
        place.name = name;
        [place setValue:[NSDate date] forKey:@"date"];
        NSLog(@"[Place+Taken insertPlace]: Place successfully inserted : %@", place);
    } else if ([matches count] == 1) {
        //Place with given name already exists.
        place = [matches lastObject];
        NSLog(@"[Place+Taken insertPlace]: Place already exists :%@", place);
    }
    return place;
}

+(void) removePlace:(Place *) place inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSLog(@"[Place + Taken] Place Removed: %@", place);
    [context deleteObject:place];
    
}

@end
