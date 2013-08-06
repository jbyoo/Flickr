//
//  VacationCollectionViewCell.h
//  Flickr
//
//  Created by Junbae Yoo on 2013-07-25.
//  Copyright (c) 2013 Junbae Yoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VacationCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) NSArray *imageViewArray;
@property (weak, nonatomic) IBOutlet UIImageView *image1;
@property (weak, nonatomic) IBOutlet UIImageView *image2;
@property (weak, nonatomic) IBOutlet UIImageView *image3;
@property (weak, nonatomic) IBOutlet UIImageView *image4;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;

@property (weak, nonatomic) IBOutlet UILabel *vacationLabel;

@end
