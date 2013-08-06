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

@interface VacationHelper : NSObject

+ (void)getVacationsUsingBlock:(vacations_list_t)vacationBlock;
+ (void)saveVacation:(NSString *)vacationName
          usingBlock:(completion_block_t)completionBlock;
+ (void)openVacation:(NSString *)vacationName
          usingBlock:(completion_block_t)completionBlock;
+ (void)deleteVacation:(NSString *)vacationName;
+(VacationHelper *) sharedVacationHelper;
@property (strong, nonatomic, readonly) NSDictionary *vacationList;
+(NSURL *) getVacationsDirectory;
@end
