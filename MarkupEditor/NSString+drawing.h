//
//  NSString+drawing.h
//  FontDrawTest
//
//  Created by shimizu on 11/03/01.
//  Copyright 2011 MK System. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString(drawing)

- (CGFloat)lineHeightWithFont:(UIFont*)font;
- (CGFloat)widthWithFont:(UIFont*)font;
- (NSString*)substringWithFont:(UIFont*)font
					  forWidth:(CGFloat)width;

@end
