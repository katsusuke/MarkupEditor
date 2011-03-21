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
    //日本語入力字などで変換途中の文字
    MarkupElementRange* markedTextRange_;
    NSDictionary* markedTextStyle_;
    id<UITextInputDelegate> inputDelegate_;
    id<UITextInputTokenizer> tokenizer_;
}

@end
