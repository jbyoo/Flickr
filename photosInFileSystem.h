//
//  photosInFileSystem.h
//  Flickr
//
//  Created by Junbae Yoo on 2013-02-19.
//  Copyright (c) 2013 Junbae Yoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface photosInFileSystem : NSObject

//  This method saves the photo data into file system.
//  The file directory size does not excees 10MB. This is accomplished by deleting oldest image files in the system.
+ (void) writeIntoFileSystem:(NSDictionary *)photo withData: (NSData *)data;

//  This method searches for a photo with same ID in the files in NSCacheDirectory and returns the image.
+ (UIImage *) getPhotoFromFileSystem: (NSString *)idForPhoto;
@end
