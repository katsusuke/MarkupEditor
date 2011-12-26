//
//  SizePickerViewController.m
//  MarkupEditor
//
//  Created by  on 11/12/20.
//  Copyright 2011 MK System. All rights reserved.
//

#import "SizePickerViewController.h"

@implementation SizePickerViewController

@synthesize sizes=sizes_;
@synthesize delegate=delegate_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc{
    [pickerView release];
    [sizes_ release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
- (void)selectRow:(NSInteger)row{
    [pickerView selectRow:row inComponent:0 animated:YES];
}
- (void)reloadAllComponents{
    [pickerView reloadAllComponents];
}
- (CGFloat)size{
    NSString* sizeStr = [sizes_ objectAtIndex:[pickerView selectedRowInComponent:0]];
    return [sizeStr floatValue];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - UIPickerViewDelegate Implementation 

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView{
    return 1;
}
-(NSInteger)pickerView:(UIPickerView*)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [sizes_ count];
}
-(NSString*)pickerView:(UIPickerView*)pickerView
           titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [sizes_ objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSString* sizeStr = [sizes_ objectAtIndex:row];
    [delegate_ sizePickerViewController:self didSelectSize:[sizeStr floatValue]];
}

@end
