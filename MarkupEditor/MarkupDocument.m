//
//  Document.m
//  CustomTextInputText
//
//  Created by shimizu on 11/02/23.
//  Copyright 2011 MK System. All rights reserved.
//

#import "MarkupDocument.h"
#import "MarkupElementPosition.h"

@implementation MarkupDocument

@synthesize markupElements=elements_;

- (void)setTestData
{
	[elements_ addObject:
	 [MarkupText markupTextWithText:@"abcd"
                               font:[UIFont systemFontOfSize:16]
                              color:[UIColor redColor]]];
	[elements_ addObject:
	 [MarkupText markupTextWithText:@"EFG"
                               font:[UIFont systemFontOfSize:30]
                              color:[UIColor blueColor]]];
	[elements_ addObject:
	 [MarkupText markupTextWithText:@"hij"
                               font:[UIFont systemFontOfSize:20]
                              color:[UIColor greenColor]]];
	[elements_ addObject:
	 [MarkupText markupTextWithText:@"klmnopqrstuvw"
                               font:[UIFont systemFontOfSize:60]
                              color:[UIColor blackColor]]];
	[elements_ addObject:
	 [[[NewLine alloc]initWithFont:[UIFont systemFontOfSize:20]]
	  autorelease]];
	
	[elements_ addObject:
	 [MarkupText markupTextWithText:@"xyzあいうえおかきくけこ"
                               font:[UIFont systemFontOfSize:40]
                              color:[UIColor redColor]]];
	[elements_ addObject:
	 [[[NewLine alloc]initWithFont:[UIFont systemFontOfSize:20]]
	  autorelease]];
	
	[elements_ addObject:
	 [MarkupText markupTextWithText:@"abcd"
                               font:[UIFont systemFontOfSize:20]
                              color:[UIColor redColor]]];
	[elements_ addObject:
	 [MarkupText markupTextWithText:@"EFG"
                               font:[UIFont systemFontOfSize:40]
                              color:[UIColor blueColor]]];
	[elements_ addObject:
	 [MarkupText markupTextWithText:@"hij"
                               font:[UIFont systemFontOfSize:16]
                              color:[UIColor greenColor]]];
}

- (id)init;
{
	self = [super init];
	if (self != nil) {
		elements_ = [[NSMutableArray alloc]init];
		defaultFont_ = [[UIFont systemFontOfSize:20]retain];
		defaultColor_ = [[UIColor blackColor]retain];
	}
	return self;
}

- (void)dealloc{
	[elements_ release];
    [viewCache_ release];
	[defaultFont_ release];
	[defaultColor_ release];
	[super dealloc];
}

- (void)layoutWithWidth:(CGFloat)width;
{
    if(viewCache_){
        [viewCache_ release];
    }
    viewCache_ = [[MarkupViewCache alloc]init];

	id<MarkupElement> previous = nil;
    id<MarkupElement> lastObject = [elements_ lastObject];
	for(id<MarkupElement> elm in elements_)
	{
		[elm layoutWithViewCache:viewCache_
                 previousElement:previous
                   documentWidth:width
                          isLast:(lastObject == elm) ? YES : NO];
		previous = elm;
	}
	layouted_ = YES;
}

- (void)drawRect:(CGRect)rect width:(CGFloat)width;
{
	if(!layouted_){
		[self layoutWithWidth:width];
	}
	for(id<MarkupElement> elm in elements_)
	{
		[elm drawRect:rect];
	}
}

- (NSString*)textInRange:(MarkupElementRange*)range
{
	if(range.empty)return [NSString string];
    
    MarkupElementPosition* start = [range startPosition];
    MarkupElementPosition* end = [range endPosition];
    
    if(start.elementIndex == end.elementIndex){
        id<MarkupElement> elm = [elements_ objectAtIndex:start.elementIndex];
        return [elm stringFrom:start.valueIndex to:end.valueIndex];
    }
	NSMutableString* string = [NSMutableString string];
    NSInteger last = end.elementIndex;
    if(!end.inAnElement){
        last--;
    }
    for(NSInteger i = start.elementIndex; i <= last; ++i){
        id<MarkupElement> elm = [elements_ objectAtIndex:i];
        if(i == start.elementIndex){
            [string appendString:[elm stringFrom:start.valueIndex to:[elm length]]];
        }else if(i == end.elementIndex){
            [string appendString:[elm stringFrom:0 to:end.valueIndex]];
        }else{
            [string appendString:[elm stringFrom:0 to:[elm length]]];
        }
    }
	return string;
}

/*
- (MarkupElementsRange*)markupElementsWithRange:(UITextRange*)range
{
	MarkupElementsRange* res = [MarkupElementsRange markupElementsRange];
	
	const NSInteger start = ((TextPosition*)range.start).index;
	const NSInteger end = ((TextPosition*)range.end).index;
	NSInteger currentStart = 0;
	NSInteger currentEnd = 0;
	
	NSInteger index = 0;
	
	for(id<MarkupElement> elem in markupElements_)
	{
		currentEnd += [elem length];
		
		if(currentStart <= start && start <  currentEnd){
            res.firstElementIndex = index;
            res.firstValueIndexInElement = start - currentStart;
        }
        if(currentStart <  end   && end   <= currentEnd){
            res.lastElementIndex = index;
            res.lastValueIndexInElement = end - currentStart;
            return res;
        }
        
		currentStart = currentEnd;
		index++;
	}
    ASSERT(NO, @"Index out of range");
	return nil;
}
*/

- (Pare*)splitElementAtPosition:(MarkupElementPosition*)position;
{
    if(![self positionIsLast:position]){
        id<MarkupElement> elm = [elements_ objectAtIndex:position.elementIndex];
        return [elm splitAtIndex:position.valueIndex];
    }else{
        return [Pare pare];
    }
}

- (MarkupElementPosition*)positionFromPosition:(MarkupElementPosition*)from
                                        offset:(NSInteger)offset;
{
    if(offset == 0)return [[self copy]autorelease];
    if(0 < offset){
        offset += from.valueIndex;
        for(NSInteger i = from.elementIndex; i < [elements_ count]; ++i){
            id<MarkupElement> elm = [elements_ objectAtIndex:i];
            if(offset < [elm length]){
                return [MarkupElementPosition positionWithElementIndex:i
                                                            valueIndex:offset];
            }
            offset -= [elm length];
        }
        return [MarkupElementPosition positionWithElementIndex:[elements_ count]
                                                    valueIndex:0];
    }else{
        NSInteger i = from.elementIndex;
        if(from.inAnElement){
            offset += from.valueIndex;
        }else{
            i--;
            id<MarkupElement> elm = [elements_ objectAtIndex:i];
            offset += [elm length];
        }
        
        for(; i >= 0; --i){
            id<MarkupElement> elm = [elements_ objectAtIndex:i];
            if(0 <= offset){
                return [MarkupElementPosition positionWithElementIndex:i
                                                            valueIndex:offset];
            }
            offset += [elm length];
        }
        return [MarkupElementPosition positionWithElementIndex:0
                                                    valueIndex:0];
    }
}

- (NSInteger)offsetFrom:(MarkupElementPosition*)from to:(MarkupElementPosition*)to;
{
    NSComparisonResult comp = [from compareTo:to];
    switch (comp) {
        case NSOrderedSame:
            return 0;
        case NSOrderedAscending:{
            NSInteger res = to.valueIndex - from.valueIndex;
            for(NSInteger i = from.elementIndex; i < to.elementIndex; ++i)
            {
                id<MarkupElement> elm = [elements_ objectAtIndex:i];
                res += [elm length];
            }
            return res;
        }
        case NSOrderedDescending:{
            NSInteger res = to.valueIndex - from.valueIndex;
            for(NSInteger i = to.elementIndex; i < to.elementIndex; ++i)
            {
                id<MarkupElement> elm = [elements_ objectAtIndex:i];
                res += [elm length];
            }
            return res;
        }
        default:
            ASSERT(0, @"");
            return 0;
    }
}

- (BOOL)positionIsLast:(MarkupElementPosition*)position;
{
    return position.elementIndex == [elements_ count];
}

- (NSMutableArray*)markupElementsWithText:(NSString*)text
									 font:(UIFont*)font
									color:(UIColor*)color
{
	
	NSMutableArray* res
	= [[NSMutableArray alloc]init];
	
    NSRange textRange = NSMakeRange(0, [text length]);
    while(textRange.length > 0) {
		NSRange subrange = [text lineRangeForRange:NSMakeRange(textRange.location, 0)];
        NSString* lineBreaked = [text substringWithRange:subrange];
		NSString* lineStr = [lineBreaked stringByTrimmingCharactersInSet:
							 [NSCharacterSet newlineCharacterSet]];
		if([lineStr length] != 0){
			MarkupText* elem = [[MarkupText alloc]initWithText:lineStr
                                                          font:font
                                                         color:color];
			[res addObject:elem];
			[elem release];
		}
		if([lineStr length] != [lineBreaked length]){
			//改行を含む
			NewLine* elem = [[NewLine alloc]initWithFont:font];
			[res addObject:elem];
			[elem release];
		}
		
		textRange.location = NSMaxRange(subrange);
		textRange.length -= subrange.length;
	}
	return res;
}

- (Pare*)splitElementsAtPosition:(MarkupElementPosition*)position
{
    Pare* res = [Pare pare];
    if(!position.inAnElement){
        res.first = [elements_ subarrayWithRange:NSMakeRange(0, position.elementIndex)];
        res.second = [elements_ subarrayWithRange:
                       NSMakeRange(position.elementIndex, [elements_ count] - position.elementIndex)];
    }else{
        res.first = [elements_ subarrayWithRange:NSMakeRange(0, position.elementIndex)];
        Pare* centerElements = [self splitElementsAtPosition:position];
        if(centerElements.first){
            res.first = [NSMutableArray arrayWithArray:res.first];
            [res.first addObject:centerElements.first];
        }
        NSArray* lastArray = [elements_ subarrayWithRange:
                              NSMakeRange(position.elementIndex + 1,
                                          [elements_ count] - position.elementIndex - 1)];
        if(centerElements.second){
            res.second = [NSMutableArray arrayWithObject:centerElements.second];
            [res.second addObjectsFromArray:lastArray];
        }else{
            res.second = lastArray;
        }
    }
    return res;
}

- (void)replaceRange:(MarkupElementRange*)range withText:(NSString*)text
{
    layouted_ = NO;
    
    MarkupElementPosition* start = (MarkupElementPosition*)range.start;
    MarkupElementPosition* end = (MarkupElementPosition*)range.end;
    
    UIFont* font = nil;
    UIColor* color = nil;
    
    
    NSInteger i = 0;
    if(start.inAnElement){
        i = start.elementIndex;
    }
    else{
        i = start.elementIndex - 1;
    }
    for(; 0 <= i; --i){
        id<MarkupElement> elm = [elements_ objectAtIndex:i];
        if([elm respondsToSelector:@selector(font)]){
            font = elm.font;
        }
        if([elm respondsToSelector:@selector(color)]){
            color = elm.color;
        }
        if(font && color){
            break;
        }
    } 
    if(!font){ font = defaultFont_; }
    if(!color){ color = defaultColor_; }
    
    NSArray* textElements
    = [self markupElementsWithText:text
                              font:font
                             color:color];
    NSMutableArray* newElements = nil;
    if(range.empty){
        if(start.isFirst){
            newElements = [[MarkupDocument connectMarkupElements:textElements andOthers:elements_]retain];
        }
        if ([self positionIsLast:start]) {
            newElements = [[MarkupDocument connectMarkupElements:elements_ andOthers:textElements]retain];
        }
    }else{
        Pare* startPare = [self splitElementsAtPosition:start];
        Pare* endPare = [self splitElementsAtPosition:end];
        newElements = [MarkupDocument connectMarkupElements:startPare.first andOthers:textElements];
        newElements = [MarkupDocument connectMarkupElements:newElements andOthers:endPare.second];
    }
    [elements_ release];
    elements_ = newElements;
}

+ (NSMutableArray*)connectMarkupElements:(NSArray *)lhs andOthers:(NSArray *)rhs
{
    if([lhs count] == 0){
        return [NSMutableArray arrayWithArray:rhs];
    }
    if([rhs count] == 0){
        return [NSMutableArray arrayWithArray:lhs];
    }
    NSMutableArray* res = [NSMutableArray array];
    id<MarkupElement> leftLast = [lhs lastObject];
    id<MarkupElement> rightFirst = [rhs objectAtIndex:0];
    id<MarkupElement> connected = [leftLast connectBack:rightFirst];
    NSInteger leftCount = [lhs count];
    NSInteger rightCout = [rhs count];
    if(connected){
        leftCount--;
        rightCout--;
    }
    for(NSInteger i = 0; i < leftCount; ++i){
        [res addObject:[lhs objectAtIndex:i]];
    }
    if(connected){
        [res addObject:connected];
    }
    for(NSInteger i = 0; i < rightCout; ++i){
        [res addObject:[res objectAtIndex:i]];
    }
    return res;
}

@end
