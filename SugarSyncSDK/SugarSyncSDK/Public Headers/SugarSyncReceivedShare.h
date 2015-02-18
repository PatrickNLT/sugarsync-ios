//
//  SugarSyncReceivedShare.h
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
 * SugarSyncReceivedShare represents the full metadata for a shared object in the SugarSync API
 */
@interface SugarSyncReceivedShare : NSObject

@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong, readonly) NSString *timeReceived;
@property (nonatomic, strong, readonly) NSURL *sharedFolder;
@property (nonatomic, assign, readonly) BOOL permissionRead;
@property (nonatomic, assign, readonly) BOOL permissionWrite;
@property (nonatomic, strong, readonly) NSURL *owner;


-(instancetype) initFromXMLContent:(NSDictionary *)xmlData NS_DESIGNATED_INITIALIZER;

@end
