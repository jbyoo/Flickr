//
//  photosInFileSystem.h
//  Flickr
//
//  Created by Junbae Yoo on 2013-02-19.
//  Copyright (c) 2013 Junbae Yoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface photosInFileSystem : NSObject
+ (void) writeIntoFileSystem:(NSDictionary *)photo withData: (NSData *)data;
+ (UIImage *) getPhotoFromFileSystem: (NSString *)idForPhoto;
@end
