//
//  RootViewController.m
//  MarkupEditor
//
//  Created by shimizu on 11/03/15.
//  Copyright 2011 MK System. All rights reserved.
//

#import "RootViewController.h"
#import "ColorPickupViewController.h"
#import "SizePickerViewController.h"

@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"RootViewController" bundle:nibBundleOrNil];
    //self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [textView0 release];
    [textView1 release];
    [textView2 release];
    [styleSelector release];
    [keyboardSelector release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    colorPickerViewController_
    = [[ColorPickupViewController alloc]initWithNibName:@"ColorPickupViewController"
                                                 bundle:nil];
    colorPickerViewController_.contentSizeForViewInPopover
    = CGSizeMake(270, 270);
    colorPickerViewController_.delegate = self;
    
    
    const NSString* const sizes[] = {
        @"8",
        @"10",
        @"12",
        @"14",
        @"16",
        @"20",
        @"24",
        @"32",
        @"40",
    };
    NSArray* sizeArray = [NSArray arrayWithObjects:sizes
                                             count:sizeof(sizes) / sizeof(sizes[0])];
    sizePickerViewController_
    = [[SizePickerViewController alloc]initWithNibName:@"SizePickerViewController"
                                                bundle:nil];
    sizePickerViewController_.contentSizeForViewInPopover = CGSizeMake(216, 216);
    sizePickerViewController_.sizes = sizeArray;
    [sizePickerViewController_ reloadAllComponents];
    [sizePickerViewController_ selectRow:2];
    sizePickerViewController_.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [sizePickerViewController_ release];
    [colorPickerViewController_ release];
    sizePickerViewController_ = nil;
    colorPickerViewController_ = nil;
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
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    //textView0.inputTextMode = InputTextModeHandWriting;
    [textView0 becomeFirstResponder];
}

- (IBAction)buttonBushed:(id)sender
{
    UISegmentedControl* sc = sender;
    if(sender == keyboardSelector){
        switch (sc.selectedSegmentIndex) {
            case 0://QWERTY
                textView0.inputTextMode = InputTextModeQwerty;
                textView1.inputTextMode = InputTextModeQwerty;
                textView2.inputTextMode = InputTextModeQwerty;
                break;
            case 1://HandWriteView
                textView0.inputTextMode = InputTextModeHandWriting;
                textView1.inputTextMode = InputTextModeHandWriting;
                textView2.inputTextMode = InputTextModeHandWriting;
                break;
        }
        if([textView0 isFirstResponder]){
            [textView0 resignFirstResponder];
            [textView0 becomeFirstResponder];
        }
        if([textView1 isFirstResponder]){
            [textView1 resignFirstResponder];
            [textView1 becomeFirstResponder];
        }
        if([textView2 isFirstResponder]){
            [textView2 resignFirstResponder];
            [textView2 becomeFirstResponder];
        }
    }
    else if(sender == styleSelector){
        switch (sc.selectedSegmentIndex) {
            case 0:{
                [popover_ release];
                popover_ = 
                [[UIPopoverController alloc] 
                 initWithContentViewController:colorPickerViewController_];
                popover_.delegate = self;
                CGRect rc = styleSelector.frame;
                rc.size.width /= styleSelector.numberOfSegments;
                
                [popover_ presentPopoverFromRect:rc
                                          inView:styleSelector
                        permittedArrowDirections:UIPopoverArrowDirectionUp
                                        animated:YES];
                break;
            }
            case 1:{
                [popover_ release];
                popover_ =
                [[UIPopoverController alloc]
                 initWithContentViewController:sizePickerViewController_];
                popover_.delegate = self;
                CGRect rc = styleSelector.frame;
                rc.size.width /= styleSelector.numberOfSegments;
                rc.origin.x += rc.size.width;
                [popover_ presentPopoverFromRect:rc
                                          inView:styleSelector
                        permittedArrowDirections:UIPopoverArrowDirectionUp
                                        animated:YES];
                break;
            }
            case 2:{//Save
                NSDateFormatter *inputDateFormatter = [[NSDateFormatter alloc] init];
                [inputDateFormatter setDateFormat:@"yyyyMMddHHmmss"];
                NSString* dateStr = [inputDateFormatter stringFromDate:[NSDate date]];
                [inputDateFormatter release];
                NSString* path =
                 [NSString stringWithFormat:@"%@/Documents/%@.pdf", NSHomeDirectory(), dateStr];
                
                [self.view renderInPDFFile:path];
            }
            case 3:{//New
                [textView0 clear];
                [textView1 clear];
                [textView2 clear];
            }
        }
    }
    
}
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if(popover_.contentViewController == sizePickerViewController_){
        if([textView0 isFirstResponder]){
            textView0.specificFont= [UIFont systemFontOfSize:sizePickerViewController_.size];
        }
        if([textView1 isFirstResponder]){
            textView0.specificFont= [UIFont systemFontOfSize:sizePickerViewController_.size];
        }
        if([textView2 isFirstResponder]){
            textView0.specificFont= [UIFont systemFontOfSize:sizePickerViewController_.size];
        }
    }
    else if(popover_.contentViewController == colorPickerViewController_){
        if([textView0 isFirstResponder]){
            textView0.specificColor = colorPickerViewController_.color;
        }
        if([textView1 isFirstResponder]){
            textView1.specificColor = colorPickerViewController_.color;
        }
        if([textView2 isFirstResponder]){
            textView2.specificColor = colorPickerViewController_.color;
        }
        
    }
}
- (void)sizePickerViewController:(SizePickerViewController*)viewController
                   didSelectSize:(CGFloat)size
{
    [popover_ dismissPopoverAnimated:YES];
    [self popoverControllerDidDismissPopover:popover_];
}

- (void)colorPickupViewController:(ColorPickupViewController*)viewController
                 didSelectedColor:(UIColor*)color
{
    [popover_ dismissPopoverAnimated:YES];
    [self popoverControllerDidDismissPopover:popover_];
}

@end
