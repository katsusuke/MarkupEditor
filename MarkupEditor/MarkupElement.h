//
//  MarkupElement.h
//  CustomTextInputText
//
//  Created by shimizu on 11/02/23.
//  Copyright 2011 MK System. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MarkupDocument;

@class Pare;
@class MarkupView;
@class MarkupViewCache;

@protocol MarkupElement<NSObject>

- (void)layoutWithViewCache:(MarkupViewCache*)viewCache
            previousElement:(id<MarkupElement>)previous
              documentWidth:(CGFloat)documentWidth
                     isLast:(BOOL)isLast;
- (void)drawRect:(CGRect)rect;
- (NSInteger)length;
- (NSString*)stringFrom:(NSInteger)start
					 to:(NSInteger)end;

- (Pare*)splitAtIndex:(NSInteger)index;
- (id<MarkupElement>)connectBack:(id<MarkupElement>)rhs;

@property(nonatomic, readonly)MarkupView* lastView;

@optional
- (UIFont*)font;
- (UIColor*)color;
@property (nonatomic, readonly) UIFont* font;
@property (nonatomic, readonly) UIColor* color;

@end

@interface NewLine : NSObject<MarkupElement>
{
	UIFont* font_;
	MarkupView* markupView_;
}

- (id)initWithFont:(UIFont*)font;
@property (nonatomic, readonly) UIFont* font;

@end


@interface MarkupText : NSObject<MarkupElement, NSCopying>
{
	NSString* text_;
	UIFont* font_;
	UIColor* color_;
		
	NSMutableArray* textList_;
	NSMutableArray* markupViews_;
}

- (id)initWithText:(NSString*)text
              font:(UIFont*)font
             color:(UIColor*)color;

+ (MarkupText*)markupTextWithText:(NSString*)text
                             font:(UIFont*)font
                            color:(UIColor*)color;

@property (nonatomic, copy)NSString* text;

- (UIFont*)font;
- (UIColor*)color;
- (id)copyWithZone:(NSZone*)zone;

@end
