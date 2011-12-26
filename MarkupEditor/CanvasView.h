//
//  CanvasView.h
//  iPainter
//
//  Created by Ohta Takashi on 11/12/05.
//  Copyright (c) 2011 MK System Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol CanvasViewDelegate

@optional
//-(void)undoCanvas;
//-(void)redoCanvas;
//-(void)historyClear;

@end

enum {
	mode_Released = 0,	//	指が放された
	mode_WaitingJudge,	//	判定待ち
	mode_Void,			//	機能しない
	mode_Pen,			//	ペン
	mode_Eraser			//	消しゴム
};

@interface CanvasView : UIView {

	
	id<CanvasViewDelegate,NSObject>	_delegate;
	
	CGContextRef _canvasContext;	//	絵を書き込む仮想キャンバス
	CGPoint		_lineStartPos;	//	タッチイベントで更新される次の線を引くためのcanvasContext上の開始位置。

	int	_mode;			//	mode_Void〜mode_Eraserの値をとる。
	CGPoint	_pickPos;		//	touchesBeganで保存する起点座標。
	UITouch *_pickTouch;		//	touchesBeganで保存する起点座標を持つUITouchインスタンス。	
	
	
//	CGPoint _touchPoint;	// タッチした座標
	
	
	
	UIColor *_penColor;		//	ペンの色
	double _penWidth;		//	ペンの幅
	BOOL _eraseMode;		//	消しゴムにする場合YES
	CGImageRef _lastImage;
	
	NSMutableArray *_undoImage;
	NSMutableArray *_redoImage;
}

@property (nonatomic, retain) id<CanvasViewDelegate,NSObject> delegate;
@property (nonatomic, retain) UIColor* penColor;
@property (nonatomic, assign) double penWidth;
@property (nonatomic, assign) BOOL eraseMode;

-(void)undo;
-(void)redo;
-(UIImage*)getImage;
@end
