//
//  SugarSyncWorkspace.m
//
//  Created by Bill Culp on 8/27/12.
//  Copyright (c) 2012 Cloud9. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.


#import "SugarSyncWorkspace.h"
#import "SSXMLLibUtil.h"

static NSURL *WorkspaceAPI;


@implementation SugarSyncWorkspace

#pragma mark Class Methods
+(void) initialize
{
    WorkspaceAPI = [NSURL URLWithString:@"https://api.sugarsync.com/workspace/"];
}

#pragma mark Initialization
-(instancetype) initFromXMLContent:(NSDictionary *)xmlData
{
    self = [super init];
    
    NSNumberFormatter * numberFormat = [NSNumberFormatter new];
    [numberFormat setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSDictionary *obj = [SSXMLLibUtil dictionaryFromNodeArray:xmlData];
    
    _displayName = obj[@"displayName"];
    _dsid = obj[@"dsid"];
    _timeCreated = obj[@"timeCreated"];
    _collections  = [NSURL URLWithString:obj[@"collections"]];
    _files  = [NSURL URLWithString:obj[@"files"]];
    _contents = [NSURL URLWithString:obj[@"contents"]];
    _iconId = [[numberFormat numberFromString:obj[@"iconId"]] intValue];

    
    return self;
}

-(NSURL *) resourceURL
{
    return [WorkspaceAPI URLByAppendingPathComponent:[_dsid stringByReplacingOccurrencesOfString:@"/" withString:@":"]];
}

-(NSDictionary *) XMLParameters
{
    NSString *resource = self.resourceURL.description;
    return @{@"displayName": _displayName,
             @"dsid": _dsid,
             @"timeCreated": _timeCreated,
             @"collections": [resource stringByAppendingString:@"/contents?type=folder"],
             @"files": [resource stringByAppendingString:@"/contents?type=file"],
             @"contents": [resource stringByAppendingString:@"/contents"],
             @"iconId": @6};
}

-(NSString *) description
{
    return [NSString stringWithFormat:@"SugarSyncWorkspace\n==============\ndisplayName :%@\ndsid        :%@\ntimeCreated :%@\ncollections :%@\nfiles       :%@\ncontents    :%@\niconId      :%d\n==============", _displayName, _dsid, _timeCreated, _collections, _files, _contents, _iconId];
}

#pragma mark Deallocation
@end
