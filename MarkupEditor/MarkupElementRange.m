//
//  MarkupElementRange.m
//  MarkupEditor
//
//  Created by shimizu on 11/03/15.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MarkupElementRange.h"


@implementation MarkupElementRange

- (UITextPosition*)start{
    return start_;
}
- (UITextPosition*)end{
    return end_;
}
- (MarkupElementPosition*)startPosition{
    return start_;
}
- (MarkupElementPosition*)endPosition{
    return end_;
}

- (id)initWithStart:(MarkupElementPosition *)start end:(MarkupElementPosition *)end
{
    self = [super init];
    if(self){
        start_ = [start copy];
        end_ = [end copy];
    }
    return self;
}

- (BOOL)empty{
    return [start_ isEqualToPosition:end_];
}


- (id)copyWithZone:(NSZone *)zone
{
    return [[[self class]allocWithZone:zone]initWithStart:start_
                                                      end:end_];
}

- (void)dealloc{
    [start_ release];
    [end_ release];
    [super dealloc];
}

- (NSString*)description{
    return [NSString stringWithFormat:
            @"<%@ start:%@ end%@>",
            [[self class]description],
            start_, 
            end_];
}

@end
