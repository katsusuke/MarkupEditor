//
//  ColorPickupViewController.h
//  MarkupEditor
//
//  Created by  on 11/12/19.
//  Copyright 2011 MK System. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ColorPickupViewControllerDelegate;

@interface ColorPickupViewController : UIViewController{
    IBOutlet UIImageView* imageView;
    UIColor* color_;
    NSMutableArray* colors_;
    UIImageView* ring_;
    id<ColorPickupViewControllerDelegate> delegate_;
}

-(IBAction)handleSingleTap:(id)sender;

- (void)setSimilarColor:(UIColor*)color;

@property (retain, nonatomic) UIColor* color;
@property (readonly, nonatomic) NSArray* colors;
@property (assign, nonatomic) id<ColorPickupViewControllerDelegate> delegate;

@end


@protocol ColorPickupViewControllerDelegate <NSObject>

- (void)colorPickupViewController:(ColorPickupViewController*)viewController
                    didSelectedColor:(UIColor*)color;

@end