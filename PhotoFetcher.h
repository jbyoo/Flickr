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
+(void) fetchPhotoUsingPhotoInfo:(NSDictionary *)photo usingBlock:(img_completion_block_t)completionBlock;
@end
