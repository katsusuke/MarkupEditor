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

@interface RootViewController : UIViewController {
    IBOutlet GraphicalTextView* textView0;
    IBOutlet GraphicalTextView* textView1;
    IBOutlet GraphicalTextView* textView2;
}

- (IBAction)buttonBushed:(id)sender;

@end
