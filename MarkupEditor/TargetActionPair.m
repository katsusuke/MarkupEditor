//
//  TargetActionPair.m
//  ProjectTemplate
//
//  Created by shimizu on 09/12/24.
//  Copyright 2009 MK System. All rights reserved.
//

#import "TargetActionPair.h"

@implementation TargetActionPair
@synthesize target;
@synthesize action;


-(id)initWithTarget:(id)object action:(SEL)selector {
	if(!(self = [super init]))return nil;
	target = object;
	action = selector;
	return self;
}
/*
-(void)fire {
	[target performSelector:action];
}
 */
-(void)fire:(id)sender {
	[target performSelector:action withObject:sender];
}


@end
