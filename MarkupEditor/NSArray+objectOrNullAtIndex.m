//
//  NSArray+objectOrNullAtIndex.m
//  CustomTextInputText
//
//  Created by shimizu on 11/03/01.
//  Copyright 2011 MK System. All rights reserved.
//

#import "NSArray+objectOrNullAtIndex.h"


@implementation NSArray(objectOrNullAtIndex)

- (id)objectOrNullAtIndex:(NSInteger)index
{
	if([self count] <= index)return NULL;
	if(index < 0)return NULL;
	return [self objectAtIndex:index];
}
@end
