//
//  MarkupElementPosition.h
//  CustomTextInputText
//
//  Created by shimizu on 11/03/10.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Pare.h"

@interface MarkupElementPosition : UITextPosition<NSCopying> {
@private
    NSInteger elementIndex_;
    NSInteger valueIndex_;
    BOOL inAnElement_;
}
@property (nonatomic, assign) NSInteger elementIndex;
@property (nonatomic, assign) NSInteger valueIndex;
@property (nonatomic, assign) BOOL inAnElement;
@property (nonatomic, readonly) BOOL isFirst;

- (id)initWithElementIndex:(NSInteger)elementIndex
                valueIndex:(NSInteger)valueIndex;
+ (id)positionWithElementIndex:(NSInteger)elementIndex
                    valueIndex:(NSInteger)valueIndex;

- (BOOL)isEqualToPosition:(MarkupElementPosition*)rhs;
- (NSComparisonResult)compareTo:(MarkupElementPosition*)other;

@end
