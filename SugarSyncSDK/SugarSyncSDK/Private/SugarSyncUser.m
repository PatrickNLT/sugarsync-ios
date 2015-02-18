//
//  SugarSyncUser.m
//
//  Created by Bill Culp on 8/27/12.
//  Copyright (c) 2012 Cloud9. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.


#import "SugarSyncUser.h"
#import "SSXMLLibUtil.h"

@implementation SugarSyncUser

#pragma mark Initialization

-(instancetype) initFromXMLContent:(NSDictionary *)xmlData
{
    self = [super init];
    
    NSNumberFormatter * numberFormat = [NSNumberFormatter new];
    [numberFormat setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSDictionary *obj = [SSXMLLibUtil dictionaryFromNodeArray:xmlData];
    
    _username = obj[@"username"];
    _nickname = obj[@"nickname"];
    _workspaces = [NSURL URLWithString:obj[@"workspaces"]];
    _syncfolders = [NSURL URLWithString:obj[@"syncfolders"]];
    _deleted = [NSURL URLWithString:obj[@"deleted"]];
    _magicBriefcase = [NSURL URLWithString:obj[@"magicBriefcase"]];
    _webArchive = [NSURL URLWithString:obj[@"webArchive"]];
    _mobilePhotos = [NSURL URLWithString:obj[@"mobilePhotos"]];
    _albums = [NSURL URLWithString:obj[@"albums"]];
    _receivedShares = [NSURL URLWithString:obj[@"receivedShares"]];
    _publicLinks = [NSURL URLWithString:obj[@"publicLinks"]];
    _recentActivities = [NSURL URLWithString:obj[@"recentActivities"]];
    _contacts = [NSURL URLWithString:obj[@"contacts"]];
    _maximumPublicLinkSize = [[numberFormat numberFromString:obj[@"maximumPublicLinkSize"]] longValue];
    
    NSDictionary *quota = obj[@"quota"];
    
    if ( quota )
    {
        long limit = [[numberFormat numberFromString:quota[@"limit"]] longValue];
        long usage = [[numberFormat numberFromString:quota[@"usage"]] longValue];
        
        _quota = [[SugarSyncUserQuota alloc] initWithLimit:limit usage:usage];
    }
       

    return self;
    
}

-(NSString *) description
{
    return [NSString stringWithFormat:@"SugarSyncUser\n=====================\nusername             :%@\nnickname             :%@\nworkspaces           :%@\nsyncfolders          :%@\ndeleted              :%@\nmagicBriefCase       :%@\nwebArchive           :%@\nmobilePhotos         :%@\nreceivedShares       :%@\ncontacts             :%@\nalbums               :%@\nrecentActivities     :%@\npublicLinks          :%@\nquota.limit          :%ld\nquota.usage          :%ld\nmaximumPublicLinkSize:%ld\n==============", _username, _nickname,
            _workspaces, _syncfolders, _deleted, _magicBriefcase, _webArchive, _mobilePhotos, _receivedShares, _contacts, _albums, _recentActivities, _publicLinks, _quota?_quota.limit : -1,_quota? _quota.usage :-1, _maximumPublicLinkSize];
}


#pragma mark Deallocation


@end

#pragma mark Quota Utility Object

@implementation SugarSyncUserQuota

-(instancetype) initWithLimit:(long)aLimit usage:(long)usage
{
    self = [super init];
    
    _limit = aLimit;
    _usage = usage;
    return self;
    
}
@end
