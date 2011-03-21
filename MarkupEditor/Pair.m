//
//  Pair.m
//  CustomTextInputText
//
//  Created by shimizu on 11/03/10.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Pair.h"

@implementation Pair

@synthesize first=first_;
@synthesize second=second_;

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (id)initWithFirst:(id)first second:(id)second
{
    self = [super init];
    if(self){
        first_ = [first retain];
        second_ = [second retain];
    }
    return self;
}

- (void)dealloc{
    [first_ release];
    [second_ release];
    [super dealloc];
}

- (NSString*)description{
    return [NSString stringWithFormat:
            @"<%@ first:%@ second:%@>",
            [super description],
            [first_ description],
            [second_ description]];
}

+ (id)pair{
    return [[[[self class]alloc]init]autorelease];
}

+ (id)pairWithFirst:(id)first second:(id)second{
    return [[[[self class]alloc]initWithFirst:first second:second]autorelease];
}

@end
