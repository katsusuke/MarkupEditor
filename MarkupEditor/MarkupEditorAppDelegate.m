//
//  MarkupEditorAppDelegate.m
//  MarkupEditor
//
//  Created by shimizu on 11/03/15.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MarkupEditorAppDelegate.h"
#import "RootViewController.h"

#include <execinfo.h>
//#include <exception>
static NSString *GBug;

@implementation MarkupEditorAppDelegate


@synthesize window=_window;

@synthesize navigationController=_navigationController;

static NSString *GetBugReport()
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *dir = [paths objectAtIndex:0];
	return [dir stringByAppendingPathComponent:@"bug.txt"];
}
static void UncaughtExceptionHandler(NSException *exception)
{
	/*
	 *	Extract the call stack
	 */
    
	NSArray *callStack = [exception callStackReturnAddresses];
	int i,len = [callStack count];
	void **frames = malloc(sizeof(void*) * len);
    
	for (i = 0; i < len; ++i) {
		frames[i] = (void *)[[callStack objectAtIndex:i] unsignedIntegerValue];
	}
	char **symbols = backtrace_symbols(frames,len);
    
	/*
	 *	Now format into a message for sending to the user
	 */
    
	NSMutableString *buffer = [[NSMutableString alloc] initWithCapacity:4096];
    
	NSBundle *bundle = [NSBundle mainBundle];
	[buffer appendFormat:@"PComp version %@ build %@\n\n",
     [bundle objectForInfoDictionaryKey:@"CFBundleVersion"],
     [bundle objectForInfoDictionaryKey:@"CIMBuildNumber"]];
	[buffer appendString:@"Uncaught Exception\n"];
	[buffer appendFormat:@"Exception Name: %@\n",[exception name]];
	[buffer appendFormat:@"Exception Reason: %@\n",[exception reason]];
	[buffer appendString:@"Stack trace:\n\n"];
	for (i = 0; i < len; ++i) {
		[buffer appendFormat:@"%4d - %s\n",i,symbols[i]];
	}
    
	/*
	 *	Get the error file to write this to
	 */
    
	NSError *err;
	[buffer writeToFile:GetBugReport() atomically:YES encoding:NSUTF8StringEncoding error:&err];
	NSLog(@"Error %@",buffer);
	exit(0);
}
void SignalHandler(int sig, siginfo_t *info, void *context)
{
	void *frames[128];
	int i,len = backtrace(frames, 128);
	char **symbols = backtrace_symbols(frames,len);
    
	/*
	 *	Now format into a message for sending to the user
	 */
    
	NSMutableString *buffer = [[NSMutableString alloc] initWithCapacity:4096];
    
	NSBundle *bundle = [NSBundle mainBundle];
	[buffer appendFormat:@"PComp version %@ build %@\n\n",
     [bundle objectForInfoDictionaryKey:@"CFBundleVersion"],
     [bundle objectForInfoDictionaryKey:@"CIMBuildNumber"]];
	[buffer appendString:@"Uncaught Signal\n"];
	[buffer appendFormat:@"si_signo    %d\n",info->si_signo];
	[buffer appendFormat:@"si_code     %d\n",info->si_code];
	[buffer appendFormat:@"si_value    %d\n",info->si_value];
	[buffer appendFormat:@"si_errno    %d\n",info->si_errno];
	[buffer appendFormat:@"si_addr     0x%08lX\n",info->si_addr];
	[buffer appendFormat:@"si_status   %d\n",info->si_status];
	[buffer appendString:@"Stack trace:\n\n"];
	for (i = 0; i < len; ++i) {
		[buffer appendFormat:@"%4d - %s\n",i,symbols[i]];
	}
    
	/*
	 *	Get the error file to write this to
	 */
    
	NSError *err;
	[buffer writeToFile:GetBugReport() atomically:YES encoding:NSUTF8StringEncoding error:&err];
	NSLog(@"Error %@",buffer);
	exit(0);
}
/*
void TerminateHandler(void)
{
	void *frames[128];
	int i,len = backtrace(frames, 128);
	char **symbols = backtrace_symbols(frames,len);

    //	Now format into a message for sending to the user
    
	NSMutableString *buffer = [[NSMutableString alloc] initWithCapacity:4096];
    
	NSBundle *bundle = [NSBundle mainBundle];
	[buffer appendFormat:@"PComp version %@ build %@\n\n",
     [bundle objectForInfoDictionaryKey:@"CFBundleVersion"],
     [bundle objectForInfoDictionaryKey:@"CIMBuildNumber"]];
	[buffer appendString:@"Uncaught C++ Exception\n"];
	[buffer appendString:@"Stack trace:\n\n"];
	for (i = 0; i < len; ++i) {
		[buffer appendFormat:@"%4d - %s\n",i,symbols[i]];
	}
    
    //	Get the error file to write this to
    
	NSError *err;
	[buffer writeToFile:GetBugReport() atomically:YES encoding:NSUTF8StringEncoding error:&err];
	NSLog(@"Error %@",buffer);
	exit(0);
}
*/
static void SetupUncaughtSignals()
{
	struct sigaction mySigAction;
	mySigAction.sa_sigaction = SignalHandler;
	mySigAction.sa_flags = SA_SIGINFO;
    
	sigemptyset(&mySigAction.sa_mask);
	sigaction(SIGQUIT, &mySigAction, NULL);
	sigaction(SIGILL, &mySigAction, NULL);
	sigaction(SIGTRAP, &mySigAction, NULL);
	sigaction(SIGABRT, &mySigAction, NULL);
	sigaction(SIGEMT, &mySigAction, NULL);
	sigaction(SIGFPE, &mySigAction, NULL);
	sigaction(SIGBUS, &mySigAction, NULL);
	sigaction(SIGSEGV, &mySigAction, NULL);
	sigaction(SIGSYS, &mySigAction, NULL);
	sigaction(SIGPIPE, &mySigAction, NULL);
	sigaction(SIGALRM, &mySigAction, NULL);
	sigaction(SIGXCPU, &mySigAction, NULL);
	sigaction(SIGXFSZ, &mySigAction, NULL);
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1) {
		/*
		 *	Send an e-mail with the specified title.
		 */
        
		NSMutableString *url = [NSMutableString stringWithCapacity:4096];
		[url appendString:@"mailto:bugs@nowhere.meh?subject=Bug%20Report&body="];
		[url appendString:[GBug stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
	}
    
	[GBug release];
}

- (void)sendBugsIfPresent
{
	NSError *err;
	NSString *path = GetBugReport();
    
	GBug = [[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err] retain];
	if (GBug == nil) return;
	[[NSFileManager defaultManager] removeItemAtPath:path error:&err];
    
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unexpected exception"
                                                    message:@"An unexpected exception was caught the last time this program ran. Send the developer a bug report by e-mail?"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Send Report",nil];
	[alert show];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    // Add the navigation controller's view to the window and display.
    self.window.rootViewController = self.navigationController;
    
    [self.window makeKeyAndVisible];
	
    /* Register for uncaught exceptions, signals */
    NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
	SetupUncaughtSignals();
    //std::set_terminate(TerminateHandler);
    
	[self sendBugsIfPresent];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
    [_window release];
    [_navigationController release];
    [super dealloc];
}

@end
