//
//  VacationCollectionViewCell.m
//  Flickr
//
//  Created by Junbae Yoo on 2013-07-25.
//  Copyright (c) 2013 Junbae Yoo. All rights reserved.
//

#import "VacationCollectionViewCell.h"

@implementation VacationCollectionViewCell

-(NSArray *)imageViewArray
{
    return @[self.image1, self.image2, self.image3, self.image4];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
