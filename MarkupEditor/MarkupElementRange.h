//
//  MarkupElementRange.h
//  MarkupEditor
//
//  Created by shimizu on 11/03/15.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MarkupElementPosition.h"


@interface MarkupElementRange : UITextRange {
@private
    MarkupElementPosition* start_;
    MarkupElementPosition* end_;
}

- (id)initWithStart:(MarkupElementPosition*)start
                end:(MarkupElementPosition*)end;
- (MarkupElementPosition*)startPosition;
- (MarkupElementPosition*)endPosition;

#pragma mark -
#pragma mark UITextPosition Methods

- (UITextPosition*)start;
- (UITextPosition*)end;
- (BOOL)empty;

@end
