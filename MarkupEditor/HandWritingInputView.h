//
//  HandWritingInputView.h
//  MarkupEditor
//
//  Created by shimizu on 11/03/23.
//  Copyright 2011 MK System. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HandWritingView.h"

@class GraphicalTextView;

enum{
    HandWritingViewsCount = 3,
};


@interface HandWritingInputView : UIView {
    GraphicalTextView* textView_;
    
    HandWritingView* handWritingViews_[HandWritingViewsCount];
    
    HandWritingView* previousWritedView_;
}

- (id)initWithGraphicalTextView:(GraphicalTextView*)textView;

- (void)handWritedWithView:(HandWritingView*)view;

@end
