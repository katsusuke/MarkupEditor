//
//  HandWritingView.h
//  MarkupEditor
//
//  Created by shimizu on 11/03/22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CACommon.h"
#import "TargetActionPair.h"

@interface HandWritingView : UIView {
    BitmapContext* bitmap_;
    TargetActionPair* targetAction_;
    NSMutableArray* points_;
}

- (void)addTarget:(id)target action:(SEL)action;

- (void)clear;
- (BOOL)hasPoints;
- (NSArray*)points;

@end
