//
//  ErrorUtil.m
//
//  Created by Bill Culp on 8/10/12.
//  Copyright (c) 2012 Cloud9. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.


#import "SSErrorUtil.h"

@implementation SSErrorUtil


+(NSError *) errorWithDomain:(NSString *)aDomain code:(long)aCode description:(NSString *)aDescription
{
    NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
    [errorDetail setValue:aDescription forKey:NSLocalizedDescriptionKey];
    return [[[NSError alloc] initWithDomain:aDomain code:aCode userInfo:errorDetail] autorelease];
    
}

+(NSError *) errorWithDomain:(NSString *)aDomain code:(long)aCode description:(NSString *)aDescription reason:(NSString *)aReason
{
    NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
    [errorDetail setValue:aDescription forKey:NSLocalizedDescriptionKey];
    [errorDetail setValue:aReason forKey:NSLocalizedFailureReasonErrorKey];
    return [[[NSError alloc] initWithDomain:aDomain code:aCode userInfo:errorDetail] autorelease];
    
}
@end
