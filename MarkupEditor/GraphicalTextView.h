//
//  GraphicalTextView.h
//  CustomTextInputText
//
//  Created by shimizu on 11/02/21.
//  Copyright 2011 MK System. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MarkupDocument.h"

@interface GraphicalTextView : UIView
<
UITextInput
>
{
	MarkupDocument* document_;

    MarkupElementRange* selectedTextRange_;
    MarkupElementRange* markedTextRange_;
    NSDictionary* markedTextStyle_;
    id<UITextInputDelegate> inputDelegate_;
    id<UITextInputTokenizer> tokenizer_;
}

@end
