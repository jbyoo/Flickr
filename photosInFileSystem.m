//
//  photosInFileSystem.m
//  Flickr
//
//  Created by Junbae Yoo on 2013-02-19.
//  Copyright (c) 2013 Junbae Yoo. All rights reserved.
//

#import "photosInFileSystem.h"
#import "FlickrFetcher.h"

#define MAXIMUM_SIZE 10485760 //10MB
#define PHOTO_FOLDER @"Photos"

@interface photosInFileSystem ()
+ (unsigned long long int)folderSize:(NSString *)folderPath;
+ (NSString *) oldestFileIn:(NSString *) folderPath;
@property (strong, nonatomic) NSString *photosDirectory;
@end

@implementation photosInFileSystem
@synthesize photosDirectory = _photosDirectory;

//  Objective: Get used to NSFileManager & more
//  Keeps Cache in filesystem so that the app will keep the cached photos even when it is not running
//  The total size of the cached photos does not exceed 10MB.
//  The newly entered photo will push out the oldest file in the folder.(Filesystem only. NSCache has size limit of 10MB, but it will stop storing photos when 10MB is reached.)
//  Note to self: The file name for each photo equals to the id of the photo. This info is used to retrieve the photo when requested.


+ (void) writeIntoFileSystem:(NSDictionary *)photo withData: (NSData *)data
{
    //Create 'Photos' folder if there isn't
    BOOL isDir;
    NSError *error;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *newDirectory = [cachePath stringByAppendingPathComponent:PHOTO_FOLDER];
    if (! [fm fileExistsAtPath:newDirectory isDirectory:&isDir] && isDir == NO) {
        NSLog(@"[photosInFileSystem: writeIntoFileSystem] newDirectory: %@", newDirectory);
        [fm createDirectoryAtPath:newDirectory withIntermediateDirectories:NO attributes:nil error:&error];
    } 
    if(error != nil)
    {
        NSLog(@"Cannot create directory %@:", error);
    }
    
    //Store the photo in the folder
    NSString *fileName;
    if([photo objectForKey:@"originalformat"]) {
        fileName = [[[photo objectForKey:FLICKR_PHOTO_ID] stringByAppendingFormat:@"." ] stringByAppendingString:[photo objectForKey:@"originalformat"]];
        NSString *filePath = [newDirectory stringByAppendingPathComponent:fileName];
      //NSLog(@"fileName: %@", fileName);
      //NSLog(@"filePath: %@", filePath);
        if(![fm fileExistsAtPath:filePath])[fm createFileAtPath:filePath contents:data attributes:nil];
        
        //Check if folder size > 10MB and keep deleting oldest files
        while([self folderSize:newDirectory] > MAXIMUM_SIZE) //10MB
        {
            NSLog(@"Directory maximum capacity is reached");
            //remove least recently used data
            NSError *error;
            NSString *pathForFileToBeRemoved = [newDirectory stringByAppendingPathComponent:[self oldestFileIn:newDirectory]];
            [fm removeItemAtPath:pathForFileToBeRemoved error:&error];
            if(error) NSLog(@"REMOVE ERROR: %@", error);
        }
    }
}


//returns folderSize
+ (unsigned long long int)folderSize:(NSString *)folderPath {
    NSArray *filesArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:folderPath error:nil];
    NSEnumerator *filesEnumerator = [filesArray objectEnumerator];
    NSString *fileName;
    unsigned long long int fileSize = 0;
    while (fileName = [filesEnumerator nextObject]) {
        NSError *error;
        NSDictionary *fileDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:[folderPath stringByAppendingPathComponent:fileName] error:&error];
        if(error) NSLog(@"File Attribute Error in folderSize: %@", error);
        fileSize += [fileDictionary fileSize];
//        NSLog(@"%@", fileDictionary);
//        NSLog(@" fileSize: %llu", [fileDictionary fileSize]);
//        NSLog(@" fileName: %@", fileName);
    }
    return fileSize;
}

//returns filePath of the oldest file
+ (NSString *) oldestFileIn:(NSString *) folderPath {
    NSArray *fileArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:folderPath error:nil];
    NSEnumerator *filesEnumerator = [fileArray objectEnumerator];
    NSString *oldestFile;
    NSString *fileName;
    NSDate *oldestDate;
    NSError *error;
    
    while(fileName = [filesEnumerator nextObject]) {
        NSDictionary *fileDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:[folderPath stringByAppendingPathComponent:fileName] error:&error];
        if(error) NSLog(@"File Attribute Error in oldestFileIn: %@", error);
        NSDate *creationDate = [fileDictionary fileCreationDate];
        if(!oldestDate || [oldestDate compare:creationDate] == NSOrderedDescending) {
            oldestDate = creationDate;
            oldestFile = fileName;
        }
    }
    NSLog(@"oldest file for deletion: %@", oldestFile);
    return oldestFile;
}

+(UIImage *)getPhotoFromFileSystem:(NSString *) idForPhoto {
    //Create 'Photos' folder if there isn't
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *newDirectory = [cachePath stringByAppendingPathComponent:PHOTO_FOLDER];
    BOOL isDir;
    
    if (! [fm fileExistsAtPath:newDirectory isDirectory:&isDir] && isDir == NO) {
        return nil;
    }
    
//    //NSString *path = [newDirectory stringByAppendingPathComponent:idForPhoto];
    
    NSArray *fileArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:newDirectory error:nil];
    NSEnumerator *filesEnumerator = [fileArray objectEnumerator];
    NSString *fileName;
    NSString *imagePath;
    
    while(fileName = [filesEnumerator nextObject]) {

        if([[fileName stringByDeletingPathExtension] isEqualToString:idForPhoto]) {
            imagePath = fileName;
            break;
        }
    }
    
    UIImage *img = [UIImage imageWithContentsOfFile:[newDirectory stringByAppendingPathComponent:imagePath]];

    if(img) {
        return img;
    } else {
        return nil;
    }
}
@end
