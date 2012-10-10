//
//  SugarSyncAlbum.m
//
//  Created by Bill Culp on 8/28/12.
//  Copyright (c) 2012 Cloud9. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.

#import "SugarSyncAlbum.h"
#import "SSXMLLibUtil.h"

@implementation SugarSyncAlbum

#pragma mark Initialization
-(id) initFromXMLContent:(NSDictionary *)xmlData
{
    self = [super init];
    
    NSDictionary *obj = [SSXMLLibUtil dictionaryFromNodeArray:xmlData];
    
    _displayName = [[obj objectForKey:@"displayName"] retain];
    _dsid = [[obj objectForKey:@"dsid"] retain];
    _contents = [[NSURL URLWithString:[obj objectForKey:@"contents"]] retain];
    _files = [[NSURL URLWithString:[obj objectForKey:@"files"]] retain];
    
    return self;
}

-(NSString *) description
{
    return [NSString stringWithFormat:@"SugarSyncAlbum\n==============\ndisplayName :%@\ndsid        :%@\ncontents    :%@\nfiles       :%@\n==============", _displayName, _dsid, _contents, _files];
}

#pragma mark Deallocation
-(void) dealloc
{
    [_displayName release];
    _displayName = nil;
    
    [_dsid release];
    _dsid = nil;
    
    [_contents release];
    _contents = nil;
    
    [_files release];
    _files = nil;
    
    [super dealloc];
}

@end
