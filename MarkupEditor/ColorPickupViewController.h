//
//  ColorPickupViewController.h
//  MarkupEditor
//
//  Created by  on 11/12/19.
//  Copyright 2011 MK System. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ColorPickupViewController : UIViewController{
    IBOutlet UIImageView* imageView;
    UIColor* color_;
    NSMutableArray* colors_;
    UIImageView* ring_;
}

-(IBAction)handleSingleTap:(id)sender;

- (void)setSimilarColor:(UIColor*)color;

@property (retain, nonatomic) UIColor* color;
@property (readonly, nonatomic) NSArray* colors;

@end
