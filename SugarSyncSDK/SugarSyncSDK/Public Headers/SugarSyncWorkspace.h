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

/*
 * SugarSyncWorkspace represents the full metadata for a workspace in the SugarSync API
 */
@interface SugarSyncWorkspace : NSObject

@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong, readonly) NSString *dsid;
@property (nonatomic, strong, readonly) NSString *timeCreated;
@property (nonatomic, strong, readonly) NSURL *collections;
@property (nonatomic, strong, readonly) NSURL *files;
@property (nonatomic, strong, readonly) NSURL *contents;
@property (nonatomic, assign, readonly) int iconId;
@property (weak, nonatomic, readonly) NSDictionary *XMLParameters;

-(instancetype) initFromXMLContent:(NSDictionary *)xmlData NS_DESIGNATED_INITIALIZER;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSURL *resourceURL;

@end
