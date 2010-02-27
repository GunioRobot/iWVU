//
//  NSString+MD5.h
//  iWVU
//
//  Created by Jared Crawford on 2/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (md5)

+ (NSString *) md5:(NSString *)str;
+ (NSString *)urlEncodeValue:(NSString *)str;
@end

