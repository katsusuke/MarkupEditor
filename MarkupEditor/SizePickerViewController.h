//
//  SizePickerViewController.h
//  MarkupEditor
//
//  Created by  on 11/12/20.
//  Copyright 2011 MK System. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SizePickerViewControllerDelegate;

@interface SizePickerViewController : UIViewController<UIPickerViewDelegate>{
    NSArray* sizes_;
    IBOutlet UIPickerView* pickerView;
    id<SizePickerViewControllerDelegate> delegate_;
}
@property (retain, nonatomic) NSArray* sizes;

- (void)selectRow:(NSInteger)row;
- (void)reloadAllComponents;

@property (readonly, nonatomic) CGFloat size;
@property (nonatomic, assign) id<SizePickerViewControllerDelegate> delegate;

@end

@protocol SizePickerViewControllerDelegate <NSObject>

- (void)sizePickerViewController:(SizePickerViewController*)viewController
                   didSelectSize:(CGFloat)size;

@end