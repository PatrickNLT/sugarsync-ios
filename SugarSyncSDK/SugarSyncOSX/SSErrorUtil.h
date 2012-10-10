//
//  ErrorUtil.h
//
//  Created by Bill Culp on 8/10/12.
//  Copyright (c) 2012 Cloud9. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.

#import <Foundation/Foundation.h>

@interface SSErrorUtil : NSObject

+(NSError *) errorWithDomain:(NSString *)aDomain code:(long)aCode description:(NSString *)aDescription;
+(NSError *) errorWithDomain:(NSString *)aDomain code:(long)aCode description:(NSString *)aDescription reason:(NSString *)aReason;

@end
