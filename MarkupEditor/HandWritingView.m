//
//  HandWritingView.m
//  MarkupEditor
//
//  Created by shimizu on 11/03/22.
//  Copyright 2011 MK System. All rights reserved.
//

#import "HandWritingView.h"
#import "CACommon.h"

@implementation HandWritingView

- (BOOL)createBitmapWithSize:(CGSize)size
{
    BitmapContextRelease(bitmap_);
    bitmap_ = nil;
    if(0 < size.width && 0 < size.height){
        bitmap_ = BitmapContextCreate(CGSizeMake(size.width,
                                                 size.height));
        CGContextSetRGBFillColor(bitmap_->context, 1, 1, 1, 1);
        CGContextFillRect(bitmap_->context, CGRectMake(0, 0, size.width, size.height));
        CGContextSetRGBStrokeColor(bitmap_->context, 0, 0, 0, 1);
        CGContextSetLineWidth(bitmap_->context, 2);
    }
    return YES;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor grayColor];
        points_ = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)dealloc
{
    BitmapContextRelease(bitmap_);
    [targetAction_ release];
    [points_ release];
    [super dealloc];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self createBitmapWithSize:self.frame.size];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    if(bitmap_){
        CGImageRef image = CGBitmapContextCreateImage(bitmap_->context);
        CGContextRef currentContext = UIGraphicsGetCurrentContext();
        CGContextDrawImage(currentContext, rect, image);
        CGImageRelease(image);
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint p = [[touches anyObject]locationInView:self];
    CGPoint q = [[touches anyObject]previousLocationInView:self];

    [points_ addObject:[NSValue valueWithCGPoint:p]];
    [points_ addObject:[NSValue valueWithCGPoint:q]];
    P(@"%d", [points_ count]);
    
    CGContextSetLineCap(bitmap_->context, kCGLineCapRound);
    CGContextBeginPath(bitmap_->context);
    CGContextMoveToPoint(bitmap_->context, q.x, q.y);
    CGContextAddLineToPoint(bitmap_->context, p.x, p.y);
    CGContextStrokePath(bitmap_->context);
    [self setNeedsDisplay];
    if(targetAction_){
        [targetAction_ fire:self];
    }
}

- (void)addTarget:(id)target action:(SEL)action
{
    if(targetAction_){
        [targetAction_ release];
    }
    targetAction_ = [[TargetActionPair alloc]initWithTarget:target action:action];
}

- (void)clear{
    [self createBitmapWithSize:self.bounds.size];
    [points_ removeAllObjects];
    [self setNeedsDisplay];
}
- (BOOL)hasPoints{
    return [points_ count] != 0;
}
- (NSArray*)points{
    NSMutableArray* res = [NSMutableArray arrayWithCapacity:[points_ count]];
    CGFloat height = self.frame.size.height;
    for(NSValue* value in points_){
        CGPoint p = [value CGPointValue];
        CGPoint q = CGPointMake(p.x / height, p.y / height);
        [res addObject:[NSValue valueWithCGPoint:q]];
    }
    return res;
}

@end
