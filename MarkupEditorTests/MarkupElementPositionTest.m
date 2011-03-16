//
//  MarkupElementPositionTest.m
//  MarkupEditor
//
//  Created by shimizu on 11/03/16.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MarkupElementPositionTest.h"


@implementation MarkupElementPositionTest

#if USE_APPLICATION_UNIT_TEST     // all code under test is in the iPhone Application

- (void)testAppDelegate {
    
    id yourApplicationDelegate = [[UIApplication sharedApplication] delegate];
    STAssertNotNil(yourApplicationDelegate, @"UIApplication failed to find the AppDelegate");
    STFail(@"fail");
}

#else                           // all code under test must be linked into the Unit Test bundle

- (void)piyo{
    STFail(@"hoge");
}

- (void)testMath {
    
    STAssertTrue((1+1)==2, @"Compiler isn't feeling well today :-(" );
    STFail(@"fail");
}

- (void)hoge{
    STFail(@"hoge");
}

#endif

@end
