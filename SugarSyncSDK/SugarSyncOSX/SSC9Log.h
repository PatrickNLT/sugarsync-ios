//
//  C9Log.h
//
//  A logger which prints out the method being executed
//
//  Created by Bill Culp on 10/28/10.
//  Copyright Cloud9 All rights reserved
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.

#import <Foundation/Foundation.h>

@interface SSC9Log : NSObject

+(void) log:(NSString *) aMessage withError:(NSError *)anError;
+(void) log:(NSString *) aMessage withException:(NSException *)anException;
+(void) log:(NSString *) aMessage;
+(void) format:(NSString *) aMessage, ...;
+(void) enter;
+(void) exit;

@end
