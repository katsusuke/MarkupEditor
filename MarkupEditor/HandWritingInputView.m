//
//  HandWritingInputView.m
//  MarkupEditor
//
//  Created by shimizu on 11/03/23.
//  Copyright 2011 MK System. All rights reserved.
//

#import "HandWritingInputView.h"
#import "GraphicalTextView.h"

@implementation HandWritingInputView

static CGSize HandWritingViewSize = {200, 240};

- (id)initWithGraphicalTextView:(GraphicalTextView*)textView
{
    CGSize size = [[UIScreen mainScreen]applicationFrame].size;
    
    self = [super initWithFrame:CGRectMake(0, 0, size.width, HandWritingViewSize.height + 20)];
    if (self) {
        textView_ = [textView retain];
        self.backgroundColor = [UIColor darkGrayColor];
        self.autoresizesSubviews = YES;
        
        CGFloat buttonWidth = 100;
        CGFloat buttonHeight = 40;
        
        UIButton* nextButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        nextButton.frame = CGRectMake(10, 10, buttonWidth, buttonHeight);
        [nextButton setTitle:@"Next" forState:UIControlStateNormal];
        [nextButton addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton* clearButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        clearButton.frame = CGRectMake(10, 60, buttonWidth, buttonHeight);
        [clearButton setTitle:@"Clear" forState:UIControlStateNormal];
        [clearButton addTarget:self action:@selector(clear) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton* backspaceButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        backspaceButton.frame = CGRectMake(10, 110, buttonWidth, buttonHeight);
        [backspaceButton setTitle:@"delete" forState:UIControlStateNormal];
        [backspaceButton addTarget:self action:@selector(backspace) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton* returnButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        returnButton.frame = CGRectMake(10, 160, buttonWidth, buttonHeight);
        [returnButton setTitle:@"return" forState:UIControlStateNormal];
        [returnButton addTarget:self action:@selector(newLine) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton* spaceButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        spaceButton.frame = CGRectMake(10, 210, buttonWidth, buttonHeight);
        [spaceButton setTitle:@"space" forState:UIControlStateNormal];
        [spaceButton addTarget:self action:@selector(space) forControlEvents:UIControlEventTouchUpInside];
        
        CGFloat margin = (size.width - 10 * 3 - buttonWidth - HandWritingViewSize.width * 3) / 2;
        
        CGRect hwv0Frame
        = CGRectMake(10 * 2 + buttonWidth, 10,
                     HandWritingViewSize.width, HandWritingViewSize.height);
        CGRect hwv1Frame = CGRectMake(CGRectGetMaxX(hwv0Frame) + margin, 10,
                                      HandWritingViewSize.width, HandWritingViewSize.height);
        CGRect hwv2Frame = CGRectMake(CGRectGetMaxX(hwv1Frame) + margin, 10, 
                                      HandWritingViewSize.width, HandWritingViewSize.height);
        
        handWritingViews_[0] = [[HandWritingView alloc]initWithFrame:hwv0Frame];
        handWritingViews_[1] = [[HandWritingView alloc]initWithFrame:hwv1Frame];
        handWritingViews_[2] = [[HandWritingView alloc]initWithFrame:hwv2Frame];
        
        for(int i = 0; i < HandWritingViewsCount; ++i){
            handWritingViews_[i].autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            [handWritingViews_[i] addTarget:self action:@selector(handWritedWithView:)];
            [self addSubview:handWritingViews_[i]];
        }
        
        [self addSubview:nextButton];
        [self addSubview:clearButton];
        [self addSubview:backspaceButton];
        [self addSubview:returnButton];
        [self addSubview:spaceButton];
    }
    return self;
}

- (void)dealloc
{
    for(int i = 0; i < HandWritingViewsCount; ++i){
        [handWritingViews_[i] release];
    }
    [super dealloc];
}

- (void)next{
    for(int i = 0; i < HandWritingViewsCount; ++i){
        if([handWritingViews_[i] hasPoints]){
            NSArray* points = [handWritingViews_[i] points];
            [textView_ addHandWritingPoints:points];
            [handWritingViews_[i] clear];
        }
    }
}
- (void)clear{
    for(int i = 0; i < HandWritingViewsCount; ++i){
        if([handWritingViews_[i] hasPoints]){
            [handWritingViews_[i] clear];
        }
    }
}
- (void)backspace{
    [textView_ deleteBackward];
}
- (void)newLine{
    [self next];
    [textView_ insertText:@"\n"];
}
- (void)space{
    [self next];
    [textView_ insertText:@" "];
}


- (void)handWritedWithView:(HandWritingView*)view
{   
    if(previousWritedView_ != view){
        if([previousWritedView_ hasPoints]){
            NSArray* points = [previousWritedView_ points];
            [textView_ addHandWritingPoints:points];
            [previousWritedView_ clear];
        }
    }
    previousWritedView_ = view;
}

@end
