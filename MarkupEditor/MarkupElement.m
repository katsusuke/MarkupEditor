//
//  MarkupElement.m
//  CustomTextInputText
//
//  Created by shimizu on 11/02/23.
//  Copyright 2011 MK System. All rights reserved.
//

#import "MarkupElement.h"
#import "MarkupView.h"
#import "MarkupViewCache.h"

@implementation MarkupNewLine

@synthesize font=font_;

- (id)initWithFont:(UIFont*)font;{
	self = [super init];
	if(self){
		font_ = [font retain];
	}
	return self;
}

+ (id)markupNewLineWithFont:(UIFont*)font{
    return [[[self alloc]initWithFont:font] autorelease];
}
- (id)copyWithZone:(NSZone *)zone{
    return [[[self class]allocWithZone:zone]initWithFont:font_];
}

- (void)dealloc{
	[markupView_ release];
	[font_ release];
	[super dealloc];
}

- (NSString*)description{
    return [NSString stringWithFormat:@"%@(font:%@ markupView:0x%08d)",
            [super description],
            font_,
            markupView_];
}

- (CGSize)size{
	return CGSizeZero;
}

- (void)layoutWithViewCache:(MarkupViewCache*)viewCache
            previousElement:(id<MarkupElement>)previous
              documentWidth:(CGFloat)documentWidth
                     isLast:(BOOL)isLast{
	NSInteger lineNumber = 0;
	NSInteger order = 0;
	CGFloat lineTop = 0;
	CGRect lineViewFrame = CGRectZero;
	lineViewFrame.size.height = [font_ lineHeight];
	if(previous){
		MarkupView* pl = previous.lastView;
        if([previous isMemberOfClass:[MarkupNewLine class]]){
            order = 0;
            lineViewFrame.origin.x = 0;
            lineViewFrame.origin.y = pl.lineBottom;
            lineTop = pl.lineBottom;
            lineNumber = pl.lineNumber + 1;
        }
        else{
            lineNumber = pl.lineNumber;
            order = pl.order + 1;
            lineViewFrame.origin.x = pl.frame.origin.x + pl.frame.size.width;
            lineViewFrame.origin.y = pl.lineTop;
            lineTop = pl.lineTop;
        }
	}
	[markupView_ release];
	markupView_ = [[MarkupView alloc]initWithMarkupElement:self
											lineNumber:lineNumber
												 order:order
											   lineTop:lineTop
												 frame:lineViewFrame];
	[viewCache addViewCache:markupView_];
	
	CGFloat lineHeight = [viewCache lineHeightWithLineNumber:lineNumber];
	[viewCache setLineViewOriginYWithNumber:lineNumber
							 withLineHeight:lineHeight];
}
- (MarkupView*)lastView{
	return markupView_;
}
- (void)drawRect:(CGRect)rect{
	//Do nothing
#ifdef DEBUG
	[@"↓" drawAtPoint:markupView_.frame.origin
			 withFont:font_];
#endif
}
- (NSInteger)length{
	return 1;
}
- (NSString*)stringValue{
    return [NSString stringWithString:@"\n"];
}
- (NSString*)stringFrom:(NSInteger)start to:(NSInteger)end{
	if(start == 0 && 1 == end){
		return [NSString stringWithString:@"\n"];
	}
	return [NSString string];
}
- (Pair*)splitAtIndex:(NSInteger)index{
    ASSERT(index == 0 || index == 1, @"");
    if(index == 0){
        return [Pair pairWithFirst:nil second:self];
    }else{//index == 1
        return [Pair pairWithFirst:self second:nil];
    }
}
- (BOOL)isConnectableTo:(id<MarkupElement>)lhs{
    return NO;
}
- (id<MarkupElement>)connectBack:(id<MarkupElement>)rhs{
    return nil;
}
- (CGRect)createRectForValueIndex:(NSInteger)valueIndex{
    ASSERT(valueIndex == 0 || valueIndex == 1, @"");
    if(valueIndex == 0){
        return markupView_.frame;
    }else{
        return CGRectMake(0, markupView_.lineBottom, 0, markupView_.frame.size.height);
    }
}
- (NSInteger)valueIndexFromPoint:(CGPoint)point
                  nextMarkupView:(MarkupView*)next{
    if(markupView_.lineTop <= point.y && point.y < markupView_.lineBottom &&
       markupView_.frame.origin.x <= point.x){
        return 0;
    }
    return -1;
}
- (MarkupView*)firstMarkupView{
    return markupView_;
}


@end

@implementation MarkupText

@synthesize text=text_;
@synthesize marked=marked_;

- (id)initWithText:(NSString*)text
              font:(UIFont*)font
             color:(UIColor*)color
            marked:(BOOL)marked{
	self = [super init];
	if (self != nil) {
		text_ = [text copy];
		font_ = [font retain];
		color_ = [color retain];
		textList_ = [[NSMutableArray alloc]init];
		markupViews_ = [[NSMutableArray alloc]init];
        marked_ = marked;
	}
	return self;
}

+ (MarkupText*)textWithText:(NSString*)text
                       font:(UIFont*)font
                      color:(UIColor*)color
                     marked:(BOOL)marked{
	return [[[MarkupText alloc]initWithText:text
                                       font:font
                                      color:color
                                     marked:marked]autorelease];
}
+ (MarkupText*)textWithText:(NSString *)text font:(UIFont *)font color:(UIColor *)color{
    return [MarkupText textWithText:text font:font color:color marked:NO];
}

- (void)dealloc{
	[text_ release];
	[font_ release];
	[color_ release];
	[textList_ release];
	[markupViews_ release];
	[super dealloc];
}

- (NSString*)description{
    return [NSString stringWithFormat:
            @"%@(text:%@\n"
            @"font:%@\n"
            @"color:%@\n"
            @"textList:%@\n"
            @"markupViews:%@",
            [super description],
            text_,
            font_,
            color_,
            textList_,
            markupViews_];
}

- (void)layoutWithViewCache:(MarkupViewCache*)viewCache
            previousElement:(id<MarkupElement>)previous
              documentWidth:(CGFloat)documentWidth
                     isLast:(BOOL)isLast{
	NSInteger lineNumber = 0;
	NSInteger order = 0;
	CGFloat lineTop = 0;
	CGRect lineViewFrame = CGRectZero;
	
	CGFloat width = documentWidth;
	if(previous){
		MarkupView* pl = previous.lastView;
		if([previous isMemberOfClass:[MarkupNewLine class]]){//改行
			lineViewFrame.origin.x = 0;
			lineViewFrame.origin.y = pl.lineBottom;
			lineTop = pl.lineBottom;
			lineNumber = pl.lineNumber + 1;
            order = 0;
		}
		else{
			lineViewFrame.origin.x = pl.frame.origin.x + pl.frame.size.width;
			lineViewFrame.origin.y = pl.lineTop;
			lineTop = pl.lineTop;
			lineNumber = pl.lineNumber;
            order = pl.order + 1;
			width -= lineViewFrame.origin.x;
		}
	}
	[textList_ removeAllObjects];
	[markupViews_ removeAllObjects];
	NSString* text = text_;
	while (YES)
	{
		CGSize textSize = [text sizeWithFont:font_];
		if(textSize.width < width){
			//一行に入り切る
			[textList_ addObject:text];
			lineViewFrame.size = textSize;
			MarkupView* newLineView
			= [[MarkupView alloc]initWithMarkupElement:self
										  lineNumber:lineNumber
											   order:order
											 lineTop:lineTop
											   frame:lineViewFrame];
			[viewCache addViewCache:newLineView];
			[markupViews_ addObject:newLineView];
			[newLineView release];
			
			if(isLast){
				
				CGFloat lineHeight = [viewCache lineHeightWithLineNumber:lineNumber];
				[viewCache setLineViewOriginYWithNumber:lineNumber
										 withLineHeight:lineHeight];
			}
			
			return;
		}else{
			//入りきらない
			NSString* currentLineString
			= [text substringWithFont:font_
							 forWidth:width];
			[textList_ addObject:currentLineString];
			textSize = [currentLineString sizeWithFont:font_];
			lineViewFrame.size = textSize;
			MarkupView* newLineView
			= [[MarkupView alloc]initWithMarkupElement:self
										  lineNumber:lineNumber
											   order:order
											 lineTop:lineTop
											   frame:lineViewFrame];
			
			[viewCache addViewCache:newLineView];
			[markupViews_ addObject:newLineView];
			[newLineView release];
			
			CGFloat lineHeight = [viewCache lineHeightWithLineNumber:lineNumber];
			[viewCache setLineViewOriginYWithNumber:lineNumber
									 withLineHeight:lineHeight];
			text = [text substringFromIndex:[currentLineString length]];
			lineNumber++;
			order = 0;
			lineTop += lineHeight;
			lineViewFrame.origin.x = 0;
			lineViewFrame.origin.y += lineHeight;
			lineViewFrame.size = CGSizeZero;
			width = documentWidth;
		}
	}
}

- (MarkupView*)lastView{
	return [markupViews_ lastObject];
}

- (void)drawRect:(CGRect)rect{
	[color_ set];
	for(NSInteger i = 0; i < [textList_ count]; ++i)
	{
		MarkupView* lineView = [markupViews_ objectAtIndex:i];
		if(CGRectIntersectsRect(lineView.frame, rect)){
            if(marked_){
                [[UIColor colorWithRed:0.57255 green:0.517648 blue:1 alpha:1]set];
                CGContextRef context = UIGraphicsGetCurrentContext();
                CGContextFillRect(context, lineView.frame);
                [color_ set];
            }
			NSString* text = [textList_ objectAtIndex:i];
			[text drawAtPoint:lineView.frame.origin withFont:font_];
#ifdef DEBUG
			CGContextRef currentContext = UIGraphicsGetCurrentContext();
			CGContextStrokeRect(currentContext, lineView.frame);
#endif
		}
	}
}

- (NSInteger)length{
	return [text_ length];
}

- (NSString*)stringValue{
    return text_;
}
- (NSString*)stringFrom:(NSInteger)start to:(NSInteger)end{
    start = MAX(start, 0);
    end = MIN(end, [text_ length]);
    NSInteger length = end - start;
    ASSERT(0 <= length, @"length must be plus");
    if(length == 0){
        return [NSString string];
    }else{
        return [text_ substringWithRange:NSMakeRange(start, length)];
    }
}

- (Pair*)splitAtIndex:(NSInteger)index{
    Pair* res = [Pair pair];
    if(index <= 0){
        MarkupText* cp = [self copy];
        res.second = cp;
        [cp release];
    }
    else{
        if(index <= [text_ length]){
            res.first = [MarkupText textWithText:[text_ substringToIndex:index]
                                            font:font_
                                           color:color_
                                          marked:marked_];
        }
        if(index < [text_ length]){
            res.second = [MarkupText textWithText:[text_ substringFromIndex:index]
                                             font:font_
                                            color:color_
                                           marked:marked_];
        }
    }
    return res;
}

- (id)copyWithZone:(NSZone *)zone{
	return [[[self class]allocWithZone:zone]initWithText:text_
                                                    font:font_
                                                   color:color_
                                                  marked:marked_];
}

- (BOOL)isConnectableTo:(id<MarkupElement>)lhs{
    if([lhs isMemberOfClass:[self class]]){
        MarkupText* markupText = (MarkupText*)lhs;
        if([font_ isEqual:markupText.font] &&
           [color_ isEqual:markupText.color] &&
           marked_ == markupText.marked){
            return YES;
        }
    }
    return NO;
}

- (id<MarkupElement>)connectBack:(id<MarkupElement>)rhs{
    if(![self isConnectableTo:rhs])return nil;
    MarkupText* text = (MarkupText*)rhs;
    return [MarkupText textWithText:[text_ stringByAppendingString:text.text]
                                     font:font_
                                    color:color_
                             marked:marked_];
}

- (UIFont*)font{
    return font_;
}
- (UIColor*)color{
    return color_;
}

- (CGRect)createRectForValueIndex:(NSInteger)valueIndex{
    NSInteger i = 0;
    NSInteger index = 0;
    for(NSString* text in textList_)
    {
        if(index <= valueIndex && valueIndex < index + [text length])
        {
            MarkupView* view = [markupViews_ objectAtIndex:i];
            NSString* substr = [text substringToIndex:valueIndex - index];
            CGFloat width = [substr widthWithFont:font_];
            return CGRectMake(view.frame.origin.x + width,
                              view.frame.origin.y,
                              0,
                              view.frame.size.height);
        }
        index += [text length];
        i++;
    }
    MarkupView* view = [markupViews_ lastObject];
    return CGRectMake(view.frame.origin.x + view.frame.size.width,
                      view.frame.origin.y,
                      0,
                      view.frame.size.height);
}

- (NSInteger)valueIndexFromPoint:(CGPoint)point
                  nextMarkupView:(MarkupView*)next
{
    NSInteger valueIndex = 0;
    for(NSInteger i = 0; i < [markupViews_ count]; ++i)
    {
        MarkupView* mv = [markupViews_ objectAtIndex:i];
        NSString* str = [textList_ objectAtIndex:i];
        if(mv == [markupViews_ lastObject] &&
           next != nil &&
           next.lineTop == mv.lineTop){
            if(mv.lineTop <= point.y && point.y < mv.lineBottom &&
               mv.frame.origin.x <= point.x && point.x <= CGRectGetMaxX(mv.frame)){
                CGFloat previous = 0;
                NSInteger j;
                for(j = 1; j < [str length] + 1; ++j){
                    NSString* substr = [str substringToIndex:j];
                    CGFloat width = [substr widthWithFont:font_];
                    if(point.x < mv.frame.origin.x + (width + previous) / 2){
                        return valueIndex + j - 1;
                    }
                    previous = width;
                }
                //ASSERT(valueIndex + j == [self length], @"");
                return valueIndex + j - 1;
            }
        }else if(mv.lineTop <= point.y && point.y < mv.lineBottom &&
                 mv.frame.origin.x <= point.x){
            CGFloat previous = 0;
            NSInteger j;
            for(j = 1; j < [str length] + 1; ++j){
                NSString* substr = [str substringToIndex:j];
                CGFloat width = [substr widthWithFont:font_];
                if(point.x < mv.frame.origin.x + (previous + width) / 2){
                    return valueIndex + j - 1;
                }
                previous = width;
            }
            return valueIndex + j - 1;
        }else{
            valueIndex += [str length];
        }
    }
    return -1;
}

- (MarkupView*)firstMarkupView{
    return [markupViews_ objectAtIndex:0];
}
@end

@implementation MarkupHandWritingChar

- (void)createBitmap
{
    CGFloat left = CGFLOAT_MAX;;
    CGFloat right = 0;
    for(NSValue* value in points_){
        CGPoint point = [value CGPointValue];
        left = MIN(left, point.x);
        right = MAX(right, point.x);
    }
    CGFloat width = right - left;
    CGFloat marginLeft = size_.height * 0.1;
    size_.width = width * size_.height + marginLeft * 2;
    bitmap_ = BitmapContextCreate(size_);
    //CGContextSetFillColorWithColor(bitmap_->context, [[UIColor clearColor]CGColor]);
    CGContextSetRGBFillColor(bitmap_->context, 1, 1, 1, 0);
    CGContextFillRect(bitmap_->context, CGRectMake(0, 0, size_.width, size_.height));
    CGContextSetStrokeColorWithColor(bitmap_->context, [color_ CGColor]);
    CGContextSetLineWidth(bitmap_->context, 1);
    CGContextSetLineCap(bitmap_->context, kCGLineCapRound);
    
    for (NSInteger i = 0; i < [points_ count]; i += 2) {
        NSValue* v0 = [points_ objectAtIndex:i];
        NSValue* v1 = [points_ objectAtIndex:i + 1];
        CGPoint p = [v0 CGPointValue];
        CGPoint q = [v1 CGPointValue];
        CGContextBeginPath(bitmap_->context);
        CGContextMoveToPoint(bitmap_->context,
                             marginLeft + (p.x - left) * size_.height,
                             p.y * size_.height);
        CGContextAddLineToPoint(bitmap_->context,
                                marginLeft + (q.x - left) * size_.height,
                                q.y * size_.height);
        CGContextStrokePath(bitmap_->context);
    }
}

- (id)initWithPoints:(NSArray*)points
                font:(UIFont *)font
               color:(UIColor *)color{
    self = [super init];
    if(self)
    {
        points_ = [[NSArray alloc]initWithArray:points];
        font_ = [font retain];
        color_ = [color retain];
        size_.height = [font lineHeight];
        [self createBitmap];
    }
    return self;
}

+ (id)charWithPoints:(NSArray*)points
                font:(UIFont*)font
               color:(UIColor *)color{
    return [[[self alloc]initWithPoints:points font:font color:color]autorelease];
}
- (id)copyWithZone:(NSZone *)zone{
    return [[[self class]allocWithZone:zone]initWithPoints:points_ font:font_ color:color_];
}
- (void)dealloc{
    [points_ release];
    [font_ release];
    [super dealloc];
}
- (CGSize)size{
    return size_;
}
- (void)layoutWithViewCache:(MarkupViewCache *)viewCache
            previousElement:(id<MarkupElement>)previous
              documentWidth:(CGFloat)documentWidth
                     isLast:(BOOL)isLast{
    [markupView_ release];
    markupView_ = nil;
    NSInteger lineNumber = 0;
    NSInteger order = 0;
    CGFloat lineTop = 0;
    CGRect lineViewFrame = CGRectZero;
    lineViewFrame.size = size_;

    if(previous){
        MarkupView* pl = previous.lastView;
        if([previous isMemberOfClass:[MarkupNewLine class]] ||//前が改行
           documentWidth < CGRectGetMaxX(pl.frame) + size_.width)//現在の行に入りきらない
        {
            CGFloat lineHeight = [viewCache lineHeightWithLineNumber:pl.lineNumber];
            [viewCache setLineViewOriginYWithNumber:pl.lineNumber
                                     withLineHeight:lineHeight];
            pl = previous.lastView;
            
            lineViewFrame.origin.x = 0;
            lineViewFrame.origin.y = pl.lineBottom;
            lineTop = pl.lineBottom;
            lineNumber = pl.lineNumber + 1;
            order = 0;
        }
        else{
            //現在の行に入り切る
            lineViewFrame.origin.x = CGRectGetMaxX(pl.frame);
            lineViewFrame.origin.y = pl.lineTop;
            lineTop = pl.lineTop;
            lineNumber = pl.lineNumber;
            order = pl.order + 1;
        }
    }
    markupView_ = [[MarkupView alloc]initWithMarkupElement:self
                                                lineNumber:lineNumber
                                                     order:order
                                                   lineTop:lineTop
                                                     frame:lineViewFrame];
    [viewCache addViewCache:markupView_];

    if(isLast){
        CGFloat lineHeight = [viewCache lineHeightWithLineNumber:lineNumber];
        [viewCache setLineViewOriginYWithNumber:lineNumber
                                 withLineHeight:lineHeight];
    }
}
- (MarkupView*)lastView{
    return markupView_;
}
- (void)drawRect:(CGRect)rect
{
    CGRect frame = markupView_.frame;
    CGImageRef image = CGBitmapContextCreateImage(bitmap_->context);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextDrawImage(currentContext, frame, image);
    CGImageRelease(image);
}
- (NSInteger)length{
    return 1;
}
- (NSString*)stringValue{
    return [NSString stringWithString:@" "];
}
- (NSString*)stringFrom:(NSInteger)start to:(NSInteger)end
{
    if(start == 0 && end == 1){
        return [self stringValue];
    }else{
        return [NSString string];
    }
}

- (Pair*)splitAtIndex:(NSInteger)index{
    ASSERT(index == 0 || index == 1, @"");
    if(index == 0){
        return [Pair pairWithFirst:nil second:self];
    }else{
        return [Pair pairWithFirst:self second:nil];
    }
}
- (BOOL)isConnectableTo:(id<MarkupElement>)lhs{
    return NO;
}
- (id<MarkupElement>)connectBack:(id<MarkupElement>)rhs
{
    return nil;
}
- (CGRect)createRectForValueIndex:(NSInteger)valueIndex
{
    ASSERT(valueIndex == 0 || valueIndex == 1, @"");
    if(valueIndex == 0){
        return CGRectMake(markupView_.frame.origin.x,
                          markupView_.frame.origin.y,
                          0, markupView_.frame.size.height);
    }else{
        return CGRectMake(CGRectGetMaxX(markupView_.frame),
                          markupView_.frame.origin.y,
                          0, markupView_.frame.size.height);
    }
}
- (UIFont*)font{
    return font_;
}
- (UIColor*)color{
    return color_;
}
- (NSInteger)valueIndexFromPoint:(CGPoint)point
                  nextMarkupView:(MarkupView*)next{
    if(markupView_.lineTop <= point.y && point.y < markupView_.lineBottom){
        if(markupView_.frame.origin.x <= point.x &&
           point.x < markupView_.frame.origin.x + markupView_.frame.size.width / 2)
        {
            return 0;
        }
        else{
            if(next != nil &&
               next.lineTop == markupView_.lineTop){
                if(markupView_.frame.origin.x + markupView_.frame.size.width / 2 <=
                   point.x &&
                   point.x < CGRectGetMaxX(markupView_.frame)){
                    return 1;
                }
            }else{
                if(markupView_.frame.origin.x + markupView_.frame.size.width / 2 <=
                   point.x){
                    return 1;
                }
            }
        }
    }
    return -1;
}

- (MarkupView*)firstMarkupView{
    return markupView_;
}

@end
