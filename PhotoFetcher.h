//
//  PhotoFetcher.h
//  Flickr
//
//  Created by Junbae Yoo on 2013-07-29.
//  Copyright (c) 2013 Junbae Yoo. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^img_completion_block_t) (UIImage *img);
@interface PhotoFetcher : NSObject

//  This method fetches photo image given a dictionary of photo info. The process of fetching follows:
//  1.  Check the local filesystem
//  2.  Check static NSCache instance (The size of cache is 10MB)
//  3.  Fetch photo from Flickr server. The photo will be saved in cache and filesystem as well for future use.
//  Fetching image over network runs asynchronously. Use completionBlock to process the returned image.
+(void) fetchPhotoUsingPhotoInfo:(NSDictionary *)photo usingBlock:(img_completion_block_t)completionBlock;
@end
