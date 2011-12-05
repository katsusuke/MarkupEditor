//
//  CACommon.h
//  PinTest
//
//  Created by shimizu on 09/11/20.
//  Copyright 2009 MK System. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef struct{
	CGContextRef context;
	void* data;
}
BitmapContext;

typedef BitmapContext* BitmapContextRef;

extern CALayer* LayerNamed(NSString* name);
extern BitmapContextRef BitmapContextCreate(CGSize size);
extern void BitmapContextRelease(BitmapContextRef context);
