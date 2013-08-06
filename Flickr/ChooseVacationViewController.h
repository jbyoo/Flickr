//
//  ChooseVacationViewController.h
//  Flickr
//
//  Created by Junbae Yoo on 2013-07-25.
//  Copyright (c) 2013 Junbae Yoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ChooseVacationViewController;
@protocol ChooseVacationViewControllerDelegate <NSObject>

-(void) chooseVacationViewController:(ChooseVacationViewController *) chooseVacationVC returnedVacation:(NSString *)vacation;

@end
@interface ChooseVacationViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDelegate>
@property (nonatomic, strong) id <ChooseVacationViewControllerDelegate> delegate;
@end
