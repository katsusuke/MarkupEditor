//
//  AlertDelegator.m
//  ProjectTemplate
//
//  Created by shimizu on 10/12/17.
//  Copyright 2010 MK System. All rights reserved.
//

#import "AlertDelegator.h"

static AlertDelegator* theAlertDelegator = nil;

void ShowAlert(NSString* title, NSString* message)
{
	UIAlertView* alert
	= [[UIAlertView alloc]initWithTitle:title
								message:message
							   delegate:nil
					  cancelButtonTitle:@"OK"
					  otherButtonTitles:nil];
	[alert show];
	[alert release];
}

void ShowAlertWithTarget(NSString* title, NSString* message, id target, SEL selector)
{
	AlertDelegator* ad = [AlertDelegator sharedDelegator];
	ad.function = [[[TargetActionPair alloc]initWithTarget:target action:selector]autorelease];
	UIAlertView* av = [[[UIAlertView alloc]initWithTitle:title
												 message:message
												delegate:ad
									   cancelButtonTitle:@"OK"
									   otherButtonTitles:nil]autorelease];
	[av show];
}

@implementation AlertDelegator
@synthesize function=function_;
+(AlertDelegator*)sharedDelegator{
	if(!theAlertDelegator){
		theAlertDelegator = [[AlertDelegator alloc]init];
		UIApplication *app = [UIApplication sharedApplication];
		[[NSNotificationCenter defaultCenter]addObserver:[AlertDelegator class]
												selector:@selector(releaseSharedDelegator)
													name:UIApplicationWillTerminateNotification
												  object:app];
		
	}
	return theAlertDelegator;
}
+ (void)releaseSharedDelegator{
	[theAlertDelegator release];
	theAlertDelegator = nil;
}
- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex
{
	[function_ fire:self];
	[function_ release];
	function_ = nil;
}
@end
