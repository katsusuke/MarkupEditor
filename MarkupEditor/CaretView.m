//
//  CaretView.m
//  CustomTextInputText
//
//  Created by shimizu on 11/03/14.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CaretView.h"

@implementation CaretView

@synthesize animated=animated_;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		[self setBackgroundColor:[UIColor blueColor]];
		[self animationFadeOut];
    }
    return self;
}

-(void)animationFadeIn {
	if (self.animated) {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
		[UIView setAnimationDuration:0.25];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(animationFadeOut)];
		self.alpha = 1.0f;
		[UIView commitAnimations];
	} else {
		self.alpha = 1.0f;
	}
}

-(void)animationFadeOut {
	if (self.animated) {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
		[UIView setAnimationDelay:0.45];
		[UIView setAnimationDuration:0.25];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(animationFadeIn)];
		self.alpha = 0.0f;
		[UIView commitAnimations];
	} else {
		self.alpha = 1.0f;
	}
}

- (void)dealloc
{
    [super dealloc];
}

@end
