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

@interface GraphicalTextView()

- (void)syncCaretViewFrame;

@end

@implementation GraphicalTextView

@synthesize selectedTextRange=selectedTextRange_;
@synthesize markedTextRange=markedTextRange_;
@synthesize markedTextStyle=markedTextStyle_;
@synthesize inputDelegate=inputDelegate_;
@synthesize tokenizer=inputTokenizer_;

- (id)preInit_{
    document_ = [[MarkupDocument alloc]init];
    [document_ setTestData];
    selectedTextRange_ = [[MarkupElementRange alloc]initWithStart:document_.endPosition
                                                              end:document_.endPosition];
    markedTextRange_ = nil;
    cartView_ = [[CaretView alloc]initWithFrame:CGRectZero];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
        self = [self preInit_];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self = [self preInit_];
    }
    return self;
}

- (void)dealloc {
	[document_ release];
    [cartView_ release];
    [super dealloc];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
	[document_ drawRect:rect width:self.frame.size.width];
}

- (UIView*)inputView{
    if(inputTextMode_ == InputTextModeQwerty){
        return [super inputView];
    }else{
        HandWritingInputView* view
        = [[[HandWritingInputView alloc]initWithGraphicalTextView:self]autorelease];
        view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        return view;
    }
}

- (InputTextMode)inputTextMode{
    return inputTextMode_;
}
- (void)setInputTextMode:(InputTextMode)newValue
{
    inputTextMode_ = newValue;
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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self becomeFirstResponder];
}


- (BOOL)hasText
{
    return YES;
}
- (void)addHandWritingPoints:(NSArray *)array
{
    [document_ replaceRange:selectedTextRange_
        withHandWritePoints:array];
    [selectedTextRange_ release];
    selectedTextRange_ = [[MarkupElementRange alloc]initWithStart:document_.endPosition
                                                              end:document_.endPosition];
    [self setNeedsDisplay];
    [self syncCaretViewFrame];
}
- (void)insertText:(NSString *)text
{
    LOG(@"text:%@", text);
    PO(text);
    [document_ replaceRange:selectedTextRange_ withText:text];
    PO(selectedTextRange_);
    [selectedTextRange_ release];
    selectedTextRange_ = [[MarkupElementRange alloc]initWithStart:document_.endPosition
                                                              end:document_.endPosition];
    PO(selectedTextRange_);
    [self setNeedsDisplay];
    [self syncCaretViewFrame];
}
- (void)deleteBackward
{
    LOG(@"");
    MarkupElementPosition* start
    = [document_ positionFromPosition:selectedTextRange_.startPosition
                               offset:-1];
    [document_ deleteWithRange:
     [MarkupElementRange rangeWithStart:start
                                    end:selectedTextRange_.endPosition]];
    [selectedTextRange_ release];
    selectedTextRange_ = [[MarkupElementRange alloc]initWithStart:document_.endPosition
                                                              end:document_.endPosition];
    [self setNeedsDisplay];
    [self syncCaretViewFrame];
}

- (void)setFrame:(CGRect)frame
{
    RECTLOG(frame);
    [super setFrame:frame];
    [document_ layoutWithWidth:frame.size.width];
    [self setNeedsDisplay];
}

- (NSString*)textInRange:(UITextRange *)range
{
	return [document_ textInRange:(MarkupElementRange*)range];
}

- (void)replaceRange:(UITextRange *)range withText:(NSString *)text
{
    [document_ replaceRange:(MarkupElementRange*)range withText:text];
}

- (void)setMarkedTextRange:(UITextRange*)range
{
    if(markedTextRange_ != range){
        [markedTextRange_ release];
        markedTextRange_ = [(MarkupElementRange*)range retain];
    }
}

- (void)setMarkedText:(NSString *)markedText selectedRange:(NSRange)selectedRange
{
    T(@"markedText:%@ selectedRange:(location:%d length:%d)",
      markedText, selectedRange.location, selectedRange.length);
    
    if (markedTextRange_){
        if (!markedText){ 
            markedText = @"";// nilが来ることある
        }
		// Replace characters in text storage and update markedText range length
        [document_ replaceRange:markedTextRange_ withText:markedText marked:YES];
        [self setMarkedTextRange:
         [self textRangeFromPosition:markedTextRange_.startPosition
                          toPosition:[self positionFromPosition:markedTextRange_.startPosition
                                                                               offset:markedText.length]]];
    } else{
		// There currently isn't a marked text range, but there is a selected range,
		// so replace text storage at selected range and update markedTextRange.
        [document_ replaceRange:selectedTextRange_ withText:markedText marked:YES];
        [self setMarkedTextRange:[self textRangeFromPosition:selectedTextRange_.startPosition
                                                  toPosition:[self positionFromPosition:selectedTextRange_.startPosition
                                                                                 offset:markedText.length]]];
    }    
	// Updated selected text range and underlying SimpleCoreTextView
    [self setSelectedTextRange:[self textRangeFromPosition:markedTextRange_.endPosition
                                                toPosition:markedTextRange_.endPosition]];	
    [self setNeedsDisplay];
    [self syncCaretViewFrame];
}

- (void)unmarkText
{
    if(!markedTextRange_)return;
    
    [document_ unmarkTextWithRange:markedTextRange_];
    
    [self setMarkedTextRange:nil];
    [self setNeedsDisplay];
    [self syncCaretViewFrame];
}

- (UITextPosition*)beginningOfDocument{
    return document_.startPosition;
}

- (UITextPosition*)endOfDocument{
    return document_.endPosition;
}

- (UITextRange*)textRangeFromPosition:(UITextPosition *)fromPosition
                           toPosition:(UITextPosition *)toPosition
{
    return [[[MarkupElementRange alloc]initWithStart:(MarkupElementPosition*)fromPosition
                                                 end:(MarkupElementPosition*)toPosition]autorelease];
}

- (UITextPosition*)positionFromPosition:(UITextPosition *)position offset:(NSInteger)offset
{
    return [document_ positionFromPosition:(MarkupElementPosition*)position offset:offset];
}

//ソフトキーボードには無いけど、上下左右キーが押されたときに呼ばれる。
//エディタ的に、左端からn 文字目に移動することにする
//改行は無視する
- (UITextPosition *)positionFromPosition:(UITextPosition *)position
                             inDirection:(UITextLayoutDirection)direction
                                  offset:(NSInteger)offset
{
    PO(position);
    PO(direction);
    P(@"%d", offset);
    NSInteger toOffset = offset;
    switch (direction) {
        case UITextLayoutDirectionLeft:
            toOffset = -offset;
        case UITextLayoutDirectionRight:
            return [self positionFromPosition:position offset:toOffset];
        case UITextLayoutDirectionUp:
            toOffset = -offset;
        case UITextLayoutDirectionDown:
            return [document_ positionDownFromPosition:(MarkupElementPosition*)position lines:toOffset];
    }
}

- (NSInteger)offsetFromPosition:(UITextPosition *)from toPosition:(UITextPosition *)toPosition
{
    return [document_ offsetFrom:(MarkupElementPosition*)from to:(MarkupElementPosition*)toPosition];
}

- (NSComparisonResult)comparePosition:(UITextPosition *)position toPosition:(UITextPosition *)other
{
    return [(MarkupElementPosition*)position compareTo:(MarkupElementPosition*)other];
}

// UITextInput protocol method - Return the text position that is at the farthest 
// extent in a given layout direction within a range of text.
- (UITextPosition *)positionWithinRange:(UITextRange *)range
                    farthestInDirection:(UITextLayoutDirection)direction
{
    PO(range);
    P(@"%d", direction);
}
- (UITextRange *)characterRangeByExtendingPosition:(UITextPosition *)position
                                       inDirection:(UITextLayoutDirection)direction
{
    PO(position);
    P(@"%d", direction);
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

/* Geometry used to provide, for example, a correction rect. */
- (CGRect)firstRectForRange:(UITextRange *)range
{
    PO(range);
    CGRect r0 = [document_ caretRectForPosition:(MarkupElementPosition*)range.start
                                          width:self.frame.size.width];
    CGRect r1 = [document_ caretRectForPosition:(MarkupElementPosition*)range.end
                                          width:self.frame.size.width];
    RECTLOG(r0);
    RECTLOG(r1);
    r0.size.width = 30;
    return r0;
}

- (CGRect)caretRectForPosition:(UITextPosition *)position
{
    CGRect rect
    = [document_ caretRectForPosition:(MarkupElementPosition*)position
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


@end

