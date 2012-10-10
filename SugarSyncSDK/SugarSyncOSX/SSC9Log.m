//
//  C9Log.m
//
//  Created by Bill Culp on 10/28/10.
//  Copyright Cloud9 All rights reserved
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.

#import "SSC9Log.h"

@implementation SSC9Log

+(void) log:(NSString *) aMessage withError:(NSError *)anError
{
    
    
}

+(void) log:(NSString *) aMessage withException:(NSException *)anException;
{
    
}

+(void) log:(NSString *) aMessage
{
    NSArray *stack = [NSThread callStackSymbols];
    
    if ( stack.count < 2 )
    {
        [NSException raise:@"The call stack is corrupt!" format:nil];
    }
    
    NSString *methodThatDidLogging = [stack objectAtIndex:1];
    
    NSRange startEnd = [methodThatDidLogging rangeOfString:@"["];
    
    if ( !startEnd.length )
    {
        startEnd = [methodThatDidLogging rangeOfString:@"block"];
        if ( startEnd.length )
        {
            methodThatDidLogging = @"(block)";
        }
    } else {
        if (startEnd.length)
        {
            methodThatDidLogging = [methodThatDidLogging substringFromIndex:startEnd.location];
        }
    }
    
    NSLog(@"%@ - %@", methodThatDidLogging, aMessage);
    
}

+(void) format:(NSString *) aMessage, ...
{
    va_list args;
    va_start(args, aMessage);
    
    aMessage = [[NSString alloc] initWithFormat:aMessage arguments:args];
    
    va_end(args);
    
    NSArray *stack = [NSThread callStackSymbols];
    
    if ( stack.count < 2 )
    {
        [NSException raise:@"The call stack is corrupt!" format:nil];
    }
    
    NSString *methodThatDidLogging = [stack objectAtIndex:1];
    
    NSRange startEnd = [methodThatDidLogging rangeOfString:@"["];
    
    if ( !startEnd.length )
    {
        startEnd = [methodThatDidLogging rangeOfString:@"block"];
        if ( startEnd.length )
        {
            methodThatDidLogging = @"(block)";
        }
    } else {
        if (startEnd.length)
        {
            methodThatDidLogging = [methodThatDidLogging substringFromIndex:startEnd.location];
        }
    }
    
    NSLog(@"%@ - %@", methodThatDidLogging, aMessage);
    
    //START SA CHANGE
    [aMessage release];
    //END SA CHANGE
    
    
}

+(void) enter
{
    NSArray *stack = [NSThread callStackSymbols];
    
    if ( stack.count < 2 )
    {
        [NSException raise:@"The call stack is corrupt!" format:nil];
    }
    
    NSString *methodThatDidLogging = [stack objectAtIndex:1];
    
    NSRange startEnd = [methodThatDidLogging rangeOfString:@"["];
    
    methodThatDidLogging = [methodThatDidLogging substringFromIndex:startEnd.location];
    
    NSLog(@"%@ (enter)", methodThatDidLogging);
    
    
}

+(void) exit
{
    NSArray *stack = [NSThread callStackSymbols];
    
    if ( stack.count < 2 )
    {
        [NSException raise:@"The call stack is corrupt!" format:nil];
    }
    
    NSString *methodThatDidLogging = [stack objectAtIndex:1];
    
    NSRange startEnd = [methodThatDidLogging rangeOfString:@"["];
    
    methodThatDidLogging = [methodThatDidLogging substringFromIndex:startEnd.location];
    
    NSLog(@"%@ (exit)", methodThatDidLogging);
    
    
}

@end
