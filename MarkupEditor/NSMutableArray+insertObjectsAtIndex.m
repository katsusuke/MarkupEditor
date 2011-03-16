//
//  NSMutableArray+insertObjectsAtIndex.m
//  CustomTextInputText
//
//  Created by shimizu on 11/03/08.
//  Copyright 2011 MK System. All rights reserved.
//

#import "NSMutableArray+insertObjectsAtIndex.h"


@implementation NSMutableArray(insertObjectsAtIndex)

- (void)insertObjects:(NSArray *)objects atIndex:(NSInteger)index
{
	for(id anObject in objects)
	{
		[self insertObject:anObject atIndex:index++];
	}
}

@end
