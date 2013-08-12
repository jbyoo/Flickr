//
//  ChooseVacationViewController.m
//  Flickr
//
//  Created by Junbae Yoo on 2013-07-25.
//  Copyright (c) 2013 Junbae Yoo. All rights reserved.
//

#import "ChooseVacationViewController.h"
#import "VacationCollectionViewCell.h"
#import "VacationHelper.h"
#import "Photo+Flickr.h"
#import "PhotoFetcher.h"
#import "FlickrFetcher.h"

@interface ChooseVacationViewController ()
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UICollectionView *vacationCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *alertLabel;
@property (strong, nonatomic) NSArray *vacationsList;
@property (weak, nonatomic) NSString *selectedVacation; // Multiple selection is not allowed
@end

@implementation ChooseVacationViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.vacationCollectionView.allowsSelection = YES;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.selectedVacation = [defaults objectForKey:NSUSERDEFAULT_CURR_VACATION_KEY];
    self.alertLabel.text = [NSString stringWithFormat:@"Current vacation is : %@", self.selectedVacation];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateVacations];
    
}

-(NSArray *) vacationsList{
    if(!_vacationsList) {
        _vacationsList = [NSArray array];
    }
    return _vacationsList;
}

-(IBAction)Add:(id)sender
{
    [self performSegueWithIdentifier:@"AddVacation" sender:self];
}

//  Get current vacations and reload the collectionviewaod
-(void) updateVacations
{
    [VacationHelper getVacationsUsingBlock:^(NSArray *vacationList) {
        _vacationsList = vacationList;
        [self.vacationCollectionView reloadData];
    }];
}

- (IBAction)dismiss:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
    }];
}

- (IBAction)chooseVacation:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.selectedVacation forKey:NSUSERDEFAULT_CURR_VACATION_KEY];
    self.alertLabel.text = [NSString stringWithFormat:@"Current vacation is : %@", self.selectedVacation];
    
    //pop back and communicate!!
    [self.delegate chooseVacationViewController:self returnedVacation:self.selectedVacation];
}

- (IBAction)deleteVacation:(id)sender {
    [VacationHelper deleteVacation:self.selectedVacation];
    [self updateVacations];
    self.alertLabel.text = [NSString stringWithFormat:@"Successfully deleted: %@", self.selectedVacation];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *newVacationName = @"";
    if([self.vacationsList containsObject:DEFAULT_VACATION]) {
        newVacationName = DEFAULT_VACATION;
    } else if (!self.vacationsList.count){
        //self.vacationList will never be empty after [self updateVacations] is called
        NSLog(@"[ChooseVacationVC deleteVacation]: vacationList is empty.");
    } else {
        newVacationName = self.vacationsList[0];
    }
    [defaults setObject:newVacationName forKey:NSUSERDEFAULT_CURR_VACATION_KEY];
}

#pragma mark -collectionView delegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    VacationCollectionViewCell *cell = (VacationCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    self.selectedVacation =  cell.vacationLabel.text;
    for(int i = 0; i< self.vacationsList.count; i++) {
        VacationCollectionViewCell *cell = (VacationCollectionViewCell *)[self.vacationCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        cell.backgroundColor = [UIColor clearColor];
        cell.selected = NO;
    }
    [collectionView cellForItemAtIndexPath:indexPath].backgroundColor = [UIColor blueColor];
    [collectionView cellForItemAtIndexPath:indexPath].selected = YES;
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView cellForItemAtIndexPath:indexPath].backgroundColor = [UIColor clearColor];
}

#pragma mark - collectionView datasource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.vacationsList.count;
}

#define FOLDER_TRANSPARENCY 0.4
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Vacation Description" forIndexPath:indexPath];
    if([cell isKindOfClass:[VacationCollectionViewCell class]]) {
        VacationCollectionViewCell *vcvc = (VacationCollectionViewCell *)cell;
        //Customize Cell here
        vcvc.backgroundImage.image = [[UIImage imageNamed:@"folder.generic.001.png"]resizableImageWithCapInsets:UIEdgeInsetsMake(5,5,5,5)];
        vcvc.backgroundImage.alpha = FOLDER_TRANSPARENCY;
        
        //  Add sample photos of correspoding vacation as background images if any, maximum 4 photos.
        [VacationHelper openVacation:self.vacationsList[indexPath.row] usingBlock:^(UIManagedDocument *vacation) {
            NSArray *photos = [Photo photosInManagedObjectContext:vacation.managedObjectContext];
            int imageViewIndex = 0;
            if([photos count]) {
                for(id photo in photos) {
                    //Collection View cell will each have 4 photos as a background image
                    if([photo isKindOfClass:[Photo class]] && imageViewIndex < 4) {
                        Photo *photoImage = (Photo *)photo;
                        //***********vacation is the same. i want diff vacation for diff collectionview
                                                NSDictionary *photoinfo = @{FLICKR_PHOTO_ID: photoImage.unique} ;
                        [PhotoFetcher fetchPhotoUsingPhotoInfo:photoinfo usingBlock:^(UIImage *img) {
                            //use img to create backgroundpic
                            if([vcvc.imageViewArray[imageViewIndex] isKindOfClass:[UIImageView class]]) {
                                UIImageView *imageView = (UIImageView *)vcvc.imageViewArray[imageViewIndex];
                                imageView.image = img;
                            }
                        }];
                        imageViewIndex += 1;
//                        NSLog(@"opened Vacation: %@", vacation);
//                        NSLog(@"Photo: %@", photoImage);
                    }
                }
            }
        }];
       
        
        vcvc.vacationLabel.text = self.vacationsList[indexPath.row];
    }
    return cell;
}
//
//#pragma mark - UICollectionViewDelegateFlowLayout
//
//-(CGSize) collectionView:(UICollectionView *)collectionView
//                  layout:(UICollectionViewLayout *)collectionViewLayout
//  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    //Customize size for photos with different dimensions. For example,
//    
////    NSString *searchTerm = self.searches[indexPath.section];
////    FlickrPhoto *photo =
////    self.searchResults[searchTerm][indexPath.row];
//
////    CGSize retval = photo.thumbnail.size.width > 0 ? photo.thumbnail.size : CGSizeMake(100, 100);
////    retval.height += 35; retval.width += 35;
////    return retval;
//}
//
//-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView
//                       layout:(UICollectionViewLayout *)collectionViewLayout
//       insetForSectionAtIndex:(NSInteger)section
//{
//    return UIEdgeInsetsMake(50, 20, 50, 20);
//}

@end
