//
//  TargetActionPair.h
//  ProjectTemplate
//
//  Created by shimizu on 09/12/24.
//  Copyright 2009 MK System. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TargetActionPair : NSObject {
	id target;
	SEL action;
}
@property (assign) id target;
@property (assign) SEL action;

-(id)initWithTarget:(id)object action:(SEL)selector;
//-(void)fire;
-(void)fire:(id)sender;

@end
