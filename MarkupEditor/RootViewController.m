//
//  RootViewController.m
//  MarkupEditor
//
//  Created by shimizu on 11/03/15.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"


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
    
    
}

- (void)viewWillDisappear:(BOOL)animated
{
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

@end
