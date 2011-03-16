//
//  Pare.m
//  CustomTextInputText
//
//  Created by shimizu on 11/03/10.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Pare.h"

@implementation Pare

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
            [[self class]description],
            first_, second_];
}

+ (id)pare{
    return [[[[self class]alloc]init]autorelease];
}

+ (id)pareWithFirst:(id)first second:(id)second{
    return [[[[self class]alloc]initWithFirst:first second:second]autorelease];
}

@end
