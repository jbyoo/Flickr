//
//  Tag+AttachedTo.m
//  Flickr
//
//  Created by Junbae Yoo on 2013-03-12.
//  Copyright (c) 2013 Junbae Yoo. All rights reserved.
//

#import "Tag+AttachedTo.h"
#import "VacationHelper.h"

@implementation Tag (AttachedTo)
+(Tag *) insertTag:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context
{
    //check if photo exists in core data by making fetchrequest
   
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
    NSSortDescriptor *desc = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:desc];
    
    NSError *error;
//    NSLog(@"Tag: %@", document.description);
    NSArray *matches = [context executeFetchRequest:request error:&error];
    Tag *tag;
    if(!matches || [matches count]> 1) {
        //handle error
    }else if ([matches count] == 0) {
        tag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:context];
        tag.name = name;
        NSLog(@"[Tag+Attached insertTag]: Tag successfully inserted : %@", tag);
    } else if ([matches count] == 1){
        tag = [matches lastObject];
        NSLog(@"[Tag+Attached insertTag]: Tag already exists :%@", tag);
    }
    return tag;
}


+(void) removeTag:(Tag *) tag inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSLog(@"[Tag + AttachedTo] Tag Removed: %@", tag);
    [context deleteObject:tag];
}


@end
