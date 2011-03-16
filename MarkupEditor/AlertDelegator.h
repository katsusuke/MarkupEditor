//
//  AlertDelegator.h
//  ProjectTemplate
//
//  Created by shimizu on 10/12/17.
//  Copyright 2010 MK System. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TargetActionPair.h"

extern void ShowAlert(NSString* title, NSString* message);
extern void ShowAlertWithTarget(NSString* title, NSString* message, id target, SEL selector);

@interface AlertDelegator : NSObject {
	TargetActionPair* function_;
}
+ (AlertDelegator*)sharedDelegator;
+ (void)releaseSharedDelegator;
@property (nonatomic, retain)TargetActionPair* function;

@end
