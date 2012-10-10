//
//  SugarSyncReceivedShare.m
//
//  Created by Bill Culp on 8/27/12.
//  Copyright (c) 2012 Cloud9. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.

#import "SugarSyncReceivedShare.h"
#import "SSXMLLibUtil.h"

@implementation SugarSyncReceivedShare

-(id) initFromXMLContent:(NSDictionary *)xmlData
{
    self = [super init];
    
    NSDictionary *obj = [SSXMLLibUtil dictionaryFromNodeArray:xmlData];
    _displayName = [[obj objectForKey:@"displayName"] retain];
    _timeReceived = [[obj objectForKey:@"timeReceived"] retain];
    _sharedFolder = [[NSURL URLWithString:[obj objectForKey:@"sharedFolder"]] retain];
    
    NSDictionary *permissions = [obj objectForKey:@"permissions"];

    NSDictionary *readAttrs = [permissions objectForKey:@"readAllowed$attributes"];
    _permissionRead = [[readAttrs objectForKey:@"enabled"] isEqualToString:@"true"] ? YES : NO;
    
    NSDictionary *writeAttrs = [permissions objectForKey:@"writeAllowed$attributes"];
    _permissionWrite = [[writeAttrs objectForKey:@"enabled"] isEqualToString:@"true"] ? YES : NO;

    _owner = [[NSURL URLWithString:[obj objectForKey:@"owner"]] retain];
    
    return self;
}

-(NSString *) description
{
    return [NSString stringWithFormat:@"SugarSyncReceivedShare\n==============\ndisplayName  :%@\ntimeReceived :%@\nsharedFolder :%@\ncanRead      :%@\ncanWrite     :%@\nowner        :%@\n==============", _displayName, _timeReceived, _sharedFolder, _permissionRead ? @"YES" :@"NO", _permissionWrite ? @"YES" : @"NO",  _owner];
}

-(void) dealloc
{
    [_displayName release];
    _displayName = nil;
    
    [_timeReceived release];
    _timeReceived = nil;
    
    [_sharedFolder release];
    _sharedFolder = nil;
    
    [_owner release];
    _owner = nil;
    
    [super dealloc];
    
}
@end

