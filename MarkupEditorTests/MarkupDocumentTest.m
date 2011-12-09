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

- (void)testPositionFromPositionOffset
{
    MarkupElementPosition* p0 = d.startPosition;
    //同一element内
    MarkupElementPosition* p1 = [d positionFromPosition:p0 offset:2];
    MarkupElementPosition* p1eq = [MarkupElementPosition positionWithElementIndex:0 valueIndex:2];
    STAssertEqualObjects(p1, p1eq, @"");
    //element 境界越え
    MarkupElementPosition* p2 = [d positionFromPosition:p1eq offset:3];
    MarkupElementPosition* p2eq = [MarkupElementPosition positionWithElementIndex:1 valueIndex:1];
    STAssertEqualObjects(p2, p2eq, @"");
    //NewLine 境界越え
    MarkupElementPosition* p3 = [d positionFromPosition:p2eq offset:2 + 3 + 13 + 1];
    MarkupElementPosition* p3eq = [MarkupElementPosition positionWithElementIndex:5 valueIndex:0];
    STAssertEqualObjects(p3, p3eq, @"");
    //endPosition 手前まで移動
    MarkupElementPosition* p4 = [d positionFromPosition:p3eq offset:13 + 1 + 4 + 3 + 2];
    MarkupElementPosition* p4eq = [MarkupElementPosition positionWithElementIndex:9 valueIndex:2];
    STAssertEqualObjects(p4, p4eq, @"");
    //終端
    MarkupElementPosition* p5 = [d positionFromPosition:p4eq offset:1];
    MarkupElementPosition* p5eq = [MarkupElementPosition positionWithElementIndex:10 valueIndex:0];
    STAssertEqualObjects(p5, p5eq, @"");
    //境界を超えても end
    MarkupElementPosition* p6 = [d positionFromPosition:p4 offset:2];
    STAssertEqualObjects(p6, d.endPosition, @"");
    
    //戻り
    //境界越え
    MarkupElementPosition* p7 = [d positionFromPosition:d.endPosition offset:-1];
    MarkupElementPosition* p7eq = [MarkupElementPosition positionWithElementIndex:9 valueIndex:2];
    STAssertEqualObjects(p7, p7eq, @"");
    //境界越えない
    MarkupElementPosition* p8 = [d positionFromPosition:p7 offset:-1];
    MarkupElementPosition* p8eq = [MarkupElementPosition positionWithElementIndex:9 valueIndex:1];
    STAssertEqualObjects(p8, p8eq, @"");
    //NewLine 超え
    MarkupElementPosition* p9 = [d positionFromPosition:p8 offset:-1 - 3 - 4 - 1];
    MarkupElementPosition* p9eq = [MarkupElementPosition positionWithElementIndex:6 valueIndex:0];
    STAssertEqualObjects(p9, p9eq, @"");
    //Start 手前
    MarkupElementPosition* p10 = [d positionFromPosition:p9 offset:-13 - 1 - 13 - 3 - 3 - 3];
    MarkupElementPosition* p10eq = [MarkupElementPosition positionWithElementIndex:0 valueIndex:1];
    STAssertEqualObjects(p10, p10eq, @"");
    //start
    MarkupElementPosition* p11 = [d positionFromPosition:p10 offset:-1];
    STAssertEqualObjects(p11, d.startPosition, @"");
    //start 超えてもstart
    MarkupElementPosition* p12 = [d positionFromPosition:p10 offset:-2];
    STAssertEqualObjects(p12, d.startPosition, @"");
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
    //先頭にひっつけると、フォントや色が変わる
    STAssertEqualObjects(d.defaultFont, [UIFont systemFontOfSize:90], @"");
    STAssertEqualObjects(d.defaultColor, [UIColor darkGrayColor], @"");
    STAssertEquals([d elementCount], 12, @"");
}
// 先頭にひっつくパターン
- (void)testInsertElementAtIndexTopConnect{
    STAssertEqualObjects(d.defaultFont, [UIFont systemFontOfSize:16], @"");
    STAssertEqualObjects(d.defaultColor, [UIColor redColor], @"");
    NSArray* a = [NSArray arrayWithObjects:
                  [MarkupNewLine newLineWithFont:[UIFont systemFontOfSize:10]],
                  [MarkupText textWithText:@"かきく"
                                      font:[UIFont systemFontOfSize:16]
                                     color:[UIColor redColor]], nil];
    [d insertElements:a atIndex:0];
    STAssertEqualObjects(d.defaultFont, [UIFont systemFontOfSize:10], @"");
    STAssertEqualObjects(d.defaultColor, [UIColor redColor], @"");
    STAssertEquals([d elementCount], 11, @"");
    id<MarkupElement> elm = [d elementAtIndex:1];
    STAssertEqualObjects(elm.stringValue, @"かきくabcd", @"");
}
//真ん中でひっつかない
- (void)testInsertElementAtCenter{
    STAssertEqualObjects(d.defaultFont, [UIFont systemFontOfSize:16], @"");
    STAssertEqualObjects(d.defaultColor, [UIColor redColor], @"");
    NSArray* a = [NSArray arrayWithObjects:
                  [MarkupText textWithText:@"さしす"
                                      font:[UIFont systemFontOfSize:10]
                                     color:[UIColor orangeColor]],
                  [MarkupNewLine newLineWithFont:[UIFont systemFontOfSize:10]], nil];
    [d insertElements:a atIndex:2];
    //default Fontは変わらない
    STAssertEqualObjects(d.defaultFont, [UIFont systemFontOfSize:16], @"");
    STAssertEqualObjects(d.defaultColor, [UIColor redColor], @"");
    STAssertEquals([d elementCount], 12, @"");
}
//真ん中で手前にひっつく
- (void)testInsertElementAtCenterConnectPrevious{
    NSArray* a = [NSArray arrayWithObjects:
                  [MarkupText textWithText:@"さしす"
                                      font:[UIFont systemFontOfSize:30]
                                     color:[UIColor blueColor]],
                  [MarkupText textWithText:@"たちつ"
                                      font:[UIFont systemFontOfSize:10]
                                     color:[UIColor orangeColor]], nil];
    [d insertElements:a atIndex:2];
    STAssertEquals([d elementCount], 11, @"");
    STAssertEqualObjects([d elementAtIndex:1].stringValue, @"EFGさしす", @"");
    STAssertEqualObjects([d elementAtIndex:2].stringValue, @"たちつ", @"");
}
//真ん中で次にひっつく
- (void)testInsertElementAtCenterConnectNext{
    NSArray* a = [NSArray arrayWithObjects:
                  [MarkupText textWithText:@"さしす"
                                      font:[UIFont systemFontOfSize:10]
                                     color:[UIColor orangeColor]],
                  [MarkupText textWithText:@"たちつ"
                                      font:[UIFont systemFontOfSize:20]
                                     color:[UIColor greenColor]], nil];
    [d insertElements:a atIndex:2];
    STAssertEquals([d elementCount], 11, @"");
    STAssertEqualObjects([d elementAtIndex:1].stringValue, @"EFG", @"");
    STAssertEqualObjects([d elementAtIndex:2].stringValue, @"さしす", @"");
    STAssertEqualObjects([d elementAtIndex:3].stringValue, @"たちつhij", @"");
}
//真ん中で両側にひっつく
- (void)testInsertElementAtCenterConnectBoth
{
    NSArray* a = [NSArray arrayWithObjects:
                  [MarkupText textWithText:@"さしす"
                                      font:[UIFont systemFontOfSize:30]
                                     color:[UIColor blueColor]],
                  [MarkupText textWithText:@"たちつ"
                                      font:[UIFont systemFontOfSize:20]
                                     color:[UIColor greenColor]], nil];
    [d insertElements:a atIndex:2];
    STAssertEquals([d elementCount], 10, @"");
    STAssertEqualObjects([d elementAtIndex:1].stringValue, @"EFGさしす", @"");
    STAssertEqualObjects([d elementAtIndex:2].stringValue, @"たちつhij", @"");
}
//後尾でひっつかない
- (void)testInsertElementAtBottom
{
    NSArray* a = [NSArray arrayWithObjects:
                  [MarkupText textWithText:@"さしす"
                                      font:[UIFont systemFontOfSize:10]
                                     color:[UIColor orangeColor]],
                  [MarkupText textWithText:@"たちつ"
                                      font:[UIFont systemFontOfSize:20]
                                     color:[UIColor greenColor]], nil];
    [d insertElements:a atIndex:10];
    STAssertEquals([d elementCount], 12, @"");
    STAssertEqualObjects([d elementAtIndex:10].stringValue, @"さしす", @"");
    STAssertEqualObjects([d elementAtIndex:11].stringValue, @"たちつ", @"");
}
//後尾でひっつく
- (void)testInsertElementAtBottomConnect
{
    NSArray* a = [NSArray arrayWithObjects:
                  [MarkupText textWithText:@"さしす"
                                      font:[UIFont systemFontOfSize:20]
                                     color:[UIColor greenColor]],
                  [MarkupText textWithText:@"たちつ"
                                      font:[UIFont systemFontOfSize:20]
                                     color:[UIColor greenColor]], nil];
    [d insertElements:a atIndex:10];
    STAssertEquals([d elementCount], 11, @"");
    STAssertEqualObjects([d elementAtIndex:9].stringValue, @"hijさしす", @"");
    STAssertEqualObjects([d elementAtIndex:10].stringValue, @"たちつ", @"");
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
