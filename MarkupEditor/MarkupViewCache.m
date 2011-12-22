//
//  MarkupViewCache.m
//  MarkupEditor
//
//  Created by shimizu on 11/03/16.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MarkupViewCache.h"
#import "MarkupView.h"

@implementation MarkupViewCache

- (id)init {
    self = [super init];
    if (self) {
        caches_ = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)dealloc{
    [caches_ release];
    [super dealloc];
}

- (void)addViewCache:(MarkupView*)markupView;
{
    [caches_ addObject:markupView];
}

- (CGFloat)lineHeightWithLineNumber:(NSInteger)lineNumber
{
	CGFloat lineHeight = 0;
	BOOL find = NO;
	for(MarkupView* lv in caches_)
	{
		if(lv.lineNumber == lineNumber)
		{
			find = YES;
			lineHeight = MAX(lv.frame.size.height, lineHeight);
		}else if(find){
			break;
		}
	}
    ASSERT1(find, @"lineNumber:%d is out of range", lineNumber);
	return lineHeight;
}

- (NSArray*)lineBottomsByLine
{
    NSMutableArray* res = [NSMutableArray array];
    NSInteger lineNum = -1;
    for(MarkupView* lv in caches_){
        if(lineNum != lv.lineNumber){
            [res addObject:[NSNumber numberWithFloat:lv.lineBottom]];
            lineNum = lv.lineNumber;
        }
    }
    return res;
}

- (void)setLineViewOriginYWithNumber:(NSInteger)lineNumber
					  withLineHeight:(CGFloat)lineHeight
{
	for(MarkupView* lv in [self lineViewsWithNumber:lineNumber])
	{
		CGRect rc = lv.frame;
		rc.origin.y = lv.lineTop + lineHeight - rc.size.height;
		lv.frame = rc;
	}
}

- (NSArray*)lineViewsWithNumber:(NSInteger)lineNumber
{
	NSMutableArray* lineViews = [NSMutableArray array];
	BOOL find = NO;
	for(MarkupView* lv in caches_)
	{
		if(lv.lineNumber == lineNumber)
		{
			[lineViews addObject:lv];
		}else if(find){
			break;
		}
	}
	return lineViews;
}

@end
