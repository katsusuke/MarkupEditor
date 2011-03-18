//
//  MarkupElementPositionTest.m
//  MarkupEditor
//
//  Created by shimizu on 11/03/16.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MarkupElementPositionTest.h"
#import "MarkupElementPosition.h"

@implementation MarkupElementPositionTest

- (void)testInit{
    MarkupElementPosition* p0
    = [[MarkupElementPosition alloc]initWithElementIndex:0 valueIndex:0];
    STAssertNotNil(p0, @"init");
    [p0 release];
    MarkupElementPosition* p1
    = [MarkupElementPosition positionWithElementIndex:0 valueIndex:0];
    STAssertNotNil(p1, @"position");
}
 
- (void)testCompare{
    MarkupElementPosition* p2
    = [MarkupElementPosition positionWithElementIndex:10 valueIndex:20];
    MarkupElementPosition* p3
    = [MarkupElementPosition positionWithElementIndex:10 valueIndex:20];
    STAssertEqualObjects(p2, p3, @"isEqual:");
    STAssertTrue([p2 isEqualToPosition:p3], @"isEqualToPosition:");
    MarkupElementPosition* p4
    = [MarkupElementPosition positionWithElementIndex:10 valueIndex:30];
    MarkupElementPosition* p5
    = [MarkupElementPosition positionWithElementIndex:30 valueIndex:20];
    STAssertFalse([p2 isEqualToPosition:p4], @"isEqualToPosition:");
    STAssertFalse([p2 isEqualToPosition:p5], @"isEqualToPosition:");
    
    STAssertEquals([p2 compareTo:p3], NSOrderedSame, @"compare same");
    STAssertEquals([p2 compareTo:p4], NSOrderedAscending, @"compare ascending");
    STAssertEquals([p2 compareTo:p5], NSOrderedAscending, @"compare ascending2");
    STAssertEquals([p4 compareTo:p2], NSOrderedDescending, @"compare descending");
    STAssertEquals([p5 compareTo:p2], NSOrderedDescending, @"compare descending");
    
}

@end
