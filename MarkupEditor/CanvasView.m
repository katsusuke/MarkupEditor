//
//  CanvasView.m
//  iPainter
//
//  Created by Ohta Takashi on 11/12/05.
//  Copyright (c) 2011 MK System Co., Ltd. All rights reserved.
//

#import "CanvasView.h"

@implementation CanvasView

@synthesize delegate=_delegate;
@synthesize penColor=_penColor;
@synthesize penWidth=_penWidth;
@synthesize eraseMode=_eraseMode;


CGContextRef createCanvasContext(int width, int height)
{
	//	RGBの描画領域作成。
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate(
												 NULL,		//	初期化用データ。NULLなら初期化はシステムに任せる
												 width,		//	画像横ピクセル数
												 height,		//	　　縦
												 8,			//	RGB各要素は8ビット
												 0,			//	横１ラインの画像を定義するのに必要なバイト数。0はシステムに任せる。
												 colorSpace, //	RGB色空間。
												 kCGImageAlphaPremultipliedLast);	//	RGBの後ろにアルファ値。
	//	RGBはアルファ値が適用済み。
	//	この時点で色情報は不要なので解放。
    CGColorSpaceRelease(colorSpace);
	return context;	
}


-(id)initWithFrame:(CGRect)frame{
	self = [super initWithFrame:frame];
	if (self) {
		
		_undoImage = [[NSMutableArray alloc] initWithCapacity:10];
		_redoImage = [[NSMutableArray alloc] initWithCapacity:10];
		
		//タッチの可否
		self.userInteractionEnabled = YES;
		_canvasContext = createCanvasContext(frame.size.width, frame.size.height);
		//描画用キャンバスは透明
		CGContextSetRGBFillColor(_canvasContext, 1.0, 1.0, 1.0, 0.0);
		CGContextFillRect(_canvasContext, CGRectMake(0, 0, frame.size.width, frame.size.height));
		_lastImage = CGBitmapContextCreateImage(_canvasContext);
		
		CGImageRef image = CGBitmapContextCreateImage(_canvasContext); 
		[_undoImage addObject:(id)image];
		CGImageRelease(image);
		
		self.opaque = YES;
		self.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f];

	}
	return self;
}


- (void)dealloc {
    
	[_undoImage release];
	[_redoImage release];
	CGImageRelease(_lastImage);
	CGContextRelease(_canvasContext);	//	解放
    [super dealloc];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
	CGContextRef context = UIGraphicsGetCurrentContext() ;
	CGImageRef imgRef = CGBitmapContextCreateImage(_canvasContext);
	CGRect r = self.bounds;
	CGContextDrawImage(context, CGRectMake(0, 0, r.size.width, r.size.height), imgRef); 
	CGImageRelease(imgRef);
}


// 画面に指をタッチしたとき
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//	LOG(@"touchesBegan --------------------------\n");
	
	if (_mode == mode_Released) {		//	指が放された状態からのイベント
		//	ここではmodeを判定しない。判定するべき時間とクリック位置を記憶。
		_mode = mode_WaitingJudge;
		_pickTouch = [touches anyObject];
		_pickPos = [_pickTouch locationInView:_pickTouch.window];	//	自分のviewはスケーリングされるので、判定用には使えない。
		_lineStartPos = [_pickTouch locationInView:self];		//	こちらは線、描画用に保存。
		
		int c = [[event allTouches] count];					//	現在追跡中のタッチイベントの数が、触れている指の数。
		if (c == 2) {										//	ここで判定しないとピンチが取りこぼされるときがある。
			_mode = mode_Void;
		}
	}
	
}

// 画面に指がタッチされた状態で動かしているとき
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	
//	LOG(@"touchesMoved %lf\n", event.timestamp);

	UITouch *touch = nil;
	if (_pickTouch) {
		touch = [touches member:_pickTouch];
	}
	if (touch == nil) {										//	対象の指は動いていない。
		return;
	}
	if (_mode == mode_WaitingJudge) {						//	判定待ち
		LOG(@"mode == mode_WaitingJudge\n");
		CGPoint pos = [touch locationInView:touch.window];	//	自分のviewはスケーリングされるので、判定用には使えない。
		if ((fabs(_pickPos.x - pos.x) > 2) || (fabs(_pickPos.y - pos.y) > 2)) {
			//	判定する。
			int c = [[event allTouches] count];				//	現在追跡中のタッチイベントの数が、触れている指の数。
			_mode = mode_Void;
			if (c == 1)
				_mode = self.eraseMode?mode_Eraser:mode_Pen;
			else if (c == 3)
				_mode = mode_Eraser;
			LOG(@"Judge c = %d mode = %d\n", c, _mode);

		}
		if ((_mode == mode_Pen) || (_mode == mode_Eraser)) {
			CGImageRelease(_lastImage);
			_lastImage = CGBitmapContextCreateImage(_canvasContext);
			
			CGImageRef currentImage =  CGBitmapContextCreateImage(_canvasContext);
			//履歴が10件を超えたら、一番古い履歴を削除する
			if ([_undoImage count] > 9 ) {
				[_undoImage removeObjectAtIndex:0];
			}
			[_undoImage addObject:(id)currentImage];
			CGImageRelease(currentImage);
			
		}
	}
	if ((_mode == mode_Pen) || (_mode == mode_Eraser)) {
		CGPoint lineEndPos = [touch locationInView:self];
		CGContextMoveToPoint(_canvasContext, _lineStartPos.x, _lineStartPos.y);
		CGContextAddLineToPoint(_canvasContext, lineEndPos.x, lineEndPos.y);
		// ラインの端の処理を、丸になるよう指示する。
		CGContextSetLineCap(_canvasContext, kCGLineCapRound);
		// 線の太さを指定	
		CGContextSetLineWidth(_canvasContext, self.penWidth * 2);
		if (_mode == mode_Eraser) {			
			//	消しゴムではkCGBlendModeCopyで完全に置き換える。
			LOG(@"消しゴム");
			CGContextSetBlendMode(_canvasContext, kCGBlendModeClear);
		} else {
			LOG(@"鉛筆");
			CGContextSetBlendMode(_canvasContext, kCGBlendModeDarken);
			// 線の色を指定（RGB）	
			const CGFloat *components = CGColorGetComponents(self.penColor.CGColor);
			CGContextSetRGBStrokeColor(_canvasContext, components[0], components[1], components[2], 0.8);
		}
		CGContextStrokePath(_canvasContext);	
		_lineStartPos = lineEndPos;
		[self setNeedsDisplay];
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	LOG(@"touchesMoved %lf\n", event.timestamp);
	if (_pickTouch && ([touches member:_pickTouch] != nil)) {
		_pickTouch = nil;
	}
	if ([[event allTouches] count] == [touches count]) {
		_mode = mode_Released;
	}
}


-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	LOG(@"touchesCancelled %lf\n", event.timestamp);
	_pickTouch = nil;
	_mode = mode_Released;
}

-(void)undo {

	if ([_undoImage count] == 0) {
		return;
	}
	
	CGImageRef currentImage =  CGBitmapContextCreateImage(_canvasContext);
	
	id tmp = [_undoImage lastObject];
	CGImageRef lastImage = (CGImageRef)tmp;
	CGContextSetBlendMode(_canvasContext, kCGBlendModeCopy);
	CGContextDrawImage(_canvasContext, self.bounds, lastImage);
	
	if ([_redoImage count] > 9) {
		[_redoImage removeObjectAtIndex:0];
	}
	[_redoImage	addObject:(id)currentImage];
	CGImageRelease(currentImage);
	
	[_undoImage removeObject:tmp];
	[self setNeedsDisplay];
}

-(void)redo {
	if ([_redoImage count] == 0) {
		return;
	}

	CGImageRef currentImage =  CGBitmapContextCreateImage(_canvasContext);
	
	id tmp = [_redoImage lastObject];
	CGImageRef lastImage = (CGImageRef)tmp;
	CGContextSetBlendMode(_canvasContext, kCGBlendModeCopy);
	CGContextDrawImage(_canvasContext, self.bounds, lastImage);
	
	if ([_undoImage count] > 9) {
		[_undoImage removeObjectAtIndex:0];
	}
	[_undoImage	addObject:(id)currentImage];	
	CGImageRelease(currentImage);
	
	[_redoImage removeObject:tmp];
	[self setNeedsDisplay];	
}

-(UIImage*)getImage {
	CGImageRef imgRef = CGBitmapContextCreateImage(_canvasContext);
	CGContextRef tmpContext = createCanvasContext(self.bounds.size.width, self.bounds.size.height);
	CGContextScaleCTM(tmpContext, 1, -1);
	CGContextTranslateCTM(tmpContext, 0, -self.bounds.size.height);
	CGContextDrawImage(tmpContext, self.bounds, imgRef);
	CGImageRelease(imgRef);
	imgRef = CGBitmapContextCreateImage(tmpContext);
	UIImage* image = [UIImage imageWithCGImage:imgRef];
	CGImageRelease(imgRef);
	return image;
}

@end
