//
//  MarkupElement.m
//  CustomTextInputText
//
//  Created by shimizu on 11/02/23.
//  Copyright 2011 MK System. All rights reserved.
//

#import "MarkupElement.h"
#import "MarkupDocument.h"
#import "MarkupView.h"

@implementation MarkupNewLine

@synthesize font=font_;

- (id)initWithFont:(UIFont*)font;
{
	self = [super init];
	if(self)
	{
		font_ = [font retain];
	}
	return self;
}

+ (MarkupNewLine*)newLineWithFont:(UIFont*)font{
    return [[[[self class]alloc]initWithFont:font]autorelease];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[[self class]alloc]initWithFont:font_];
}

- (void)dealloc
{
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
                     isLast:(BOOL)isLast;
{
	NSInteger lineNumber = 0;
	NSInteger order = 0;
	CGFloat lineTop = 0;
	CGRect lineViewFrame = CGRectZero;
	lineViewFrame.size.height = [font_ lineHeight];
	if(previous){
		MarkupView* pl = previous.lastView;
		lineNumber = pl.lineNumber;
		order = pl.order + 1;
		lineViewFrame.origin.x = pl.frame.origin.x + pl.frame.size.width;
		lineViewFrame.origin.y = pl.lineTop;
		lineTop = pl.lineTop;
	}
	[markupView_ release];
	markupView_ = [[MarkupView alloc]initWithMarkupElement:self
											lineNumber:lineNumber
												 order:order
											   lineTop:lineTop
												 frame:lineViewFrame];
	[viewCache addViewCache:markupView_];
	
	CGFloat lineHeight = [viewCache lineHeightWithNumber:lineNumber];
	[viewCache setLineViewOriginYWithNumber:lineNumber
							 withLineHeight:lineHeight];
}

- (MarkupView*)lastView
{
	return markupView_;
}

- (void)drawRect:(CGRect)rect
{
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
- (NSString*)stringFrom:(NSInteger)start to:(NSInteger)end
{
	if(start == 0 && 1 == end){
		return [NSString stringWithString:@"\n"];
	}
	return [NSString string];
}

- (Pare*)splitAtIndex:(NSInteger)index
{
    ASSERT(index == 0 || index == 1, @"");
    if(index == 0){
        return [Pare pareWithFirst:nil second:self];
    }else{//index == 1
        return [Pare pareWithFirst:self second:nil];
    }
}

- (BOOL)isConnectableTo:(id<MarkupElement>)lhs{
    return NO;
}

- (id<MarkupElement>)connectBack:(id<MarkupElement>)rhs
{
    return nil;
}

@end



@implementation MarkupText

@synthesize text=text_;

- (id)initWithText:(NSString*)text
              font:(UIFont*)font
             color:(UIColor*)color
{
	self = [super init];
	if (self != nil) {
		text_ = [text copy];
		font_ = [font retain];
		color_ = [color retain];
		textList_ = [[NSMutableArray alloc]init];
		markupViews_ = [[NSMutableArray alloc]init];
	}
	return self;
}

+ (MarkupText*)textWithText:(NSString*)text
                             font:(UIFont*)font
                            color:(UIColor*)color
{
	return [[[MarkupText alloc]initWithText:text
                                       font:font
                                      color:color]autorelease];
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
                     isLast:(BOOL)isLast;
{
	NSInteger lineNumber = 0;
	NSInteger order = 0;
	CGFloat lineTop = 0;
	CGRect lineViewFrame = CGRectZero;
	
	CGFloat width = documentWidth;
	if(previous){
		MarkupView* pl = previous.lastView;
		lineNumber = pl.lineNumber;
		order = pl.order + 1;
		if([previous isMemberOfClass:[MarkupNewLine class]]){//改行
			lineViewFrame.origin.x = 0;
			lineViewFrame.origin.y = pl.lineBottom;
			lineTop = pl.lineBottom;
			lineNumber = pl.lineNumber + 1;
		}
		else{
			lineViewFrame.origin.x = pl.frame.origin.x + pl.frame.size.width;
			lineViewFrame.origin.y = pl.lineTop;
			lineTop = pl.lineTop;
			lineNumber = pl.lineNumber;
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
				
				CGFloat lineHeight = [viewCache lineHeightWithNumber:lineNumber];
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
			
			CGFloat lineHeight = [viewCache lineHeightWithNumber:lineNumber];
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

- (void)drawRect:(CGRect)rect
{
	[color_ set];
	for(NSInteger i = 0; i < [textList_ count]; ++i)
	{
		MarkupView* lineView = [markupViews_ objectAtIndex:i];
		if(CGRectIntersectsRect(lineView.frame, rect)){
			NSString* text = [textList_ objectAtIndex:i];
			[text drawAtPoint:lineView.frame.origin withFont:font_];
			CGContextRef currentContext = UIGraphicsGetCurrentContext();
			CGContextStrokeRect(currentContext, lineView.frame);
		}
	}
}

- (NSInteger)length{
	return [text_ length];
}

- (NSString*)stringValue{
    return text_;
}
- (NSString*)stringFrom:(NSInteger)start to:(NSInteger)end
{
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

- (Pare*)splitAtIndex:(NSInteger)index
{
    MarkupText* first = nil;
    MarkupText* last = nil;
    if(0 < index){
        first = [MarkupText textWithText:[text_ substringToIndex:index]
                                          font:font_
                                         color:color_];
    }
    if(index < [text_ length] - 1){
        last = [MarkupText textWithText:[text_ substringFromIndex:index]
                                         font:font_
                                        color:color_];
    }
    if(first && last){
        return [Pare pareWithFirst:first second:last];
    }
    if(first){
        return [Pare pareWithFirst:first second:nil];
    }
    if(last){
        return [Pare pareWithFirst:nil second:last];
    }
    ASSERT(0, @"[text length] == 0");
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
	id clone = [[[self class]allocWithZone:zone]initWithText:text_
                                                        font:font_
                                                       color:color_];
	return clone;
}

- (BOOL)isConnectableTo:(id<MarkupElement>)lhs{
    if([lhs isMemberOfClass:[self class]]){
        MarkupText* markupText = (MarkupText*)lhs;
        if([font_ isEqual:markupText.font] &&
           [color_ isEqual:markupText.color]){
            return YES;
        }
    }
    return NO;
}

- (id<MarkupElement>)connectBack:(id<MarkupElement>)rhs
{
    if(![self isConnectableTo:rhs])return nil;
    MarkupText* text = (MarkupText*)rhs;
    return [MarkupText textWithText:[text_ stringByAppendingString:text.text]
                                     font:font_
                                    color:color_];
}

- (UIFont*)font{
    return font_;
}
- (UIColor*)color{
    return color_;
}

@end
