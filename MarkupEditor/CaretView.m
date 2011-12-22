//
//  CaretView.m
//  CustomTextInputText
//
//  Created by shimizu on 11/03/14.
//  Copyright 2011 MK System. All rights reserved.
//

#import "CaretView.h"

@implementation CaretView

static const NSTimeInterval InitialBlinkDelay = 0.7;
static const NSTimeInterval BlinkRate = 0.5;

@synthesize animated=animated_;

// Class method that returns current caret color (note that in this sample,
// the color cannot be changed)
+ (UIColor *)caretColor
{
    static UIColor *color = nil;
    if (color == nil) {
        color = [[UIColor alloc] initWithRed:0.25 green:0.50 blue:1.0 alpha:1.0];
    }
    return color;
}

+ (UIColor*)selectionColor
{
    static UIColor *color = nil;
    if (color == nil) {
        color = [[UIColor alloc] initWithRed:0.25 green:0.50 blue:1.0 alpha:0.50];    
    }    
    return color;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		[self setBackgroundColor:[CaretView caretColor]];
		[self animationFadeOut];
    }
    return self;
}
- (void)dealloc
{
    [blinkTimer_ invalidate];
    [blinkTimer_ release];
    [super dealloc];
}

- (void)blink{
    self.hidden = !self.hidden;
}
- (void)delayBlink
{
    self.hidden = NO;
    [blinkTimer_ setFireDate:[NSDate dateWithTimeIntervalSinceNow:InitialBlinkDelay]];
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

- (void)didMoveToSuperview
{
    self.hidden = NO;
    
    if (self.superview) {
        blinkTimer_ = [[NSTimer scheduledTimerWithTimeInterval:BlinkRate
                                                        target:self
                                                      selector:@selector(blink)
                                                      userInfo:nil
                                                       repeats:YES] retain];
        [self delayBlink];
    } else {
        [blinkTimer_ invalidate];
        [blinkTimer_ release];
        blinkTimer_ = nil;        
    }
}


@end
