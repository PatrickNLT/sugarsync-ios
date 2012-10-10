//
//  SugarSyncUser.h
//
//  Created by Bill Culp on 8/27/12.
//  Copyright (c) 2012 Cloud9. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.

#import <Foundation/Foundation.h>

/*
 * SugarSyncUser is the primary object returned after login to the SugarSyncAPI.
 * It represents the starting point for retrieving user data from the API
 *
 * The SugarSync API is REST based and uses URLs for all API calls
 * to refer to requested resources and resource manipulation
 *
 * Use the URLs in this object to return collections of various objects
 * in the users account
 */

@class SugarSyncUserQuota;

@interface SugarSyncUser : NSObject


@property (nonatomic, retain, readonly) NSString *username;
@property (nonatomic, retain, readonly) NSString *nickname;
@property (nonatomic, retain, readonly) NSURL *workspaces;
@property (nonatomic, retain, readonly) NSURL *syncfolders;
@property (nonatomic, retain, readonly) NSURL *deleted;
@property (nonatomic, retain, readonly) NSURL *magicBriefcase;
@property (nonatomic, retain, readonly) NSURL *webArchive;
@property (nonatomic, retain, readonly) NSURL *mobilePhotos;
@property (nonatomic, retain, readonly) NSURL *receivedShares;
@property (nonatomic, retain, readonly) NSURL *contacts;
@property (nonatomic, retain, readonly) NSURL *albums;
@property (nonatomic, retain, readonly) NSURL *recentActivities;
@property (nonatomic, retain, readonly) NSURL *publicLinks;
@property (nonatomic, retain, readonly) SugarSyncUserQuota *quota;
@property (nonatomic, assign, readonly) long maximumPublicLinkSize;

-(id) initFromXMLContent:(NSDictionary *)xmlData;


@end

@interface SugarSyncUserQuota : NSObject

@property (nonatomic, assign, readonly) long limit;
@property (nonatomic, assign, readonly) long usage;

-(id) initWithLimit:(long)aLimit usage:(long)usage;


@end