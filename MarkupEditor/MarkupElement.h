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

@protocol MarkupElement<NSCopying, NSObject>

- (id)copy;

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
- (NSString*)stringValue;
@property (nonatomic, readonly) UIFont* font;
@property (nonatomic, readonly) UIColor* color;
@property (nonatomic, readonly) NSString* stringValue;

@end

@interface MarkupNewLine : NSObject<MarkupElement>
{
	UIFont* font_;
	MarkupView* markupView_;
}

- (id)initWithFont:(UIFont*)font;
+ (MarkupNewLine*)newLineWithFont:(UIFont*)font;
@property (nonatomic, readonly) UIFont* font;

@end


@interface MarkupText : NSObject<MarkupElement>
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

+ (MarkupText*)textWithText:(NSString*)text
                             font:(UIFont*)font
                            color:(UIColor*)color;

@property (nonatomic, copy)NSString* text;

- (UIFont*)font;
- (UIColor*)color;
- (id)copyWithZone:(NSZone*)zone;

@end
