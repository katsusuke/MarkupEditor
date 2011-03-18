//
//  MarkupDocumentTest.m
//  MarkupEditor
//
//  Created by shimizu on 11/03/17.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MarkupDocumentTest.h"
#import "MarkupDocument.h"
#import <Foundation/Foundation.h>

@implementation MarkupDocumentTest


- (void) setUp;
{
    [super setUp];
    
    d = [[MarkupDocument alloc]init];
    [d setTestData];
}
- (void) tearDown;
{
    [d release];
    
    [super tearDown];
}

- (void)testInit{
    MarkupDocument* d1 = [[MarkupDocument alloc]init];
    STAssertNotNil(d1, @"init");
    [d1 release];
}

- (void)testTextInRange{
    NSString* t0
    = [d textInRange:[MarkupElementRange rangeWithStart:d.startPosition
                                                    end:d.endPosition]];
    STAssertEqualObjects(t0,
                         @"abcdEFGhijklmnopqrstuvw\n"
                         @"xyzあいうえおかきくけこ\n"
                         @"abcdEFGhij",
                         @"textInRange", @"all text");
    
    NSString* t1
    = [d textInRange:[MarkupElementRange rangeWithStartElement:0
                                               startValueIndex:1
                                                    endElement:9
                                                 endValueIndex:2]];
    
    STAssertEqualObjects(t1,
                         @"bcdEFGhijklmnopqrstuvw\n"
                         @"xyzあいうえおかきくけこ\n"
                         @"abcdEFGhi",
                         @"textInRang", @"Range is Middle");
    
    NSString* t2
    = [d textInRange:[MarkupElementRange rangeWithStartElement:0
                                               startValueIndex:1
                                                    endElement:0
                                                 endValueIndex:3]];
    STAssertEqualObjects(t2,
                         @"bc", @"Range is single element");
    NSString* t3
    = [d textInRange:[MarkupElementRange rangeWithStartElement:4
                                               startValueIndex:0
                                                    endElement:5
                                                 endValueIndex:0]];
    STAssertEqualObjects(t3, @"\n", @"Range is newline");
}

- (void)testReplaceInRangeFirst
{
    P(@"%d", [d elementCount]);
    [d replaceRange:[MarkupElementRange rangeWithStart:d.startPosition
                                                   end:d.startPosition]
           withText:@"ほげ\nぴよ"];
    //0: ほげ systemFont16 red
    //1: \n systemFont16
    //2: ぴよabcd systemFont16 red
    //3: EFG systemFont30 blue 変更無し
    // elementCount == 12
    //になるはず
    STAssertEquals([d elementCount], 12, @"");
    
    id<MarkupElement> e0 = [[[d elementAtIndex:0]copy]autorelease];
    id<MarkupElement> e1 = [[[d elementAtIndex:1]copy]autorelease];
    id<MarkupElement> e2 = [[[d elementAtIndex:2]copy]autorelease];
    id<MarkupElement> e3 = [[[d elementAtIndex:3]copy]autorelease];
    
    STAssertTrue([e0 isMemberOfClass:[MarkupText class]], @"");
    STAssertEqualObjects(e0.font, [UIFont systemFontOfSize:16], @"");
    STAssertEqualObjects(e0.color, [UIColor redColor], @"");
    STAssertEqualObjects(e0.stringValue, @"ほげ", @"");
    
    STAssertTrue([e1 isMemberOfClass:[MarkupNewLine class]], @"");
    STAssertEqualObjects(e1.font, [UIFont systemFontOfSize:16], @"");
    
    STAssertTrue([e2 isMemberOfClass:[MarkupText class]], @"");
    STAssertEqualObjects(e2.font, [UIFont systemFontOfSize:16], @"");
    STAssertEqualObjects(e2.color, [UIColor redColor], @"");
    STAssertEqualObjects(e2.stringValue, @"ぴよabcd", @"");
    
    STAssertTrue([e3 isMemberOfClass:[MarkupText class]], @"");
    STAssertEqualObjects(e3.font, [UIFont systemFontOfSize:30], @"");
    STAssertEqualObjects(e3.color, [UIColor blueColor], @"");
    STAssertEqualObjects(e3.stringValue, @"EFG", @"");
}

//先頭にひっつかないパターン
- (void)testInsertElementAtIndexTop{
    STAssertEqualObjects(d.defaultFont, [UIFont systemFontOfSize:16], @"");
    STAssertEqualObjects(d.defaultColor, [UIColor redColor], @"");
    NSArray* a = [NSArray arrayWithObjects:
                  [MarkupNewLine newLineWithFont:[UIFont systemFontOfSize:90]],
                  [MarkupText textWithText:@"あいう"
                                      font:[UIFont systemFontOfSize:30]
                                     color:[UIColor darkGrayColor]], nil];
    [d insertElements:a atIndex:0];
    STAssertEqualObjects(d.defaultFont, [UIFont systemFontOfSize:90], @"");
    STAssertEqualObjects(d.defaultColor, [UIColor darkGrayColor], @"");
    STAssertEquals([d elementCount], 12, @"");
}
//TODO 先頭にひっつくパターン
- (void)testInsertElementAtIndexTopConnect{
    
}

- (void)testConnectMarkupElements
{
    NSMutableArray* a0 = [NSMutableArray arrayWithObjects:
                          [MarkupText textWithText:@"abc"
                                              font:[UIFont systemFontOfSize:10]
                                             color:[UIColor redColor]],
                          [MarkupText textWithText:@"def"
                                              font:[UIFont systemFontOfSize:20]
                                             color:[UIColor blueColor]], nil];
    NSMutableArray* a1 = [NSMutableArray arrayWithObjects:
                          [MarkupText textWithText:@"ghi"
                                              font:[UIFont systemFontOfSize:20]
                                             color:[UIColor blueColor]],
                          [MarkupText textWithText:@"jkl"
                                              font:[UIFont systemFontOfSize:30]
                                             color:[UIColor whiteColor]], nil];
    NSMutableArray* a2 = [NSMutableArray arrayWithObjects:
                          [MarkupText textWithText:@"mno"
                                              font:[UIFont systemFontOfSize:20]
                                             color:[UIColor greenColor]],
                          [MarkupText textWithText:@"pqr"
                                              font:[UIFont systemFontOfSize:30]
                                             color:[UIColor whiteColor]], nil];
    NSMutableArray* a3 = [NSMutableArray arrayWithObjects:
                          [MarkupNewLine newLineWithFont:[UIFont systemFontOfSize:20]],
                          [MarkupNewLine newLineWithFont:[UIFont systemFontOfSize:20]], nil];
    {
        //ひっつくパターン text
        NSArray* r0 = [MarkupDocument connectMarkupElements:a0 andOthers:a1];
        STAssertEquals([r0 count], 3u, @"");
        id<MarkupElement> c = [r0 objectAtIndex:1];
        STAssertEqualObjects(c.font, [UIFont systemFontOfSize:20], @"");
        STAssertEqualObjects(c.color, [UIColor blueColor], @"");
        STAssertEqualObjects(c.stringValue, @"defghi", @"");
    }
    {
        //ひっつかないパターン text
        NSArray* r = [MarkupDocument connectMarkupElements:a0 andOthers:a2];
        STAssertEquals([r count], 4u, @"");
    }
    {
        //ひっつかないパターン text + newline
        NSArray* r = [MarkupDocument connectMarkupElements:a0 andOthers:a3];
        STAssertEquals([r count], 4u, @"");
    }
    {
        //ひっつかないパターン newline + text
        NSArray* r = [MarkupDocument connectMarkupElements:a3 andOthers:a0];
        STAssertEquals([r count], 4u, @"");
    }
    {
        //前が空配列
        NSArray* r = [MarkupDocument connectMarkupElements:[NSArray array] andOthers:a0];
        STAssertEquals([r count], 2u, @"");
    }
    {
        //後ろが空配列
        NSArray* r = [MarkupDocument connectMarkupElements:a0 andOthers:[NSArray array]];
        STAssertEquals([r count], 2u, @"");
    }
}

@end
