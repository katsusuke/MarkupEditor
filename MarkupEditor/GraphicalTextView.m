//
//  GraphicalTextView.m
//  CustomTextInputText
//
//  Created by shimizu on 11/02/21.
//  Copyright 2011 MK System. All rights reserved.
//

#import "GraphicalTextView.h"
#import "MarkupElementPosition.h"
#import "HandWritingInputView.h"
#import "MarkupElement.h"
#import "MarkupView.h"

#ifdef DEBUG
static MarkupElementPosition* POS_CAST(UITextPosition* pos)
{
    if(pos == nil){
        LOG(@"pos is null!!!!!");
    }
    if(![pos isMemberOfClass:[MarkupElementPosition class]]){
        LOG(@"pos is not IndexedPosition. pos:%@", pos);
    }
    return (MarkupElementPosition*)pos;
}
#else
#define POS_CAST(pos) ((MarkupElementPosition*)pos)
#endif

@interface GraphicalTextView()

- (void)syncCaretViewFrame;
- (NSInteger)indexFromPosition:(MarkupElementPosition*)pos;
- (MarkupElementPosition*)positionFromIndex:(NSInteger)index;

@end

@implementation GraphicalTextView

@synthesize selectedTextRange=selectedTextRange_;
@synthesize markedTextRange=markedTextRange_;
@synthesize markedTextStyle=markedTextStyle_;
@synthesize inputDelegate=inputDelegate_;
@synthesize tokenizer=inputTokenizer_;
@synthesize inputTextMode=inputTextMode_;
@synthesize defaultFont=defaultFont_;
@synthesize defaultColor=defaultColor_;
@synthesize specificFont=specificFont_;
@synthesize specificColor=specificColor_;

+ (NSArray*)connectMarkupElements:(NSArray *)lhs andOthers:(NSArray *)rhs
{
    if([lhs count] == 0){
        return [NSArray arrayWithArray:rhs];
    }
    if([rhs count] == 0){
        return [NSArray arrayWithArray:lhs];
    }
    NSMutableArray* res = [NSMutableArray array];
    id<MarkupElement> leftLast = [lhs lastObject];
    id<MarkupElement> rightFirst = [rhs objectAtIndex:0];
    id<MarkupElement> connected = [leftLast connectBack:rightFirst];
    NSInteger leftCount = [lhs count];
    NSInteger rightStart = 0;
    if(connected){
        leftCount--;
        rightStart++;
    }
    for(NSInteger i = 0; i < leftCount; ++i){
        [res addObject:[lhs objectAtIndex:i]];
    }
    if(connected){
        [res addObject:connected];
    }
    for(NSInteger i = rightStart; i < [rhs count]; ++i){
        [res addObject:[rhs objectAtIndex:i]];
    }
    return res;
}

+ (void)getFirstFont:(UIFont **)refFont andColor:(UIColor **)refColor fromElements:(NSArray *)elements
{
    *refFont = nil;
    *refColor = nil;
    for (id<MarkupElement> elm in elements) {
        if(*refFont == nil){
            if([elm respondsToSelector:@selector(font)]){
                *refFont = elm.font;
            }
        }
        if(*refColor == nil){
            if([elm respondsToSelector:@selector(color)]){
                *refColor = elm.color;
            }
        }
        if(*refFont != nil && *refColor != nil){
            return;
        }
    }
}

+ (void)getLastFont:(UIFont **)refFont andColor:(UIColor **)refColor fromElements:(NSArray *)elements
{
    *refFont = nil;
    *refColor = nil;
    for (id<MarkupElement> elm in [elements reverseObjectEnumerator]) {
        if(*refFont == nil){
            if([elm respondsToSelector:@selector(font)]){
                *refFont = elm.font;
            }
        }
        if(*refColor == nil){
            if([elm respondsToSelector:@selector(color)]){
                *refColor = elm.color;
            }
        }
        if(*refFont != nil && *refColor != nil){
            return;
        }
    }
}

- (void)setTestData
{
    [defaultFont_ release];
    [defaultColor_ release];
    
    defaultFont_ = [[UIFont systemFontOfSize:16]retain];
    defaultColor_ = [[UIColor redColor]retain];
    
	[elements_ addObject:
	 [MarkupText textWithText:@"abcd"
                         font:defaultFont_
                        color:defaultColor_]];
	[elements_ addObject:
	 [MarkupText textWithText:@"EFG"
                         font:[UIFont systemFontOfSize:30]
                        color:[UIColor blueColor]]];
	[elements_ addObject:
	 [MarkupText textWithText:@"hij"
                         font:[UIFont systemFontOfSize:20]
                        color:[UIColor greenColor]]];
	[elements_ addObject:
	 [MarkupText textWithText:@"klmnopqrstuvw"
                         font:[UIFont systemFontOfSize:60]
                        color:[UIColor blackColor]]];
	[elements_ addObject:
	 [MarkupNewLine markupNewLineWithFont:[UIFont systemFontOfSize:30]]];
    [elements_ addObject:
	 [MarkupText textWithText:@"xyzあいうえおかきくけこ"
                         font:[UIFont systemFontOfSize:40]
                        color:[UIColor redColor]]];
	[elements_ addObject:[MarkupNewLine markupNewLineWithFont:[UIFont systemFontOfSize:10]]];
	[elements_ addObject:
	 [MarkupText textWithText:@"abcd"
                         font:[UIFont systemFontOfSize:20]
                        color:[UIColor redColor]]];
	[elements_ addObject:
	 [MarkupText textWithText:@"EFG"
                         font:[UIFont systemFontOfSize:40]
                        color:[UIColor blueColor]]];
	[elements_ addObject:
	 [MarkupText textWithText:@"hij"
                         font:[UIFont systemFontOfSize:20]
                        color:[UIColor greenColor]]];
    /*
    MarkupElementPosition* ep = self.endPosition;
    NSInteger i = [self indexFromPosition:ep];
    MarkupElementPosition* p2 = [self positionFromIndex:i];
    LOG(@"%d", [ep isEqualToPosition:p2]);
    
    MarkupElementPosition* p3 = [MarkupElementPosition positionWithElementIndex:9
                                                                     valueIndex:2];
    NSInteger i2 = [self indexFromPosition:p3];
    ASSERT(i2 == 47, @"indexFromPosition");
    */
    //elements_ count => 10
}

- (void)preInit_{
    elements_ = [[NSMutableArray alloc]init];
    defaultFont_ = [[UIFont systemFontOfSize:20]retain];
    defaultColor_ = [[UIColor blackColor]retain];
    
    [self setTestData];
    
    [self setSelectedTextRange:
     [[MarkupElementRange alloc]initWithStart:self.endPosition
                                          end:self.endPosition]];
    markedTextRange_ = nil;
    cartView_ = [[CaretView alloc]initWithFrame:CGRectZero];
    
    UIPanGestureRecognizer* panRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(singleTaped:)];
    [self addGestureRecognizer:panRecognizer];
    [panRecognizer release];
    UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTaped:)];
    [self addGestureRecognizer:tapRecognizer];
    [tapRecognizer release];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
        [self preInit_];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self preInit_];
    }
    return self;
}

- (void)dealloc {
	[elements_ release];
    [viewCache_ release];
	[defaultFont_ release];
	[defaultColor_ release];
    [selectedTextRange_ release];
    [markedTextRange_ release];
    [cartView_ release];
    [super dealloc];
}

- (void)layout{
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
                   documentWidth:self.frame.size.width
                          isLast:(lastObject == elm) ? YES : NO];
		previous = elm;
	}
	layouted_ = YES;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
	if(!layouted_){
		[self layout];
	}
	for(id<MarkupElement> elm in elements_)
	{
		[elm drawRect:rect];
	}
}

- (UIView*)inputView{
    if(inputTextMode_ == InputTextModeQwerty){
        return [super inputView];
    }else{
        HandWritingInputView* view
        = [[[HandWritingInputView alloc]initWithGraphicalTextView:self]autorelease];
        //view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        return view;
    }
}

- (BOOL)canBecomeFirstResponder{ 
	return YES;
}
- (BOOL)becomeFirstResponder{
    [self addSubview:cartView_];
    [self syncCaretViewFrame];
    return [super becomeFirstResponder];
}
- (BOOL)resignFirstResponder{
    [cartView_ removeFromSuperview];
    [self syncCaretViewFrame];
    return [super resignFirstResponder];
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self becomeFirstResponder];
}
- (UITextPosition*)beginningOfDocument{
    return [MarkupElementPosition positionWithElementIndex:0 valueIndex:0];
}
- (UITextPosition*)endOfDocument{
    return [MarkupElementPosition positionWithElementIndex:[elements_ count] valueIndex:0];
}
- (MarkupElementPosition*)beginPosition{
    return [MarkupElementPosition positionWithElementIndex:0 valueIndex:0];
}
- (MarkupElementPosition*)endPosition{
    return [MarkupElementPosition positionWithElementIndex:[elements_ count] valueIndex:0];
}

- (BOOL)hasText
{
    return [elements_ count] != 0;
}
- (void)insertText:(NSString *)text
{
    T(@"text:%@", text);
    [self replaceRange:selectedTextRange_ withText:text];
    PO(selectedTextRange_);
    [self setSelectedTextRange:
     [[MarkupElementRange alloc]initWithStart:self.endPosition
                                          end:self.endPosition]];
    PO(selectedTextRange_);
    [self setNeedsDisplay];
    [self syncCaretViewFrame];
}
- (Pair*)splitElementAtPosition:(MarkupElementPosition*)position;
{
    ASSERT(position.inAnElement, @"Position must be in an element");
    if([position compareTo:self.endPosition] == NSOrderedAscending){
        id<MarkupElement> elm = [elements_ objectAtIndex:position.elementIndex];
        return [elm splitAtIndex:position.valueIndex];
    }else{
        return [Pair pair];
    }
}

- (Pair*)splitElementsAtPosition:(MarkupElementPosition*)position
{
    Pair* res = [Pair pair];
    if(!position.inAnElement){
        res.first = [elements_ subarrayWithRange:NSMakeRange(0, position.elementIndex)];
        res.second = [elements_ subarrayWithRange:
                      NSMakeRange(position.elementIndex, [elements_ count] - position.elementIndex)];
    }else{
        res.first = [elements_ subarrayWithRange:NSMakeRange(0, position.elementIndex)];
        Pair* centerElements = [self splitElementAtPosition:position];
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

- (void)deleteWithRange:(MarkupElementRange*)range;
{
    if(range.empty){
        return;
    }
    layouted_ = NO;
    MarkupElementPosition* start = range.startPosition;
    MarkupElementPosition* end = range.endPosition;
    
    Pair* firstPair = [self splitElementsAtPosition:start];
    Pair* lastPair = [self splitElementsAtPosition:end];
    NSArray* newElements = [GraphicalTextView connectMarkupElements:firstPair.first andOthers:lastPair.second];
    [elements_ removeAllObjects];
    [elements_ addObjectsFromArray:newElements];
}

- (void)deleteBackward
{
    TV();
    NSInteger index = [self indexFromPosition:selectedTextRange_.startPosition];
    if(selectedTextRange_.isEmpty){
        if(index == 0)return;
        MarkupElementPosition* start =
        POS_CAST([self positionFromPosition:selectedTextRange_.startPosition
                                     offset:-1]);
        index--;
        [self deleteWithRange:
         [MarkupElementRange rangeWithStart:start
                                        end:selectedTextRange_.endPosition]];
        
    }else{
        [self deleteWithRange:selectedTextRange_];
    }
    MarkupElementPosition* pos = [self positionFromIndex:index];
    [self setSelectedTextRange:
     [MarkupElementRange rangeWithStart:pos
                                    end:pos]];
    [self setNeedsDisplay];
    [self syncCaretViewFrame];
}

- (void)setFrame:(CGRect)frame
{
    RECTLOG(frame);
    [super setFrame:frame];
    [self layout];
    [self syncCaretViewFrame];
    [self setNeedsDisplay];
}

- (NSString*)textInRange:(UITextRange *)range
{
	if(range.empty)return [NSString string];
    
    MarkupElementPosition* start = POS_CAST(range.start);
    MarkupElementPosition* end = POS_CAST(range.end);
    
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
            [string appendString:elm.stringValue];
        }
    }
	return string;
}

- (NSMutableArray*)markupElementsWithText:(NSString*)text
									 font:(UIFont*)font
									color:(UIColor*)color
                                   marked:(BOOL)marked
{
	NSMutableArray* res = [NSMutableArray array];
	
    NSRange textRange = NSMakeRange(0, [text length]);
    while(textRange.length > 0) {
		NSRange subrange = [text lineRangeForRange:NSMakeRange(textRange.location, 0)];
        NSString* lineBreaked = [text substringWithRange:subrange];
		NSString* lineStr = [lineBreaked stringByTrimmingCharactersInSet:
							 [NSCharacterSet newlineCharacterSet]];
		if([lineStr length] != 0){
			MarkupText* elem = [[MarkupText alloc]initWithText:lineStr
                                                          font:font
                                                         color:color
                                                        marked:marked];
			[res addObject:elem];
			[elem release];
		}
		if([lineStr length] != [lineBreaked length]){
			//改行を含む
			MarkupNewLine* elem = [[MarkupNewLine alloc]initWithFont:font];
			[res addObject:elem];
			[elem release];
		}
		
		textRange.location = NSMaxRange(subrange);
		textRange.length -= subrange.length;
	}
	return res;
}

- (void)insertElements:(NSArray*)insertElements atElementIndex:(NSInteger)index;
{
    layouted_ = NO;
    ASSERT(0 <= index && index <= [elements_ count], @"");
    NSArray* newElements = nil;
    if(index == 0){
        UIFont* font = nil;
        UIColor* color = nil;
        [GraphicalTextView getFirstFont:&font andColor:&color fromElements:insertElements];
        //要素の始めに挿入時はdefault を書き換える
        if(font){ self.defaultFont = font; }
        if(color){ self.defaultColor = color; }
        newElements = [GraphicalTextView connectMarkupElements:insertElements
                                                  andOthers:elements_];
    }
    else if(index == [elements_ count]){
        newElements = [GraphicalTextView connectMarkupElements:elements_
                                                  andOthers:insertElements];
    }else{
        newElements = [elements_ subarrayWithRange:NSMakeRange(0, index)];
        NSArray* last = [elements_ subarrayWithRange:NSMakeRange(index, [elements_ count] - index)];
        newElements = [GraphicalTextView connectMarkupElements:newElements andOthers:insertElements];
        newElements = [GraphicalTextView connectMarkupElements:newElements andOthers:last];
    }
    [elements_ removeAllObjects];
    [elements_ addObjectsFromArray:newElements];
}

- (void)insertElements:(NSArray *)insertElements atPosition:(MarkupElementPosition*)position
{
    layouted_ = NO;
    if(!position.inAnElement){
        [self insertElements:insertElements atElementIndex:position.elementIndex];
    }else{
        NSArray* newElements = [elements_ subarrayWithRange:NSMakeRange(0, position.elementIndex)];
        Pair* center = [self splitElementAtPosition:position];
        NSArray* last
        = [elements_ subarrayWithRange:NSMakeRange(position.elementIndex + 1,
                                                   [elements_ count] - position.elementIndex - 1)];
        if(center.first){
            newElements = [GraphicalTextView connectMarkupElements:newElements
                                                      andOthers:[NSArray arrayWithObject:center.first]];
        }
        newElements = [GraphicalTextView connectMarkupElements:newElements
                                                  andOthers:insertElements];
        if(center.second){
            newElements = [GraphicalTextView connectMarkupElements:newElements
                                                      andOthers:[NSArray arrayWithObject:center.second]];
        }
        newElements = [GraphicalTextView connectMarkupElements:newElements
                                                  andOthers:last];
        [elements_ removeAllObjects];
        [elements_ addObjectsFromArray:newElements];
    }
}

- (void)replaceRange:(MarkupElementRange *)range withElements:(NSArray *)elements
{
    layouted_ = NO;
    MarkupElementPosition* start = range.startPosition;
    MarkupElementPosition* end = range.endPosition;
    
    if(range.empty){
        [self insertElements:elements atPosition:start];
    }else{
        Pair* firstPair = [self splitElementsAtPosition:start];
        Pair* lastPair = [self splitElementsAtPosition:end];
        
        NSArray* newElements = [GraphicalTextView connectMarkupElements:firstPair.first andOthers:elements];
        newElements = [GraphicalTextView connectMarkupElements:newElements andOthers:lastPair.second];
        [elements_ removeAllObjects];
        [elements_ addObjectsFromArray:newElements];
    }
}

- (void)replaceRange:(MarkupElementRange*)range withText:(NSString*)text marked:(BOOL)marked
{
    NSArray* firstElements
    = [elements_ subarrayWithRange:NSMakeRange(0, range.startPosition.splitNextElementIndex)];
    UIFont* font = nil;
    UIColor* color = nil;
    [GraphicalTextView getLastFont:&font andColor:&color fromElements:firstElements];
    if(specificFont_){ font = specificFont_; }
    else if(!font){ font = defaultFont_; }
    if(specificColor_){ color = specificColor_; }
    else if(!color){ color = defaultColor_; }
    
    NSArray* elements
    = [self markupElementsWithText:text
                              font:font
                             color:color
                            marked:marked];
    [self replaceRange:range withElements:elements];
}

- (void)replaceRange:(UITextRange *)range withText:(NSString *)text
{
    [self replaceRange:(MarkupElementRange*)range withText:text marked:NO];
}

- (void)addHandWritingPoints:(NSArray *)points
{
    NSArray* firstElements = [elements_ subarrayWithRange:NSMakeRange(0, selectedTextRange_.startPosition.splitNextElementIndex)];
    UIFont* font = nil;
    UIColor* color = nil;
    [GraphicalTextView getLastFont:&font andColor:&color fromElements:firstElements];
    if(!font){ font = defaultFont_; }
    if(!color){ color = defaultColor_; }
    NSArray* elements
    = [NSArray arrayWithObject:
       [MarkupHandWritingChar charWithPoints:points font:font color:color]];
    NSInteger index = [self indexFromPosition:selectedTextRange_.startPosition] + 1;
    [self replaceRange:selectedTextRange_ withElements:elements];
    MarkupElementPosition* pos = [self positionFromIndex:index];
    
    [self setSelectedTextRange:
     [[MarkupElementRange alloc]initWithStart:pos
                                          end:pos]];
    [self setNeedsDisplay];
    [self syncCaretViewFrame];
}

- (void)setMarkedTextRange:(UITextRange*)range
{
    T(@"range:%@", range);
    if(markedTextRange_ != range){
        [markedTextRange_ release];
        markedTextRange_ = [(MarkupElementRange*)range retain];
    }
}
- (void)setSelectedTextRange:(UITextRange *)range
{
    T(@"range:%@", range);
    MarkupElementRange* elementRange = (MarkupElementRange*)range;
    if(selectedTextRange_ != range){
        [selectedTextRange_ release];
        selectedTextRange_ = [elementRange retain];
        [self syncCaretViewFrame];
    }
}

// MarkedText => 日本語入力とかで入力された文字列
// selectedRange => 入力された文字列の中での選択範囲
// あい|う
// 
// の様に あいの後ろにカーソルがあれば loc => 2 length => 0
// length が 0以外になるタイミングは不明
- (void)setMarkedText:(NSString *)markedText selectedRange:(NSRange)selectedNSRange
{
    T(@"markedText:%@ selectedNSRange:(location:%d length:%d)",
      markedText, selectedNSRange.location, selectedNSRange.length);
    LOG(@"markedTextRange_:%@", markedTextRange_);
    
    if (markedTextRange_){
        if (!markedText){ 
            markedText = @"";// nilが来ることある
        }
		// Replace characters in text storage and update markedText range length
        NSInteger index = [self indexFromPosition:markedTextRange_.startPosition];
        [self replaceRange:markedTextRange_ withText:markedText marked:YES];
        MarkupElementPosition* first = [self positionFromIndex:index];
        MarkupElementPosition* last = [self positionFromIndex:index + markedText.length];
        [self setMarkedTextRange:[self textRangeFromPosition:first
                                                  toPosition:last]];
    } else{
        if([markedText length] != 0){
            // There currently isn't a marked text range, but there is a selected range,
            // so replace text storage at selected range and update markedTextRange.
            NSInteger index = [self indexFromPosition:selectedTextRange_.startPosition];
            [self replaceRange:selectedTextRange_ withText:markedText marked:YES];
            MarkupElementPosition* first = [self positionFromIndex:index];
            MarkupElementPosition* last = [self positionFromIndex:index + markedText.length];
            [self setMarkedTextRange:[self textRangeFromPosition:first
                                                      toPosition:last]];
        }else{
            // There currently isn't marked or selected text ranges, so just insert
            // given text into storage and update markedTextRange.
            
        }
    }    
	// Updated selected text range and underlying SimpleCoreTextView
    if(markedTextRange_){
        NSInteger firstIndex = [self indexFromPosition:markedTextRange_.startPosition];
        MarkupElementPosition* pos1 = [self positionFromIndex:firstIndex + selectedNSRange.location];
        MarkupElementPosition* pos2 = [self positionFromIndex:firstIndex + selectedNSRange.location + selectedNSRange.length];
        
        [self setSelectedTextRange:[self textRangeFromPosition:pos1
                                                    toPosition:pos2]];	
    }
    [self setNeedsDisplay];
    [self syncCaretViewFrame];
}

- (MarkupElementPosition*)positionFromIndex:(NSInteger)index
{
    for(NSInteger i = 0; i < [elements_ count]; ++i){
        id<MarkupElement> elm = [elements_ objectAtIndex:i];
        if(index < [elm length]){
            return [MarkupElementPosition positionWithElementIndex:i valueIndex:index];
        }else{
            index -= [elm length];
        }
    }
    return [self endPosition];
}
- (NSInteger)indexFromPosition:(MarkupElementPosition*)pos{
    NSInteger index = 0;
    for(NSInteger i = 0; i < pos.elementIndex; ++i){
        id<MarkupElement> elm = [elements_ objectAtIndex:i];
        index += [elm length];
    }
    return index + pos.valueIndex;
}
- (void)unmarkText
{
    if(!markedTextRange_)return;
    
    NSMutableArray* unmarkedElements = [NSMutableArray array];
    for(NSInteger i = markedTextRange_.startPosition.elementIndex;
        i < markedTextRange_.endPosition.splitNextElementIndex; ++i)
    {
        //copy しないと駄目かも
        id<MarkupElement> elm = [elements_ objectAtIndex:i];
        if([elm respondsToSelector:@selector(setMarked:)]){
            elm.marked = NO;
        }
        [unmarkedElements addObject:elm];
    }
    NSInteger index = [self indexFromPosition:markedTextRange_.endPosition];
    [self replaceRange:markedTextRange_ withElements:unmarkedElements];
    MarkupElementPosition* pos = [self positionFromIndex:index];
    [selectedTextRange_ release];
    selectedTextRange_ = [[MarkupElementRange alloc]initWithStart:pos end:pos];
    
    [self setMarkedTextRange:nil];
    [self setNeedsDisplay];
    [self syncCaretViewFrame];
}

- (UITextRange*)textRangeFromPosition:(UITextPosition *)fromPosition
                           toPosition:(UITextPosition *)toPosition
{
    return [MarkupElementRange rangeWithStart:POS_CAST(fromPosition)
                                          end:POS_CAST(toPosition)];
}

- (UITextPosition*)positionFromPosition:(UITextPosition *)textPosition offset:(NSInteger)offset
{
    MarkupElementPosition* from = POS_CAST(textPosition);
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
        return self.endPosition;
    }else{
        if(from.isFirst){
            return self.beginPosition;
        }
        NSInteger i = from.elementIndex;
        if(from.inAnElement){
            id<MarkupElement> elm = [elements_ objectAtIndex:i];
            offset -= [elm length] - from.valueIndex;
        }else{
            i--;
        }
        for(; i >= 0; --i){
            id<MarkupElement> elm = [elements_ objectAtIndex:i];
            offset += [elm length];
            if(0 <= offset){
                return [MarkupElementPosition positionWithElementIndex:i
                                                            valueIndex:offset];
            }
        }
        return self.beginPosition;
    }
}

- (MarkupElementPosition*)positionDownFromPosition:(MarkupElementPosition*)position
                                             lines:(NSInteger)lines
{
    if(lines == 0)return [[self copy]autorelease];
    //行頭を0とした場合のIndex
    NSInteger columns = position.valueIndex;
    for(NSInteger i = position.elementIndex - 1; 0 <= i; --i){
        id<MarkupElement> elm = [elements_ objectAtIndex:i];
        if([elm isKindOfClass:[MarkupNewLine class]]){
            break;
        }else{
            columns += [elm length];
        }
    }
    //行頭のElement -> NewLineの次か、先頭
    MarkupElementPosition* topPosition = nil;
    if(0 < lines){
        for(NSInteger i = position.splitNextElementIndex;
            i < [elements_ count]; ++i)
        {
            id<MarkupElement> elm = [elements_ objectAtIndex:i];
            if([elm isMemberOfClass:[MarkupNewLine class]]){
                lines--;
                if(lines <= 0){
                    topPosition = [MarkupElementPosition positionWithElementIndex:i + 1 valueIndex:0];
                    break;
                }
            }
        }
        if(!topPosition){
            return self.endPosition;
        }
    }else{
        for(NSInteger i = position.elementIndex - 1; 0 <= i; --i){
            id<MarkupElement> elm = [elements_ objectAtIndex:i];
            if([elm isMemberOfClass:[MarkupNewLine class]]){
                lines++;
                if(0 < lines){
                    topPosition = [MarkupElementPosition positionWithElementIndex:i + 1 valueIndex:0];
                }
            }
        }
        if(!topPosition){
            topPosition = self.beginPosition;
        }
    }
    for(NSInteger i = topPosition.elementIndex; i < [elements_ count]; ++i){
        id<MarkupElement> elm = [elements_ objectAtIndex:i];
        if([elm isMemberOfClass:[MarkupNewLine class]]){
            return [MarkupElementPosition positionWithElementIndex:i
                                                        valueIndex:0];
        }
        if(columns < [elm length]){
            return [MarkupElementPosition positionWithElementIndex:i
                                                        valueIndex:columns];
        }
        columns -= [elm length];
    }
    return self.beginPosition;
}


//ソフトキーボードには無いけど、上下左右キーが押されたときに呼ばれる。
//エディタ的に、左端からn 文字目に移動することにする
//改行は無視する
- (UITextPosition *)positionFromPosition:(UITextPosition *)position
                             inDirection:(UITextLayoutDirection)direction
                                  offset:(NSInteger)offset
{
    T(@"position:%@ direction:%d offset:%d", position, direction, offset);
    NSInteger toOffset = offset;
    switch (direction) {
        case UITextLayoutDirectionLeft:
            toOffset = -offset;
        case UITextLayoutDirectionRight:
            return [self positionFromPosition:position offset:toOffset];
        case UITextLayoutDirectionUp:
            toOffset = -offset;
        case UITextLayoutDirectionDown:
            return [self positionDownFromPosition:POS_CAST(position) lines:toOffset];
    }
}

- (NSInteger)offsetFromPosition:(UITextPosition *)fromPosition toPosition:(UITextPosition *)toPosition
{
    MarkupElementPosition* from = POS_CAST(fromPosition);
    MarkupElementPosition* to = POS_CAST(toPosition);
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

- (NSComparisonResult)comparePosition:(UITextPosition *)position toPosition:(UITextPosition *)other
{
    return [POS_CAST(position) compareTo:POS_CAST(other)];
}

// UITextInput protocol method - Return the text position that is at the farthest 
// extent in a given layout direction within a range of text.
- (UITextPosition *)positionWithinRange:(UITextRange *)range
                    farthestInDirection:(UITextLayoutDirection)direction
{
    T(@"range:%@ direction:%d", range, direction);
    switch (direction) {
        case UITextLayoutDirectionUp:
        case UITextLayoutDirectionLeft:
            return [[range.start copy]autorelease];
        case UITextLayoutDirectionRight:
        case UITextLayoutDirectionDown:
            return [[range.end copy]autorelease];
    }
}

// UITextInput protocol required method - Return a text range from a given text position 
// to its farthest extent in a certain direction of layout.
- (UITextRange *)characterRangeByExtendingPosition:(UITextPosition *)position
                                       inDirection:(UITextLayoutDirection)direction
{
    T(@"position:%@ direction:%d", position, direction);
    // Note that this sample assumes LTR text direction
    switch (direction) {
        case UITextLayoutDirectionUp:
        case UITextLayoutDirectionLeft:
            return [MarkupElementRange
                    rangeWithStart:POS_CAST([self positionFromPosition:position offset:-1])
                    end:POS_CAST(position)];
        case UITextLayoutDirectionRight:
        case UITextLayoutDirectionDown:
            return [MarkupElementRange
                    rangeWithStart:POS_CAST(position)
                    end:POS_CAST([self positionFromPosition:position offset:1])];
    }
}

/* Writing direction */
- (UITextWritingDirection)baseWritingDirectionForPosition:(UITextPosition *)position
                                              inDirection:(UITextStorageDirection)direction
{
    T(@"position:%@ direction:%d", position, direction);
    RD(UITextWritingDirectionLeftToRight);
    // This sample assumes LTR text direction and does not currently support BiDi or RTL.
    return UITextWritingDirectionLeftToRight;
}

- (void)setBaseWritingDirection:(UITextWritingDirection)writingDirection
                       forRange:(UITextRange *)range
{
    T(@"writingDirection:%d range:%@", writingDirection, range);
}

- (CGRect)caretRectForPosition:(MarkupElementPosition*)position width:(CGFloat)width;
{
    [self layout];
    if(position.elementIndex >= [elements_ count]){
        id<MarkupElement> last = [elements_ lastObject];
        if(last == nil){//空の時
            if(specificFont_){
                return CGRectMake(0, 0, 0, specificFont_.lineHeight);
            }else{
                return CGRectMake(0, 0, 0, defaultFont_.lineHeight);
            }
        }else{
            return [last createRectForValueIndex:[last length]];
        }
    }else{
        id<MarkupElement> elm = [elements_ objectAtIndex:position.elementIndex];
        return [elm createRectForValueIndex:position.valueIndex];
    }
}

/* Geometry used to provide, for example, a correction rect. */
- (CGRect)firstRectForRange:(UITextRange *)range
{
    PO(range);
    CGRect r0 = [self caretRectForPosition:POS_CAST(range.start)
                                     width:self.frame.size.width];
    CGRect r1 = [self caretRectForPosition:POS_CAST(range.end)
                                     width:self.frame.size.width];
    RECTLOG(r0);
    RECTLOG(r1);
    r0.size.width = 30;
    return r0;
}

- (CGRect)caretRectForPosition:(UITextPosition *)position
{
    CGRect rect
    = [self caretRectForPosition:POS_CAST(position)
                           width:self.frame.size.width];
    rect.size.width = 3;
    return rect;
}

/* Hit testing. */
//実装しなくても動くらしい
- (UITextPosition *)closestPositionToPoint:(CGPoint)point
{
    POINTLOG(point);
    return nil;
}
//実装しなくても動くらしい
- (UITextPosition *)closestPositionToPoint:(CGPoint)point
                               withinRange:(UITextRange *)range
{
    POINTLOG(point);
    PO(range);
    return nil;
}
//実装しなくても動くらしい
- (UITextRange *)characterRangeAtPoint:(CGPoint)point
{
    POINTLOG(point);
    return nil;
}

- (void)syncCaretViewFrame{
    cartView_.frame = [self caretRectForPosition:selectedTextRange_.start];
}

- (NSInteger)elementIndexByElement:(id<MarkupElement>)element{
    NSInteger i = 0;
    for(id<MarkupElement> elm in elements_){
        if(element == elm) break;
        i++;
    }
    return i;
}

- (void)singleTaped:(UIPanGestureRecognizer*)sender
{
    T(@"sender:%@", sender);
    CGPoint point = [sender locationInView:self];
    MarkupElementPosition* pos = nil;
    
    for(NSInteger i = 0; i < [elements_ count]; ++i){
        id<MarkupElement> e = [elements_ objectAtIndex:i];
        id<MarkupElement> next = [elements_ objectOrNullAtIndex:i + 1];
        NSInteger valueIndex =
        [e valueIndexFromPoint:point
                nextMarkupView:(next? [next firstMarkupView] : nil)];
        if(valueIndex != -1){
            if(valueIndex == [e length]){
                pos = [MarkupElementPosition positionWithElementIndex:i + 1 valueIndex:0];
            }else{
                pos = [MarkupElementPosition positionWithElementIndex:i valueIndex:valueIndex];
            }
            if([pos compareTo:markedTextRange_.startPosition] == NSOrderedAscending){
                pos = markedTextRange_.startPosition;
            }
            break;
        }
    }
    if(markedTextRange_ == nil){
        if(pos){
            [self setSelectedTextRange:[MarkupElementRange rangeWithStart:pos
                                                                      end:pos]];
        }else{
            [self setSelectedTextRange:
             [MarkupElementRange rangeWithStart:markedTextRange_.endPosition
                                            end:markedTextRange_.endPosition]];
        }
    }else{
        if(pos == nil){
            [self setSelectedTextRange:
             [MarkupElementRange rangeWithStart:markedTextRange_.endPosition
                                            end:markedTextRange_.endPosition]];
        }
        if([pos compareTo:markedTextRange_.startPosition] == NSOrderedAscending){
            pos = markedTextRange_.startPosition;
        }
        if([pos compareTo:markedTextRange_.endPosition] == NSOrderedDescending){
            pos = markedTextRange_.endPosition;
        }
        [self setSelectedTextRange:[MarkupElementRange rangeWithStart:pos
                                                                  end:pos]];
        /*
         //ここのコードは効かない
         //日本語入力後、変換区分の選択方法は不明
        NSInteger first = [self indexFromPosition:markedTextRange_.startPosition];
        NSInteger index = [self indexFromPosition:pos];
        
        [self setMarkedText:[self textInRange:markedTextRange_]
              selectedRange:NSMakeRange(index - first, 0)];
         */
    }
}

- (void)setSpecificFont:(UIFont *)specificFont
{
    if(specificFont_ != specificFont){
        [specificFont_ release];
        specificFont_ = [specificFont retain];
        [self syncCaretViewFrame];
    }
}

- (void)clear{
    [elements_ removeAllObjects];
    [self setSelectedTextRange:[MarkupElementRange rangeWithStart:self.beginPosition end:self.beginPosition]];
    [self setMarkedTextRange:nil];
    [self layout];
    [self syncCaretViewFrame];
    [self setNeedsDisplay];
}


@end

