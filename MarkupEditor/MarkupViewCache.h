//
//  MarkupViewCache.h
//  MarkupEditor
//
//  Created by shimizu on 11/03/16.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MarkupView;

@interface MarkupViewCache : NSObject {
@private
    //各MarkupViews は先頭から順番に入ってる
	NSMutableArray* caches_;    
}

- (void)addViewCache:(MarkupView*)markupView;

- (CGFloat)lineHeightWithLineNumber:(NSInteger)lineNumber;
- (NSArray*)lineBottomsByLine;
- (void)setLineViewOriginYWithNumber:(NSInteger)lineNumber
					  withLineHeight:(CGFloat)lineHeight;
- (NSArray*)lineViewsWithNumber:(NSInteger)lineNumber;

@end
