//
//  Tag+AttachedTo.h
//  Flickr
//
//  Created by Junbae Yoo on 2013-03-12.
//  Copyright (c) 2013 Junbae Yoo. All rights reserved.
//

#import "Tag.h"

@interface Tag (AttachedTo)
+(Tag *) insertTag:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context;
+(void) removeTag:(Tag *) tag inManagedObjectContext:(NSManagedObjectContext *)context;
@end
