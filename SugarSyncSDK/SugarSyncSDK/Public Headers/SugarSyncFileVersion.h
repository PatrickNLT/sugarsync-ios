//
//  SugarSyncFileVersion.h
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
 * SugarSyncFileVersion represents the full metadata for a file version in the  SugarSync API
 */
@interface SugarSyncFileVersion : NSObject


@property (nonatomic, strong, readonly) NSString *mediaType;
@property (nonatomic, strong, readonly) NSURL *ref;
@property (nonatomic, assign, readonly) long size;
@property (nonatomic, strong, readonly) NSString *lastModified;
@property (nonatomic, strong, readonly) NSURL *fileData;
@property (nonatomic, assign, readonly) BOOL presentOnServer;


-(instancetype) initFromXMLContent:(NSDictionary *)xmlData NS_DESIGNATED_INITIALIZER;

@end


