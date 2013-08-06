//
//  VacationTypeViewController.m
//  Flickr
//
//  Created by Junbae Yoo on 2013-03-01.
//  Copyright (c) 2013 Junbae Yoo. All rights reserved.
//

#import "VacationTypeViewController.h"
#import "VacationPlacesTableViewController.h"
#import "PhotosTagViewController.h"

@interface VacationTypeViewController ()
@end

@implementation VacationTypeViewController
@synthesize vacation = _vacation;

-(void) viewDidLoad
{
    [super viewDidLoad];
    self.title = self.vacation;
}
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [segue.destinationViewController setVacation:self.vacation];
}
@end
