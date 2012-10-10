//
//  SugarSyncWorkspace.h
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

@class SugarSyncXMLTemplate;
/*
 * SugarSyncWorkspace represents the full metadata for a workspace in the SugarSync API
 */
@interface SugarSyncWorkspace : NSObject

@property (nonatomic, retain) NSString *displayName;
@property (nonatomic, retain, readonly) NSString *dsid;
@property (nonatomic, retain, readonly) NSString *timeCreated;
@property (nonatomic, retain, readonly) NSURL *collections;
@property (nonatomic, retain, readonly) NSURL *files;
@property (nonatomic, retain, readonly) NSURL *contents;
@property (nonatomic, assign, readonly) int iconId;


-(id) initFromXMLContent:(NSDictionary *)xmlData;
-(NSURL *) resourceURL;
-(NSString *) fillXMLTemplate:(SugarSyncXMLTemplate *)aTemplate;

@end
