//
//  CaretView.h
//  CustomTextInputText
//
//  Created by shimizu on 11/03/14.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CaretView : UIView {
	bool animated_;
}

@property (nonatomic, assign) bool animated;

-(void)animationFadeIn;
-(void)animationFadeOut;

@end
