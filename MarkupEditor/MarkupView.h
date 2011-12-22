//
//  MarkupView.h
//  MarkupEditor
//
//  Created by shimizu on 11/03/15.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MarkupElement;

@interface MarkupView : NSObject 
{
	id<MarkupElement> element_;
	NSInteger lineNumber_;
    //各行内での順番
	NSInteger order_;
	CGFloat lineTop_;
	CGRect frame_;
}

- (id)initWithMarkupElement:(id<MarkupElement>)markupElement
				 lineNumber:(NSInteger)lineNumber
					  order:(NSInteger)order
					lineTop:(CGFloat)lineTop
					  frame:(CGRect)lineViewFrame;

- (CGFloat)lineBottom;

@property (nonatomic, assign)id<MarkupElement> element;
@property (nonatomic, assign)NSInteger lineNumber;
@property (nonatomic, assign)NSInteger order;
@property (nonatomic, assign)CGFloat lineTop;
@property (nonatomic, readonly, getter=lineBottom)CGFloat lineBottom;
@property (nonatomic, assign)CGRect frame;

@end
