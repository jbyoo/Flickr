//
//  PhotoFetcher.m
//  Flickr
//
//  Created by Junbae Yoo on 2013-07-29.
//  Copyright (c) 2013 Junbae Yoo. All rights reserved.
//

#import "PhotoFetcher.h"
#import "FlickrFetcher.h"
#import "photosInFileSystem.h"

@interface PhotoFetcher()

@property (strong, nonatomic) NSCache *cache;
@end
static NSCache *cache;
@implementation PhotoFetcher
+(void) fetchPhotoUsingPhotoInfo:(NSDictionary *)photo
                           usingBlock:(img_completion_block_t)completionBlock
{
    //Create cache if none
    if(!cache) {
        cache = [[NSCache alloc] init];
        //Cost limit for cache is 10MB
        [cache setTotalCostLimit:10 * pow (2,20)];
        NSLog(@"An instance of NSCache has been created.");
    }
    
    //will check for cache first to see if the requested photo is in the cache.
    NSString *idForPhoto = [photo objectForKey:FLICKR_PHOTO_ID];
    UIImage *cachedPhoto = [cache objectForKey:idForPhoto];
    UIImage *photoInFileSystem = [photosInFileSystem getPhotoFromFileSystem:idForPhoto];
    
    
    //Look for photo in Filesystem first, then cache, and if we fail, fetch photo from Flickr over network.
    if(photoInFileSystem) {
        NSLog(@"[PhotoViewerVC viewWillAppear]: Photo is fetched from filesystem");
        completionBlock(photoInFileSystem);
    } else if(cachedPhoto) {
        NSLog(@"[PhotoViewerVC viewWillAppear]:Photo is fetched from NSCache");
        completionBlock(cachedPhoto);
    } else {
        NSLog(@"[PhotoViewerVC viewWillAppear]:Photo is fetched from Flickr");
        dispatch_queue_t downloadQueue = dispatch_queue_create("flickr", DISPATCH_QUEUE_SERIAL);
        dispatch_async(downloadQueue, ^{
            NSURL *url = [FlickrFetcher urlForPhoto:photo format:FlickrPhotoFormatOriginal];
            NSData *photoData = [NSData dataWithContentsOfURL:url];
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *img = [UIImage imageWithData:photoData];
                //NSLog(@"%@", img);
                completionBlock(img);
                
                //Each photo has size of 'costOfPhoto' and the sum of photos in cache should not exceed 10MB.
                NSUInteger costOfPhoto = [photoData length];
                //NSLog(@"%d", costOfPhoto);
                if(img) [cache setObject:img forKey:idForPhoto cost:costOfPhoto];
                if(photo) {
                    [photosInFileSystem writeIntoFileSystem:photo withData:photoData];
                } else {
                    NSLog(@"Invalid Photo");
                }
            });
        });
    }
}
@end
