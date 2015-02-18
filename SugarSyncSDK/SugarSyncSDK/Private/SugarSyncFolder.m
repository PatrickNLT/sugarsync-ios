//
//  SugarSyncFolder.m
//
//  Created by Bill Culp on 8/27/12.
//  Copyright (c) 2012 Cloud9. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.


#import "SugarSyncFolder.h"
#import "SSXMLLibUtil.h"

static NSURL *FolderAPI;

@implementation SugarSyncFolder

+(void) initialize
{
    FolderAPI = [[NSURL URLWithString:@"https://api.sugarsync.com/folder/"] retain];
}

-(instancetype) initFromXMLContent:(NSDictionary *)xmlData
{
    self = [super init];

    NSDictionary *obj = [SSXMLLibUtil dictionaryFromNodeArray:xmlData];
    
    _displayName = [obj[@"displayName"] retain];
    _dsid = [obj[@"dsid"] retain];
    _parent = [[NSURL URLWithString:obj[@"parent"]] retain];
    _timeCreated = [obj[@"timeCreated"] retain];
    _collections  = [[NSURL URLWithString:obj[@"collections"]] retain];
    _contents = [[NSURL URLWithString:obj[@"contents"]] retain];
    _files = [[NSURL URLWithString:obj[@"files"]] retain];

    NSDictionary *sharingAttributes = obj[@"sharing$attributes"];
    
    _sharingEnabled = [sharingAttributes[@"enabled"] isEqualToString:@"true"] ? YES : NO;
    
    return self;
}

-(NSURL *) resourceURL
{
    return [FolderAPI URLByAppendingPathComponent:[_dsid stringByReplacingOccurrencesOfString:@"/" withString:@":"]];
}

- (NSDictionary *)XMLParameters
{
    NSString *resource = self.resourceURL.description;
    return @{@"displayName": _displayName,
             @"dsid": _dsid,
             @"timeCreated": _timeCreated,
             @"parent": _parent? _parent : @"",
             @"collections": [resource stringByAppendingString:@"/contents?type=folder"],
             @"files": [resource stringByAppendingString:@"/contents?type=file"],
             @"contents": [resource stringByAppendingString:@"/contents"]};
    // FIXME: Add <sharing enabled="false"/>
}


-(NSString *) description
{
    return [NSString stringWithFormat:@"SugarSyncFolder\n==============\ndisplayName :%@\ndsid        :%@\ntimeCreated :%@\ncollections :%@\nfiles       :%@\ncontents    :%@\nsharing     :%@\n==============", _displayName, _dsid, _timeCreated, _collections, _files, _contents, _sharingEnabled ? @"true" :@"false"];
}

-(void) dealloc
{
    [_displayName release];
    _displayName = nil;
    
    [_parent release];
    _parent = nil;
    
    [_dsid release];
    _dsid = nil;
    
    [_timeCreated release];
    _timeCreated = nil;
    
    [_collections release];
    _collections = nil;
    
    [_files release];
    _files = nil;
    
    [_contents release];
    _contents = nil;

    [super dealloc];
}

@end
