//
//  PhotoViewerViewController.m
//  Flickr
//
//  Created by Junbae Yoo on 2013-02-04.
//  Copyright (c) 2013 Junbae Yoo. All rights reserved.
//

//  Note: When fetching a photo the app checks to see if it exists in NSCache AND file system. This may not be the best practice.
//  Don't forget to add map related parts!!!

#import "PhotoViewerViewController.h"
#import "FlickrFetcher.h"
#import "photosInFileSystem.h"
#import "VacationHelper.h"
#import "Photo+Flickr.h"
#import "PhotoFetcher.h"

@interface PhotoViewerViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *currentVacationLabel;

@end

@implementation PhotoViewerViewController

-(void)chooseVacationViewController:(ChooseVacationViewController *)chooseVacationVC
                   returnedVacation:(NSString *)vacation
{
    self.vacation = vacation;
    [self openAndVisitPhotoIntoVacation:vacation];
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

-(NSString *) vacation
{
    if(!_vacation) {
        _vacation = [[NSUserDefaults standardUserDefaults] objectForKey:NSUSERDEFAULT_CURR_VACATION_KEY];
    }
    return _vacation;
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}


- (IBAction)visit{  //or unvisit
    
    //Add vacation property. This will be set when user navigates through My vacations tab.
    //Give the user the ability to choose among vacations when "Visit" button is pressed.
    //Bring up a ModalVC to show the current vacation and option to change to another vacation instance.
    //Visit Button text. how to tell if photo is in one of vacations?
    
    
    if([self.navigationItem.rightBarButtonItem.title isEqualToString: @"Unvisit"]) {
        [VacationHelper openVacation:self.vacation usingBlock:^(UIManagedDocument *vacation) {
            NSManagedObjectContext *context = vacation.managedObjectContext;
            [Photo removePhoto:self.photo inManagedObjectContext:context];
            self.navigationItem.rightBarButtonItem.title = @"Visit";
            [self.navigationController popViewControllerAnimated:YES];
        }];
    } else if ([self.navigationItem.rightBarButtonItem.title isEqualToString: @"Visit"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Current vacation name is :"
                                                        message:self.vacation
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Use current vacation", @"Choose another vacation", nil];
        [alert show];
    }
}
-(void) setVisitButtonLabel
{
    //if photo exists in current vacation, label.text = unvisit.
    //else label.text = visit
    if(!self.vacation) {
        NSLog(@"!!!!!!!!NO VACATION!!!!");
    }
    self.currentVacationLabel.text = [NSString stringWithFormat:@"Current Vacation: %@", self.vacation];
    self.currentVacationLabel.backgroundColor = [self.currentVacationLabel.backgroundColor colorWithAlphaComponent:0.6];
    [VacationHelper openVacation:self.vacation usingBlock:^(UIManagedDocument *vacation) {
        NSManagedObjectContext *context = vacation.managedObjectContext;
        NSLog(@"[PhotoViewerVC setVisitButtonLabel]: vacation = %@", vacation);
        int count = [[Photo matchingPhotos:self.photo inManagedObjectContext:context] count];
        //get document and save the photo into core data
        if(count == 0) {
            self.navigationItem.rightBarButtonItem.title = @"Visit";
        } else if (count == 1) {
            self.navigationItem.rightBarButtonItem.title = @"Unvisit";
        } else {
            NSLog(@"[PhotoViewerVC setVisitButtonLabel]: invalid number of photos in coredata.");
        }
    }];
    
}

-(void) openAndVisitPhotoIntoVacation:(NSString *)vacationForSaving
{
    //Open vacation and 'visit' current photo using current vacation
    [VacationHelper openVacation:vacationForSaving usingBlock:^(UIManagedDocument *vacation) {
        NSManagedObjectContext *context = vacation.managedObjectContext;
        
        int count = [[Photo matchingPhotos:self.photo inManagedObjectContext:context] count];
        NSLog(@"[PhotoViewerVC alertView] document: %@", vacation);
        //get document and save the photo into core data
        if(count == 0) {
            //insert photo since it is not in the database
            NSLog(@"[PhotoViewerVC alertView]: self.photo = %@", self.photo);
            [Photo insertPhoto:self.photo inManagedObjectContext:context];
            NSLog(@"[PhotoViewerVC alertView] is photo inserted? %@, context: %@",[Photo matchingPhotos:self.photo inManagedObjectContext:context], context);
            self.navigationItem.rightBarButtonItem.title = @"Unvisit";
        } else {
            //remove photo from core data
            NSLog(@"[PhotoViewerVC alertView] Photo exists in Core Data");
            [Photo removePhoto:self.photo inManagedObjectContext:context];
            //                self.navigationItem.rightBarButtonItem.title = @"Visit";
            //                [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1) {
        //Open vacation and 'visit' current photo using current vacation
        [self openAndVisitPhotoIntoVacation:self.vacation];
    } else if (buttonIndex == 2) {
        //Modal view controller to choose another vacation.
        [self performSegueWithIdentifier:@"Choose Vacation" sender:self];
    } else if (buttonIndex == 3) {
        //Cancel button
    }
}

//Coordinate System, frame
-(void) updatePhotoWithImage:(UIImage *)img
{
    double widthToHeightRatio = img.size.width / img.size.height;
    double screenRatio = self.view.bounds.size.width / self.view.bounds.size.height;
    CGSize imageSize; 
    if(widthToHeightRatio < screenRatio)
    {
        imageSize.width = self.view.bounds.size.height * widthToHeightRatio;
        imageSize.height = self.view.bounds.size.height;
    } else
    {
        imageSize.width = self.view.bounds.size.width;
        imageSize.height = self.view.bounds.size.width / widthToHeightRatio;
    }
    self.imageView.image = [self imageWithImage:img scaledToSize:imageSize];
    self.scrollView.contentSize = self.imageView.frame.size;
}

- (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize {
	UIGraphicsBeginImageContext(newSize);
    
	[image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
	UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
	UIGraphicsEndImageContext();
    
	return newImage;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.scrollView.delegate = self;
}

#define SPINNER_SIDE_LENGTH 40
//UIActivityIndicatorView, GCD, NSCache
- (void)viewWillAppear:(BOOL)animated
{
    //Set up spinner and NetworkActivityIndicator
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.frame = CGRectMake(self.view.bounds.size.width/2 - SPINNER_SIDE_LENGTH/2,
                               self.view.bounds.size.height/2 - SPINNER_SIDE_LENGTH/2,
                               SPINNER_SIDE_LENGTH,
                               SPINNER_SIDE_LENGTH);
    [self.imageView addSubview:spinner];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [spinner startAnimating];
    
    
    
    [PhotoFetcher fetchPhotoUsingPhotoInfo:self.photo usingBlock:^(UIImage *img) {
        [self.imageView setImage:img];
        [self updatePhotoWithImage:img];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [spinner stopAnimating];
        spinner.hidden = YES;
    }];
    
    self.title = [self.photo objectForKey:FLICKR_PHOTO_TITLE];
    [self setVisitButtonLabel];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Choose Vacation"]) {
        ChooseVacationViewController *chooser = (ChooseVacationViewController *)segue.destinationViewController;
        chooser.delegate = self;
    }
}


@end
