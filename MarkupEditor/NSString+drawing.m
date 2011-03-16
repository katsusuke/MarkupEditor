//
//  NSString+drawing.m
//  FontDrawTest
//
//  Created by shimizu on 11/03/01.
//  Copyright 2011 MK System. All rights reserved.
//

#import "NSString+drawing.h"


@implementation NSString(drawing)

- (CGFloat)lineHeightWithFont:(UIFont*)font
{
	return [self sizeWithFont:font].height;
}

- (CGFloat)widthWithFont:(UIFont*)font
{
	return [self sizeWithFont:font].width;
}

- (NSString*)substringWithFont:(UIFont*)font
					  forWidth:(CGFloat)width
{
	NSRange firstLine = [self lineRangeForRange:NSMakeRange(0, 0)];
	for(NSInteger i = 0; i < firstLine.length; ++i)
	{
		NSString* substr = [self substringToIndex:firstLine.length - i];
		if([substr widthWithFont:font] <= width){
			return substr;
		}
	}
	return [NSString string];
}

@end
