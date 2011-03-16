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
	NSMutableArray* elements_;
    MarkupViewCache* viewCache_;
    
	BOOL layouted_;
	
	UIFont* defaultFont_;
	UIColor* defaultColor_;
	
}

- (id)init;
- (void)drawRect:(CGRect)rect width:(CGFloat)width;
- (void)layoutWithWidth:(CGFloat)width;
- (NSString*)textInRange:(MarkupElementRange *)range;
- (void)replaceRange:(MarkupElementRange*)range withText:(NSString*)text;

@property (nonatomic, readonly)NSMutableArray* markupElements;

- (Pare*)splitElementsAtPosition:(MarkupElementPosition*)position;
- (MarkupElementPosition*)positionFromPosition:(MarkupElementPosition*)position
                                        offset:(NSInteger)offset;
- (NSInteger)offsetFrom:(MarkupElementPosition*)from to:(MarkupElementPosition*)to;
- (BOOL)positionIsLast:(MarkupElementPosition*)position;

- (void)setTestData;

+ (NSMutableArray*)connectMarkupElements:(NSArray*)lhs
                        andOthers:(NSArray*)rhs;


@end
