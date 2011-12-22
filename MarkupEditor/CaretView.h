//
//  CaretView.h
//  CustomTextInputText
//
//  Created by shimizu on 11/03/14.
//  Copyright 2011 MK System. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CaretView : UIView {
	BOOL animated_;
    NSTimer* blinkTimer_;
}

+ (UIColor*)caretColor;
+ (UIColor*)selectionColor;


@property (nonatomic, assign) BOOL animated;

-(void)animationFadeIn;
-(void)animationFadeOut;
-(void)delayBlink;

@end
