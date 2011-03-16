//
//  Tools.h
//  CustomTextInputText
//
//  Created by shimizu on 10/02/12.
//  Copyright 2010 MK System. All rights reserved.
//

#import <Foundation/Foundation.h>

extern CGRect OutsideRect(CGRect r1, CGRect r2);
extern NSString* DocumentDirectory();
extern NSString* AppDirectory();

@interface NSDictionary(XMLDescription)
- (NSString*)xmlDescription;
@end

@interface NSFileManager(overwriteCopy)
//デフォルトの copyItemAtPath:toPath:error: はtoPath にファイルが存在すると
//上書きをせずにファイルエラーを返すので、上書きをしてくれるバージョン
//スレッドセーフじゃないので注意が必要
- (BOOL)overwriteCopyItemAtPath:(NSString*)srcPath
						 toPath:(NSString*)toPath
						  error:(NSError**)error;
@end
