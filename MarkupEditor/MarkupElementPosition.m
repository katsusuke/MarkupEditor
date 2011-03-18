//
//  MarkupElementPosition.m
//  CustomTextInputText
//
//  Created by shimizu on 11/03/10.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MarkupElementPosition.h"
#import "MarkupElement.h"


@implementation MarkupElementPosition

@synthesize elementIndex=elementIndex_;
@synthesize valueIndex=valueIndex_;
@synthesize inAnElement=inAnElement_;

- (id)initWithElementIndex:(NSInteger)elementIndex
                valueIndex:(NSInteger)valueIndex
{
    self = [super init];
    if(self){
        if(elementIndex < 0 || valueIndex < 0){
            [self release];
            return nil;
        }
        elementIndex_ = elementIndex;
        valueIndex_ = valueIndex;
        inAnElement_ = valueIndex_ != 0;
    }
    return self;
}

+ (id)positionWithElementIndex:(NSInteger)elementIndex
                    valueIndex:(NSInteger)valueIndex
{
    return [[[[self class]alloc]initWithElementIndex:elementIndex
                                          valueIndex:valueIndex]autorelease];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[[self class]allocWithZone:zone]initWithElementIndex:elementIndex_
                                                      valueIndex:valueIndex_];
}

- (void)dealloc{
    [super dealloc];
}

- (NSString*)description{
    return [NSString stringWithFormat:
            @"%@(elementIndex:%d valueIndex:%d inAnElement:%d)",
            [super description],
            elementIndex_,
            valueIndex_,
            inAnElement_];
}

- (BOOL)isFirst{
    return elementIndex_ == 0 && valueIndex_ == 0;
}

- (BOOL)isEqual:(id)object
{
    return [self isEqualToPosition:(MarkupElementPosition*)object];
}

- (BOOL)isEqualToPosition:(MarkupElementPosition *)rhs
{
    return elementIndex_ == rhs.elementIndex &&
    valueIndex_ == rhs.valueIndex;
}

- (NSComparisonResult)compareTo:(MarkupElementPosition*)other{
    if(elementIndex_ < other.elementIndex){
        return NSOrderedAscending;
    }
    else if(elementIndex_ > other.elementIndex){
        return NSOrderedDescending;
    }
    else{
        if(valueIndex_ < other.valueIndex){
            return NSOrderedAscending;
        }
        else if(valueIndex_ > other.valueIndex){
            return NSOrderedDescending;
        }
        else{
            return NSOrderedSame;
        }
    }
}

@end

