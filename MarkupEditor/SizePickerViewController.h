//
//  SizePickerViewController.h
//  MarkupEditor
//
//  Created by  on 11/12/20.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SizePickerViewController : UIViewController<UIPickerViewDelegate>{
    NSArray* sizes_;
    IBOutlet UIPickerView* pickerView;
}
@property (retain, nonatomic) NSArray* sizes;

- (void)selectRow:(NSInteger)row;
- (void)reloadAllComponents;

@property (readonly, nonatomic) CGFloat size;

@end
