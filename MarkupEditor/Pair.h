//
//  Pair.h
//  CustomTextInputText
//
//  Created by shimizu on 11/03/10.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Pair : NSObject {
@private
    id first_;
    id second_;
}
@property (nonatomic, retain) id first;
@property (nonatomic, retain) id second;

- (id)init;
- (id)initWithFirst:(id)first second:(id)second;

+ (id)pair;
+ (id)pairWithFirst:(id)first second:(id)second;
@end


