//
//  GraphicalTextView.m
//  CustomTextInputText
//
//  Created by shimizu on 11/02/21.
//  Copyright 2011 MK System. All rights reserved.
//

#import "GraphicalTextView.h"
#import "MarkupElementPosition.h"

@implementation GraphicalTextView

@synthesize selectedTextRange=selectedTextRange_;
@synthesize markedTextRange=markedTextRange_;
@synthesize markedTextStyle=markedTextStyle_;
@synthesize inputDelegate=inputDelegate_;
@synthesize tokenizer=inputTokenizer_;

- (id)preInit_{
    document_ = [[MarkupDocument alloc]init];
    [document_ setTestData];
    self.backgroundColor = [UIColor whiteColor];
    selectedTextRange_ = [[MarkupElementRange alloc]initWithStart:document_.endPosition
                                                              end:document_.endPosition];
    markedTextRange_ = [[MarkupElementRange alloc]initWithStart:document_.endPosition
                                                            end:document_.endPosition];
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
    [super dealloc];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
	[document_ drawRect:rect width:self.frame.size.width];
}

- (BOOL)canBecomeFirstResponder;
{ 
	return YES;
}

- (BOOL)hasText
{
    return YES;
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
    selectedTextRange_ = [MarkupElementRange rangeWithStart:start end:start];
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

- (void)setMarkedText:(NSString *)markedText selectedRange:(NSRange)selectedRange
{
    LOG(@"markedText:%@ selectedRange:(location:%d length:%d",
        markedText, selectedRange.location, selectedRange.length);
}
- (void)unmarkText
{
    
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
- (UITextPosition *)positionFromPosition:(UITextPosition *)position
                             inDirection:(UITextLayoutDirection)direction
                                  offset:(NSInteger)offset
{
    
}

- (NSInteger)offsetFromPosition:(UITextPosition *)from toPosition:(UITextPosition *)toPosition
{
    return [document_ offsetFrom:(MarkupElementPosition*)from to:(MarkupElementPosition*)toPosition];
}

- (NSComparisonResult)comparePosition:(UITextPosition *)position toPosition:(UITextPosition *)other
{
    return [(MarkupElementPosition*)position compareTo:(MarkupElementPosition*)other];
}

- (UITextPosition *)positionWithinRange:(UITextRange *)range
                    farthestInDirection:(UITextLayoutDirection)direction
{
    
}
- (UITextRange *)characterRangeByExtendingPosition:(UITextPosition *)position
                                       inDirection:(UITextLayoutDirection)direction
{
    
}

/* Writing direction */
- (UITextWritingDirection)baseWritingDirectionForPosition:(UITextPosition *)position
                                              inDirection:(UITextStorageDirection)direction
{
    
}
- (void)setBaseWritingDirection:(UITextWritingDirection)writingDirection
                       forRange:(UITextRange *)range
{
    
}

/* Geometry used to provide, for example, a correction rect. */
- (CGRect)firstRectForRange:(UITextRange *)range
{
    
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
- (UITextPosition *)closestPositionToPoint:(CGPoint)point
{
    
}
- (UITextPosition *)closestPositionToPoint:(CGPoint)point
                               withinRange:(UITextRange *)range
{
    
}
- (UITextRange *)characterRangeAtPoint:(CGPoint)point
{
    
}


@end

