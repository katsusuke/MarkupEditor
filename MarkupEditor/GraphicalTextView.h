//
//  GraphicalTextView.h
//  CustomTextInputText
//
//  Created by shimizu on 11/02/21.
//  Copyright 2011 MK System. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CaretView.h"
#import "MarkupViewCache.h"
#import "MarkupElementRange.h"

typedef enum{
    InputTextModeQwerty,
    InputTextModeHandWriting,
}
InputTextMode;

@interface GraphicalTextView : UIView<UITextInput>
{
    @private
	NSMutableArray* elements_;
    MarkupViewCache* viewCache_;
    
	BOOL layouted_;
	
	UIFont* defaultFont_;
	UIColor* defaultColor_;
    
    UIFont* specificFont_;
    UIColor* specificColor_;

    MarkupElementRange* selectedTextRange_;
    //日本語入力字などで変換途中の文字
    MarkupElementRange* markedTextRange_;
    NSDictionary* markedTextStyle_;
    id<UITextInputDelegate> inputDelegate_;
    id<UITextInputTokenizer> tokenizer_;
    CaretView* cartView_;
    
    InputTextMode inputTextMode_;
}

- (UIView*)inputView;

@property (nonatomic, assign)InputTextMode inputTextMode;
@property (nonatomic, retain) UIFont* defaultFont;
@property (nonatomic, retain) UIColor* defaultColor;
@property (nonatomic, readonly) MarkupElementPosition* beginPosition;
@property (nonatomic, readonly) MarkupElementPosition* endPosition;

@property (nonatomic, retain) UIFont* specificFont;
@property (nonatomic, retain) UIColor* specificColor;

- (void)addHandWritingPoints:(NSArray*)array;

@end
