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
-(instancetype) initFromXMLContent:(NSDictionary *)xmlData
{
    self = [super init];
    
    NSDictionary *obj = [SSXMLLibUtil dictionaryFromNodeArray:xmlData];
    
    _displayName = obj[@"displayName"];
    _dsid = obj[@"dsid"];
    _contents = [NSURL URLWithString:obj[@"contents"]];
    _files = [NSURL URLWithString:obj[@"files"]];
    
    return self;
}

-(NSString *) description
{
    return [NSString stringWithFormat:@"SugarSyncAlbum\n==============\ndisplayName :%@\ndsid        :%@\ncontents    :%@\nfiles       :%@\n==============", _displayName, _dsid, _contents, _files];
}

#pragma mark Deallocation

@end
