//
//  VacationHelper.h
//  Flickr
//
//  Created by Junbae Yoo on 2013-02-28.
//  Copyright (c) 2013 Junbae Yoo. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DEFAULT_DATABASE_FOLDER @"Vacations"
#define DEFAULT_VACATION @"My Vacation"
#define NSUSERDEFAULT_CURR_VACATION_KEY @"Current Vacation"

typedef void (^completion_block_t)(UIManagedDocument *vacation);
typedef void (^vacations_list_t)(NSArray *vacationList);

//  This class implements singleton pattern to keep the mapping between file name and UIManagedDocument

//  Note to self: Make sure the mapping is always synched!!
//            ??  How do you persist the mapping over app's life cycle without using NSUserDefaults?

@interface VacationHelper : NSObject

+(VacationHelper *) sharedVacationHelper;

//  This method takes vacationBlock in which vacation list will be available
//  This will search the directory and pass matching documents given the file names, over to the block.
//  If there is no UIManagedDocument, an instance of document is created using default name and saved asynchrounously, which is why we are using block to hand out the list instead of returning the result.
+ (void)getVacationsUsingBlock:(vacations_list_t)vacationBlock;

//  This saves UIManagedDocument to filesystem and maps the file name to document.
//  The document can be called in completion_block if needed. The state of document is open so it is ready to use
+ (void)saveVacation:(NSString *)vacationName
          usingBlock:(completion_block_t)completionBlock;

//  This will open the UIManagedDocument. If none, saveVacation: will be called
+ (void)openVacation:(NSString *)vacationName
          usingBlock:(completion_block_t)completionBlock;

//  Delete from filesystem and self.vacationList
+ (void)deleteVacation:(NSString *)vacationName;

@end
