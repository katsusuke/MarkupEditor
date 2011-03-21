//
//  MarkupElementTest.m
//  MarkupEditor
//
//  Created by shimizu on 11/03/17.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MarkupElementTest.h"

@implementation MarkupElementTest

- (void)setUp{
    [super setUp];
    tx0 = [[MarkupText textWithText:@"abc"
                                   font:[UIFont systemFontOfSize:10]
                                    color:[UIColor redColor]]retain];
    tx1 = [[MarkupText textWithText:@"defg"
                                     font:[UIFont systemFontOfSize:10]
                                    color:[UIColor redColor]]retain];
    tx2 = [[MarkupText textWithText:@"hijkl"
                                     font:[UIFont systemFontOfSize:12]
                                    color:[UIColor redColor]]retain];
    nl0 = [[MarkupNewLine newLineWithFont:[UIFont systemFontOfSize:12]]retain];
    nl1 = [[MarkupNewLine newLineWithFont:[UIFont systemFontOfSize:12]]retain];
}

- (void)tearDown{
    [tx0 release];
    [tx1 release];
    [tx2 release];
    [nl0 release];
    [nl1 release];
    
    [super tearDown];
}

- (void)testLength{
    STAssertEquals(tx0.length, 3, @"");
    STAssertEquals(nl0.length, 1, @"");
}

- (void)testStringFromTo
{
    STAssertEqualObjects([tx0 stringFrom:0 to:1], @"a", @"first");
    STAssertEqualObjects([tx0 stringFrom:1 to:2], @"b", @"center");
    STAssertEqualObjects([tx0 stringFrom:2 to:3], @"c", @"last");
    STAssertEqualObjects([tx0 stringFrom:0 to:0], @"", @"");
    STAssertEqualObjects([tx0 stringFrom:3 to:3], @"", @"");
    STAssertEqualObjects([tx0 stringFrom:2 to:2], @"", @"");
    
    STAssertEqualObjects([nl0 stringFrom:0 to:1], @"\n", @"new line");
    STAssertEqualObjects([nl0 stringFrom:0 to:0], @"", @"");
    STAssertEqualObjects([nl0 stringFrom:1 to:1], @"", @"");
}

- (void)testSplit
{
    {
        Pair* p = [tx0 splitAtIndex:0];
        STAssertNil(p.first, @"");
        STAssertNotNil(p.second, @"");
        id<MarkupElement> e1 = p.second;
        STAssertEqualObjects(e1.font, [UIFont systemFontOfSize:10], @"");
        STAssertEqualObjects(e1.color, [UIColor redColor], @"");
        STAssertEqualObjects(e1.stringValue, @"abc", @"");
    }
    {
        Pair* p = [tx0 splitAtIndex:1];
        STAssertNotNil(p.first, @"");
        id<MarkupElement> e0 = p.first;
        STAssertEqualObjects(e0.font, [UIFont systemFontOfSize:10], @"");
        STAssertEqualObjects(e0.color, [UIColor redColor], @"");
        STAssertEqualObjects(e0.stringValue, @"a", @"");
        
        STAssertNotNil(p.second, @"");
        id<MarkupElement> e1 = p.second;
        STAssertEqualObjects(e1.font, [UIFont systemFontOfSize:10], @"");
        STAssertEqualObjects(e1.color, [UIColor redColor], @"");
        STAssertEqualObjects(e1.stringValue, @"bc", @"");
    }
    {
        Pair* p = [tx0 splitAtIndex:3];
        STAssertNotNil(p.first, @"");
        STAssertNil(p.second, @"");
        id<MarkupElement> e1 = p.first;
        STAssertEqualObjects(e1.font, [UIFont systemFontOfSize:10], @"");
        STAssertEqualObjects(e1.color, [UIColor redColor], @"");
        STAssertEqualObjects(e1.stringValue, @"abc", @"");
    }
    {
        Pair* p = [nl0 splitAtIndex:0];
        STAssertNil(p.first, @"");
        id<MarkupElement> e = p.second;
        STAssertEqualObjects(e.font, [UIFont systemFontOfSize:12], @"");
        STAssertEqualObjects(e.stringValue, @"\n", @"");
    }
    {
        Pair* p = [nl0 splitAtIndex:1];
        STAssertNil(p.second, @"");
        id<MarkupElement> e = p.first;
        STAssertEqualObjects(e.font, [UIFont systemFontOfSize:12], @"");
        STAssertEqualObjects(e.stringValue, @"\n", @"");
    }
}

- (void)testConnectBack{
    {
        // tx + tx => tx
        id<MarkupElement> e = [tx0 connectBack:tx1];
        STAssertNotNil(e, @"");
        STAssertEqualObjects(e.font, [UIFont systemFontOfSize:10], @"");
        STAssertEqualObjects(e.color, [UIColor redColor], @"");
        STAssertEqualObjects(e.stringValue, @"abcdefg", @"");
    }
    {
        // tx + tx => nil
        id<MarkupElement> e = [tx0 connectBack:tx2];
        STAssertNil(e, @"");
    }
    {
        // tx + nl => nil
        id<MarkupElement> e = [tx0 connectBack:nl0];
        STAssertNil(e, @"");
    }
    {
        // nl + nl => nil
        id<MarkupElement> e = [nl0 connectBack:nl1];
        STAssertNil(e, @"");
    }
}
@end
