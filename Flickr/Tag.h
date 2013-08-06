//
//  Tag.h
//  Flickr
//
//  Created by Junbae Yoo on 2013-04-11.
//  Copyright (c) 2013 Junbae Yoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo;

@interface Tag : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * numPhotos;
@property (nonatomic, retain) NSSet *photosWithTag;
@end

@interface Tag (CoreDataGeneratedAccessors)

- (void)addPhotosWithTagObject:(Photo *)value;
- (void)removePhotosWithTagObject:(Photo *)value;
- (void)addPhotosWithTag:(NSSet *)values;
- (void)removePhotosWithTag:(NSSet *)values;

@end
