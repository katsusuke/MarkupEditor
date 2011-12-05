//
//  CACommon.m
//  PinTest
//
//  Created by shimizu on 09/11/20.
//  Copyright 2009 MK System. All rights reserved.
//

#import "CACommon.h"
#import <QuartzCore/QuartzCore.h>

CALayer* LayerNamed(NSString* name)
{
	CALayer* layer = [CALayer layer];
	UIImage* image = [UIImage imageNamed:name];
	layer.contents = (id)image.CGImage;
	//layer.edgeAntialiasingMask = 0;
	
	CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
	layer.frame = rect;
	return layer;
}

BitmapContextRef BitmapContextCreate(CGSize size)
{
	int bitmapBytesPerRow = ((int)size.width * 4);
	int bitmapByteCount = (bitmapBytesPerRow * (int)size.height);
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	void* bitmapData = malloc(bitmapByteCount);
	
	if(bitmapData == NULL)
	{
		LOG(@"Memory not allocated!");
		CGColorSpaceRelease(colorSpace);
		return NULL;
	}

	CGContextRef context
	= CGBitmapContextCreate(bitmapData,
							(int)size.width,
							(int)size.height,
							8,
							bitmapBytesPerRow,
							colorSpace,
							kCGImageAlphaPremultipliedLast);
	if(context == NULL) {
		CGColorSpaceRelease(colorSpace);
		free(bitmapData);
		fprintf(stderr, "Context not created!");
		return NULL;
	}
	CGColorSpaceRelease(colorSpace);
	
	BitmapContextRef bitmap = malloc(sizeof(BitmapContext));
	bitmap->context = context;
	bitmap->data = bitmapData;
	return bitmap;
}

void BitmapContextRelease(BitmapContextRef context)
{
	CGContextRelease(context->context);
	free(context->data);
	free(context);
}

