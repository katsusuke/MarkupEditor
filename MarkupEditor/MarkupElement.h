//
//  MarkupElement.h
//  CustomTextInputText
//
//  Created by shimizu on 11/02/23.
//  Copyright 2011 MK System. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CACommon.h"

@class Pair;
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

- (Pair*)splitAtIndex:(NSInteger)index;
- (BOOL)isConnectableTo:(id<MarkupElement>)lhs;
- (id<MarkupElement>)connectBack:(id<MarkupElement>)rhs;
- (CGRect)createRectForValueIndex:(NSInteger)valueIndex;

@property(nonatomic, readonly)MarkupView* lastView;

@optional
- (UIFont*)font;
- (UIColor*)color;
- (NSString*)stringValue;
@property (nonatomic, readonly) UIFont* font;
@property (nonatomic, readonly) UIColor* color;
@property (nonatomic, readonly) NSString* stringValue;
@property (nonatomic, assign)BOOL marked;

@end

@interface MarkupNewLine : NSObject<MarkupElement>
{
	UIFont* font_;
	MarkupView* markupView_;
}

- (id)initWithFont:(UIFont*)font;
+ (id)markupNewLineWithFont:(UIFont*)font;
@property (nonatomic, readonly) UIFont* font;

@end


@interface MarkupText : NSObject<MarkupElement>
{
    BOOL marked_;
	NSString* text_;
	UIFont* font_;
	UIColor* color_;
		
	NSMutableArray* textList_;
	NSMutableArray* markupViews_;
}

- (id)initWithText:(NSString*)text
              font:(UIFont*)font
             color:(UIColor*)color
            marked:(BOOL)marked;

+ (id)textWithText:(NSString*)text
                       font:(UIFont*)font
                      color:(UIColor*)color
                     marked:(BOOL)marked;

+ (id)textWithText:(NSString*)text
                       font:(UIFont*)font
                      color:(UIColor*)color;

@property (nonatomic, copy)NSString* text;
@property (nonatomic, assign)BOOL marked;

- (UIFont*)font;
- (UIColor*)color;
- (id)copyWithZone:(NSZone*)zone;
- (NSInteger)valueIndexFromPoint:(CGPoint)point;

@end

@interface MarkupHandWritingChar : NSObject<MarkupElement> {
@private
    NSArray* points_;
    UIFont* font_;
    UIColor* color_;
    MarkupView* markupView_;
    BitmapContext* bitmap_;
    CGSize size_;
}

- (id)initWithPoints:(NSArray*)points
                font:(UIFont*)font
               color:(UIColor*)color;

+ (id)charWithPoints:(NSArray*)points
                font:(UIFont*)font
               color:(UIColor*)color;

@property (nonatomic, readonly) UIFont* font;
@property (nonatomic, readonly) UIColor* color;

@end
