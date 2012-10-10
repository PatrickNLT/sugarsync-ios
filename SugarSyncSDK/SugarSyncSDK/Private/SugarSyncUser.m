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

-(id) initFromXMLContent:(NSDictionary *)xmlData
{
    self = [super init];
    
    NSNumberFormatter * numberFormat = [NSNumberFormatter new];
    [numberFormat setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSDictionary *obj = [SSXMLLibUtil dictionaryFromNodeArray:xmlData];
    
    _username = [[obj objectForKey:@"username"] retain];
    _nickname = [[obj objectForKey:@"nickname"] retain];
    _workspaces = [[NSURL URLWithString:[obj objectForKey:@"workspaces"]] retain];
    _syncfolders = [[NSURL URLWithString:[obj objectForKey:@"syncfolders"]] retain];
    _deleted = [[NSURL URLWithString:[obj objectForKey:@"deleted"]] retain];
    _magicBriefcase = [[NSURL URLWithString:[obj objectForKey:@"magicBriefcase"]] retain];
    _webArchive = [[NSURL URLWithString:[obj objectForKey:@"webArchive"]] retain];
    _mobilePhotos = [[NSURL URLWithString:[obj objectForKey:@"mobilePhotos"]] retain];
    _albums = [[NSURL URLWithString:[obj objectForKey:@"albums"]] retain];
    _receivedShares = [[NSURL URLWithString:[obj objectForKey:@"receivedShares"]] retain];
    _publicLinks = [[NSURL URLWithString:[obj objectForKey:@"publicLinks"]] retain];
    _recentActivities = [[NSURL URLWithString:[obj objectForKey:@"recentActivities"]] retain];
    _contacts = [[NSURL URLWithString:[obj objectForKey:@"contacts"]] retain];
    _maximumPublicLinkSize = [[numberFormat numberFromString:[obj objectForKey:@"maximumPublicLinkSize"]] longValue];
    
    NSDictionary *quota = [obj objectForKey:@"quota"];
    
    if ( quota )
    {
        long limit = [[numberFormat numberFromString:[quota objectForKey:@"limit"]] longValue];
        long usage = [[numberFormat numberFromString:[quota objectForKey:@"usage"]] longValue];
        
        _quota = [[[SugarSyncUserQuota alloc] initWithLimit:limit usage:usage] retain];
    }
       
    [numberFormat release];

    return self;
    
}

-(NSString *) description
{
    return [NSString stringWithFormat:@"SugarSyncUser\n=====================\nusername             :%@\nnickname             :%@\nworkspaces           :%@\nsyncfolders          :%@\ndeleted              :%@\nmagicBriefCase       :%@\nwebArchive           :%@\nmobilePhotos         :%@\nreceivedShares       :%@\ncontacts             :%@\nalbums               :%@\nrecentActivities     :%@\npublicLinks          :%@\nquota.limit          :%ld\nquota.usage          :%ld\nmaximumPublicLinkSize:%ld\n==============", _username, _nickname,
            _workspaces, _syncfolders, _deleted, _magicBriefcase, _webArchive, _mobilePhotos, _receivedShares, _contacts, _albums, _recentActivities, _publicLinks, _quota?_quota.limit : -1,_quota? _quota.usage :-1, _maximumPublicLinkSize];
}


#pragma mark Deallocation

-(void) dealloc
{
    [_username release];
    _username = nil;
    
    [_nickname release];
    _nickname = nil;
    
    [_workspaces release];
    _workspaces = nil;
    
    [_syncfolders release];
    _syncfolders = nil;
    
    [_deleted release];
    _deleted = nil;
    
    [_magicBriefcase release];
    _magicBriefcase = nil;
    
    [_webArchive release];
    _webArchive = nil;
    
    [_mobilePhotos release];
    _mobilePhotos = nil;
    
    [_receivedShares release];
    _receivedShares = nil;
    
    [_contacts release];
    _contacts = nil;
    
    [_albums release];
    _albums = nil;
    
    [_recentActivities release];
    _recentActivities = nil;
    
    [_publicLinks release];
    _publicLinks = nil;
    
    [_quota release];
    _quota = nil;

    [super dealloc];

}

@end

#pragma mark Quota Utility Object

@implementation SugarSyncUserQuota

-(id) initWithLimit:(long)aLimit usage:(long)usage
{
    self = [super init];
    
    _limit = aLimit;
    _usage = usage;
    return self;
    
}
@end
