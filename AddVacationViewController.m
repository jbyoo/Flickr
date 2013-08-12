//
//  AddVacationViewController.m
//  Flickr
//
//  Created by Junbae Yoo on 2013-07-18.
//  Copyright (c) 2013 Junbae Yoo. All rights reserved.
//

#import "AddVacationViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface AddVacationViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *vacationTextField;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigatoonBar;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *addVacationButton;
@property (weak, nonatomic) IBOutlet UILabel *alertLabel;
@property (weak, nonatomic) IBOutlet UITableView *vacationTable;
@property (strong , nonatomic) NSString *inputText;
@property (strong, nonatomic) NSArray *vacations;
@end

@implementation AddVacationViewController

-(void) viewDidLoad
{
    [super viewDidLoad];
    self.vacationTextField.delegate = self;
    self.vacationTable.delegate = self;
    self.vacationTable.dataSource = self;
    [self.scrollView setContentSize:self.view.frame.size];
    [self registerForKeyboardNotifications];
    
}

-(NSArray *)vacations
{
    if(!_vacations) {
        _vacations = [[NSArray alloc] init];
    }
    return _vacations;
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}


//  Adjust the scrollview so the user can view the textField while keyboard is up.
-(void)keyboardWasShown:(NSNotification *)aNotification
{
    NSDictionary *info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    aRect.size.height -= self.navigatoonBar.frame.size.height;
   
    CGPoint origin = self.addVacationButton.frame.origin;
    origin.y -= self.scrollView.contentOffset.y;
    origin.y += self.addVacationButton.frame.size.height;

    // If hidden always show addVacationButton right above the keyboard.
    if (!CGRectContainsPoint(aRect, origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, self.addVacationButton.frame.origin.y
                                          - aRect.size.height
                                          + self.addVacationButton.frame.size.height);
        [self.scrollView setContentOffset:scrollPoint animated:YES];
    }
    
    
}

-(void)keyboardWillBeHidden:(NSNotification *)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateVacationsTable];
    self.alertLabel.text = @"";
    self.vacationTable.layer.borderWidth = 2;
    self.vacationTable.layer.borderColor = [[UIColor grayColor] CGColor];
    
}

//  TableView will be refreshed to include the latest vacation that was just added by the user
-(void)updateVacationsTable
{
    [VacationHelper getVacationsUsingBlock:^(NSArray *vacationList) {
        NSMutableArray *mutableVacations = [@[vacationList[0]] mutableCopy];
        for(int i = 1; i< [vacationList count]; i++) {
            [mutableVacations addObject:vacationList[i]];
        }
        NSLog(@"[AddVacationView updateVacationsLabel:]%@", mutableVacations);
        self.vacations = [mutableVacations copy];
        [self.vacationTable reloadData];
    }];
}

#pragma mark -Table view data source

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.vacations.count;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"Vacation Name";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = self.vacations[indexPath.row];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


#pragma mark - Text field delegate

-(void) textFieldDidEndEditing:(UITextField *)textField
{
    if(![textField.text length]) {
        //?
    } else {
        //Save Vacation to VacationList and update view.
        self.inputText = textField.text;
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if([textField.text length]) {
        [textField resignFirstResponder];
        return YES;
    } else {
        return NO;
    }
}

//  Add a new vacation and change the UI accordingly
- (IBAction)addVacation:(UIButton *)sender {
    //Add button is pressed before the keyboard is dismissed.
    if(![self.inputText length]) {
        self.inputText = self.vacationTextField.text;
    }
    if(![self.vacationTextField.text length]) {
        self.alertLabel.text = @"Enter a vacation name.";
    }
    //Check outputText(or CD? ) and see if input text already exists.
    else {
        [VacationHelper saveVacation:self.inputText usingBlock:^(UIManagedDocument *vacation) {
            [self updateVacationsTable];
            self.vacationTextField.text = @"";
            self.inputText = @"";
            if(!vacation) {
                //Vacation already exists in CD. Let user know insertion has failed.
                self.alertLabel.text = @"Failed to insert. The vacation already exists.";
                self.alertLabel.textColor = [UIColor redColor];
            } else {
                //Let user know vacation was inserted successfully.
                self.alertLabel.text = @"Successfully inserted.";
                self.alertLabel.textColor = [UIColor blackColor];
                [self.vacationTextField resignFirstResponder];
            }
            
        }];
    }
    
}
- (IBAction)dismiss:(UIButton *)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
    }];
}

@end
