//
//  RootViewController.h
//  MarkupEditor
//
//  Created by shimizu on 11/03/15.
//  Copyright 2011 MK System. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphicalTextView.h"
#import "HandWritingView.h"

#import "SizePickerViewController.h"
#import "ColorPickupViewController.h"
#import "CanvasView.h"

@interface RootViewController :
UIViewController<
UIPopoverControllerDelegate, 
ColorPickupViewControllerDelegate,
SizePickerViewControllerDelegate,
UIAlertViewDelegate
> {
    IBOutlet GraphicalTextView* textView0;
    IBOutlet GraphicalTextView* textView1;
    IBOutlet GraphicalTextView* textView2;
    IBOutlet UISegmentedControl* keyboardSelector;
    //XIBがうまく動かなくなってしまったので急遽差し替え
    UISegmentedControl* styleSelector;
    UIPopoverController *popover_;
    SizePickerViewController* sizePickerViewController_;
    ColorPickupViewController* colorPickerViewController_;
    CanvasView* canvasView_;
}

- (IBAction)buttonBushed:(id)sender;

@end
