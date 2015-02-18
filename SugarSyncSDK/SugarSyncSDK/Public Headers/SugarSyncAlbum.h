//
//  SugarSyncAlbum.h
//
//  Created by Bill Culp on 8/28/12.
//  Copyright (c) 2012 Cloud9. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.

#import <Foundation/Foundation.h>

/*
 * SugarSyncAlbum represents the full metadata for an album in the SugarSync API
 */
@interface SugarSyncAlbum : NSObject

@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong, readonly) NSString *dsid;
@property (nonatomic, strong, readonly) NSURL *files;
@property (nonatomic, strong, readonly) NSURL *contents;

-(instancetype) initFromXMLContent:(NSDictionary *)xmlData NS_DESIGNATED_INITIALIZER;


@end
