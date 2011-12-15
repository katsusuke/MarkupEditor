//
//  MarkupView.m
//  MarkupEditor
//
//  Created by shimizu on 11/03/15.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MarkupView.h"


@implementation MarkupView
@synthesize element=element_;
@synthesize lineNumber=lineNumber_;
@synthesize order=order_;
@synthesize lineTop=lineTop_;
@synthesize frame=frame_;

- (id)initWithMarkupElement:(id<MarkupElement>)markupElement
                 lineNumber:(NSInteger)lineNumber
                      order:(NSInteger)order
                    lineTop:(CGFloat)lineTop
                      frame:(CGRect)lineViewFrame
{
	self = [super init];
	if(self){
		element_ = markupElement;
		lineNumber_ = lineNumber;
		order_ = order;
		lineTop_ = lineTop;
		frame_ = lineViewFrame;
	}
	return self;
}

- (CGFloat)lineBottom
{
	return frame_.origin.y + frame_.size.height;
}

@end
