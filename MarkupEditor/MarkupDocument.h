//
//  Document.h
//  CustomTextInputText
//
//  Created by shimizu on 11/02/23.
//  Copyright 2011 MK System. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MarkupElement.h"
#import "MarkupElementPosition.h"
#import "MarkupElementRange.h"
#import "MarkupViewCache.h"

@interface MarkupDocument : NSObject {
@private
	NSMutableArray* elements_;
    MarkupViewCache* viewCache_;
    
	BOOL layouted_;
	
	UIFont* defaultFont_;
	UIColor* defaultColor_;
}

- (id)init;
- (void)setTestData;


- (BOOL)positionIsValid:(MarkupElementPosition*)position;
- (MarkupElementPosition*)startPosition;
- (MarkupElementPosition*)endPosition;
@property(nonatomic, readonly) MarkupElementPosition* startPosition;
@property(nonatomic, readonly) MarkupElementPosition* endPosition;

@property(nonatomic, retain) UIFont* defaultFont;
@property(nonatomic, retain) UIColor* defaultColor;

- (NSInteger)elementCount;
- (id<MarkupElement>)elementAtIndex:(NSInteger)index;

- (void)drawRect:(CGRect)rect width:(CGFloat)width;
- (void)layoutWithWidth:(CGFloat)width;

- (NSString*)textInRange:(MarkupElementRange *)range;

- (void)replaceRange:(MarkupElementRange*)range withElements:(NSArray*)elements;
- (void)replaceRange:(MarkupElementRange*)range withText:(NSString*)text;
- (void)replaceRange:(MarkupElementRange*)range withText:(NSString*)text marked:(BOOL)marked;
- (void)replaceRange:(MarkupElementRange*)range withHandWritePoints:(NSArray*)points;

- (void)deleteWithRange:(MarkupElementRange*)range;
- (Pair*)splitElementsAtPosition:(MarkupElementPosition*)position;
- (MarkupElementPosition*)positionFromPosition:(MarkupElementPosition*)position
                                        offset:(NSInteger)offset;
- (MarkupElementPosition*)positionDownFromPosition:(MarkupElementPosition*)position lines:(NSInteger)lines;
- (NSInteger)offsetFrom:(MarkupElementPosition*)from to:(MarkupElementPosition*)to;
- (BOOL)positionIsLast:(MarkupElementPosition*)position;
- (void)insertElements:(NSArray*)insertElement atIndex:(NSInteger)index;
- (void)insertElements:(NSArray *)insertElements atPosition:(MarkupElementPosition*)position;

- (CGRect)caretRectForPosition:(MarkupElementPosition*)position width:(CGFloat)width;

- (void)unmarkTextWithRange:(MarkupElementRange*)range;

+ (NSArray*)connectMarkupElements:(NSArray*)lhs
                        andOthers:(NSArray*)rhs;
+ (void)getFirstFont:(UIFont**)refFont andColor:(UIColor**)refColor fromElements:(NSArray*)elements;
+ (void)getLastFont:(UIFont**)refFont andColor:(UIColor**)refColor fromElements:(NSArray*)elements;

@end
