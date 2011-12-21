//
//  RootViewController.h
//  MarkupEditor
//
//  Created by shimizu on 11/03/15.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphicalTextView.h"
#import "HandWritingView.h"

#import "SizePickerViewController.h"
#import "ColorPickupViewController.h"

@interface RootViewController : UIViewController<UIPopoverControllerDelegate> {
    IBOutlet GraphicalTextView* textView0;
    IBOutlet GraphicalTextView* textView1;
    IBOutlet GraphicalTextView* textView2;
    IBOutlet UISegmentedControl* keyboardSelector;
    IBOutlet UISegmentedControl* styleSelector;
    UIPopoverController *popover_;
    SizePickerViewController* sizePickerViewController_;
    ColorPickupViewController* colorPickerViewController_;
}

- (IBAction)buttonBushed:(id)sender;

@end
