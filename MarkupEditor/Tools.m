//
//  Tools.m
//  CustomTextInputText
//
//  Created by shimizu on 10/02/12.
//  Copyright 2010 MK System. All rights reserved.
//

#import "Tools.h"
#import "TargetActionPair.h"
#include <stdarg.h>
#include <stdlib.h>


CGRect OutsideRect(CGRect r1, CGRect r2)
{
	CGFloat left, top, right, bottom;
	left = MIN(r1.origin.x, r2.origin.x);
	top = MIN(r1.origin.y, r2.origin.y);
	right = MAX(r1.origin.x + r1.size.width,
				r2.origin.x + r2.size.width);
	bottom = MAX(r1.origin.y + r1.size.height,
				 r2.origin.y + r2.size.height);
	return CGRectMake(left, top, right - left, bottom - top);
}

NSString* DocumentDirectory(){
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	if([paths count] != 0){
		return [paths objectAtIndex:0];
	}
	return nil;
}

NSString* AppDirectory(){
	return [[NSBundle mainBundle]bundlePath];
}


@implementation NSDictionary(XMLDescription)

- (NSString*)xmlDescription
{
    NSData*	xmlData;
    
    xmlData = (NSData*)CFPropertyListCreateXMLData(
												   kCFAllocatorSystemDefault, 
												   (CFPropertyListRef)self);
    
    NSString* res = [[[NSString alloc] 
					  initWithData:xmlData 
					  encoding:NSUTF8StringEncoding]autorelease];
	CFRelease(xmlData);
	return res;
}

@end

@implementation NSFileManager(overwriteCopy)

- (BOOL)overwriteCopyItemAtPath:(NSString*)srcPath
						 toPath:(NSString*)toPath
						  error:(NSError**)error
{
	if(![self fileExistsAtPath:toPath]){
		//toPathにファイルはないので、気にせずコピー
		return [self copyItemAtPath:srcPath toPath:toPath error:error];
	}
	//toPathにファイルが存在するので、tmpに一時移動
	srand(time(NULL));
	NSString* cachesDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
																NSUserDomainMask,
																YES) objectAtIndex:0];
	
	NSString* tmpPath = nil;
	do{
		tmpPath = [cachesDir stringByAppendingPathComponent:
					  [NSString stringWithFormat:
					   @"overwriteCopyTmp%08x", rand()]];
	}
	while([self fileExistsAtPath:tmpPath]);
		
	if(![self moveItemAtPath:toPath toPath:tmpPath error:error]){
		return NO;
	}
	//ほんちゃんの移動
	if(![self copyItemAtPath:srcPath toPath:toPath error:error]){
		//とりあえずダメもとでtmpにコピーしたファイルを戻してみる.
		[self moveItemAtPath:tmpPath toPath:toPath error:NULL];
		return NO;
	}
	//tmpのファイルを削除する。失敗しても気にしない
	[self removeItemAtPath:tmpPath error:NULL];
	return YES;
}


@end
