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
    FolderAPI = [NSURL URLWithString:@"https://api.sugarsync.com/folder/"];
}

-(instancetype) initFromXMLContent:(NSDictionary *)xmlData
{
    self = [super init];

    NSDictionary *obj = [SSXMLLibUtil dictionaryFromNodeArray:xmlData];
    
    _displayName = obj[@"displayName"];
    _dsid = obj[@"dsid"];
    _parent = [NSURL URLWithString:obj[@"parent"]];
    _timeCreated = obj[@"timeCreated"];
    _collections  = [NSURL URLWithString:obj[@"collections"]];
    _contents = [NSURL URLWithString:obj[@"contents"]];
    _files = [NSURL URLWithString:obj[@"files"]];

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


@end
