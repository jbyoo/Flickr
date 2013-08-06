//
//  VacationHelper.m
//  Flickr
//
//  Created by Junbae Yoo on 2013-02-28.
//  Copyright (c) 2013 Junbae Yoo. All rights reserved.
//

#import "VacationHelper.h"
#import "FlickrFetcher.h"
#import "Photo+Flickr.h"

@interface VacationHelper ()
@property (strong, nonatomic) NSDictionary *vacationList;   //Object = UIManagedDocument    Key = NSString
@end

@implementation VacationHelper
@synthesize vacationList = _vacationList;

-(NSDictionary *)vacationList
{
    if(!_vacationList) {
        _vacationList = [NSDictionary dictionary];
    }
    return _vacationList;
}



+(NSURL *) getVacationsDirectory
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *dir = [[[fm URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:DEFAULT_DATABASE_FOLDER isDirectory:YES];
    
    //Create one if none exists.
    BOOL isDir = NO;
    NSError *err;
    if( !([fm fileExistsAtPath:[dir path] isDirectory:&isDir] && isDir)) {
        [fm createDirectoryAtURL:dir withIntermediateDirectories:NO attributes:nil error:&err];
        if(err) {
            dir = nil;
            NSLog(@"[VacationHelper getVacations]: Failed to create 'Vacations' directory. %@", err);
        }
    }
    return dir;
}


+(void)getVacationsUsingBlock:(vacations_list_t)vacationBlock {
    //Get "Vacations" directory from NSDocumentDirectory.
    NSMutableArray *vacations = [NSMutableArray array];
    
    //Get vacation files from "Vacations" directory in NSDocumentDirectory.
    NSError *err;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[VacationHelper getVacationsDirectory]
                       includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey]
                                          options:NSDirectoryEnumerationSkipsHiddenFiles
                                            error:&err];
    if(err) {
        NSLog(@"[VacationHelper getVacations]: Failed to fetch contents of 'Vacations' directory. %@", err);
    }
    
    //Create a default vacation. **No document in disk yet**
    //Return the URLs of the files.
    if(![files count]) {
        [VacationHelper saveVacation:DEFAULT_VACATION usingBlock:^(UIManagedDocument *vacation) {
            NSString *fileName = [[vacation.fileURL lastPathComponent] stringByDeletingPathExtension];
            vacationBlock([NSArray arrayWithObject:fileName]);
        }];
    } else {
        for(NSURL *url in files) {
            NSString* fileName = [[url lastPathComponent] stringByDeletingPathExtension];
            [vacations addObject:fileName];
        }
        vacationBlock([NSArray arrayWithArray:[vacations copy]]);
    }
}

+ (VacationHelper *) sharedVacationHelper
{
    static VacationHelper *_sharedVacation = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedVacation = [[self alloc] init];
    });
    return _sharedVacation;
}

+ (void)saveVacation:(NSString *)vacationName usingBlock:(completion_block_t)completionBlock{
    NSURL *url = [[VacationHelper getVacationsDirectory] URLByAppendingPathComponent:vacationName];
    UIManagedDocument *document = [[VacationHelper sharedVacationHelper].vacationList objectForKey:vacationName];
    if([[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
        //Vacation file exists at url.
//        NSLog(@"[VacationHelper saveVacation:] Vacation is already saved at url.");
        if (!document) {
            document = [[UIManagedDocument alloc] initWithFileURL:url];
            //If VacationHelper.vacationList instance does not have document associated with vacationName,
            //enter vacationName and document into VacationHelper.vacationList
            NSMutableDictionary *vacations = [NSMutableDictionary dictionaryWithDictionary:[VacationHelper sharedVacationHelper].vacationList];
//            NSLog(@"%@ ***** %@", vacationName, document);
            [vacations setObject:document forKey:vacationName];
            [VacationHelper sharedVacationHelper].vacationList = [vacations copy];
        }
        
        //    ================================================
//        NSLog(@"saveVacation: sharedVacation %@", [VacationHelper sharedVacationHelper]);
//        NSLog(@"saveVacation: vacations %@", vacations);
//        NSLog(@"saveVacation: document %@", document);
//        NSLog(@"saveVacation: vacationList %@", [VacationHelper sharedVacationHelper].vacationList);
//
//        //    ================================================
        
        //If VacationHelper.vacationList has document associated with VacationName simply use document in VacationHelper.vacationList
        document = [[VacationHelper sharedVacationHelper].vacationList objectForKey:vacationName];
        completionBlock(document);
    } else {
        //Document is not created in file system. save to url
        document = [[UIManagedDocument alloc] initWithFileURL:url];
        [document saveToURL:url
           forSaveOperation:UIDocumentSaveForCreating
          completionHandler:^(BOOL success) {
              //Save vacation in VacationHelper instance
              NSMutableDictionary *vacations = [NSMutableDictionary dictionaryWithDictionary:[VacationHelper sharedVacationHelper].vacationList];
              [vacations setObject:document forKey:vacationName];
              [VacationHelper sharedVacationHelper].vacationList = [vacations copy];
              completionBlock(document);
              if(success) NSLog(@"[VacationHelper saveVacation:] Document created and saved at url: %@", url);
              if(!success) NSLog(@"[VacationHelper saveVacation:] Error creating the document at url: %@", url);
          }];
    }
}

+ (void)openVacation:(NSString *)vacationName usingBlock:(completion_block_t)completionBlock{
    NSURL *url = [[VacationHelper getVacationsDirectory] URLByAppendingPathComponent:vacationName];
    UIManagedDocument *document = [[VacationHelper sharedVacationHelper].vacationList objectForKey:vacationName];
//    //    ================================================
//
//    NSLog(@"openVacation vacationNameForDocument: %@", vacationName);
//    NSLog(@"openVacation document: %@", document);
//    NSLog(@"openVacation: vacationList %@", [VacationHelper sharedVacationHelper].vacationList);
//    
//    //    ================================================
    if(!document || ![[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
        [VacationHelper saveVacation:vacationName usingBlock:^(UIManagedDocument *vacation) {
//            NSLog(@"savedVacation document: %@", vacation);
            completionBlock(vacation);
        }];
    } else if (document.documentState == UIDocumentStateClosed){
        //open the doc

        [document openWithCompletionHandler:^(BOOL success) {
            completionBlock(document);
            if(success) NSLog(@"[VacationHelper openVacation]: document opened successfully and finished executing completionBlock");  //doc is ready
            if(!success) NSLog(@"[VacationHelper]: Error opening the document at url: %@", document.fileURL);
        }];
            
    } else if (document.documentState == UIDocumentStateNormal) {
            completionBlock(document);
        //    NSLog(@"[VacationHelper]: Document state is normal");
    }
}
+ (void)deleteVacation:(NSString *)vacationName
{
        NSError *error;
        NSURL *urlfolder = [[VacationHelper getVacationsDirectory] URLByAppendingPathComponent:vacationName];
        [[NSFileManager defaultManager] removeItemAtURL:urlfolder error:&error];
}

@end
