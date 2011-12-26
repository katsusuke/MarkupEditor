//
//  UIView+renderInPDFFile.m
//  MarkupEditor
//
//  Created by  on 11/12/26.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "UIView+PDFWritingAdditions.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView(PDFWritingAdditions)

- (void)renderInPDFFile:(NSString*)path
{
    CGRect mediaBox = self.bounds;
    CGContextRef ctx = CGPDFContextCreateWithURL((CFURLRef)[NSURL fileURLWithPath:path], &mediaBox, NULL);
    
    CGPDFContextBeginPage(ctx, NULL);
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -mediaBox.size.height);
    [self.layer renderInContext:ctx];
    CGPDFContextEndPage(ctx);
    CFRelease(ctx);
}

@end
