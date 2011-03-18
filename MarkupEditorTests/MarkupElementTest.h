//
//  MarkupElementTest.h
//  MarkupEditor
//
//  Created by shimizu on 11/03/17.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
//  See Also: http://developer.apple.com/iphone/library/documentation/Xcode/Conceptual/iphone_development/135-Unit_Testing_Applications/unit_testing_applications.html

//  Application unit tests contain unit test code that must be injected into an application to run correctly.
//  Define USE_APPLICATION_UNIT_TEST to 0 if the unit test code is designed to be linked into an independent test executable.

#import <SenTestingKit/SenTestingKit.h>
#import <UIKit/UIKit.h>
#import "MarkupElement.h"


@interface MarkupElementTest : SenTestCase {
    MarkupNewLine* nl0;
    MarkupNewLine* nl1;
    MarkupText* tx0;
    MarkupText* tx1;
    MarkupText* tx2;
}

@end
