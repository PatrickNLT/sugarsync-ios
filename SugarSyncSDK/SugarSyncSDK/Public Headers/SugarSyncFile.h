//
//  SugarSyncFile.h
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

@class SugarSyncFileImage;

/*
 * SugarSyncFile represents the full metadata for a file object in the SugarSync API
 */
@interface SugarSyncFile : NSObject

@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSURL *parent;
@property (nonatomic, strong) NSString *mediaType;
@property (nonatomic, assign) BOOL publicLinkEnabled;

//readonly properties
@property (nonatomic, strong, readonly) NSString *dsid;
@property (nonatomic, assign, readonly) long size;
@property (nonatomic, strong, readonly) NSString *lastModified;
@property (nonatomic, strong, readonly) NSString *timeCreated;
@property (nonatomic, strong, readonly) NSURL *fileData;
@property (nonatomic, strong, readonly) NSURL *versions;
@property (nonatomic, strong, readonly) NSURL *publicLink;
@property (nonatomic, strong, readonly) SugarSyncFileImage *image;
@property (nonatomic, assign, readonly) BOOL presentOnServer;

-(instancetype) initFromXMLContent:(NSDictionary *)xmlData NS_DESIGNATED_INITIALIZER;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSURL *resourceURL;
@end

/*
 * SugarSyncFileImage provides extra metadata for images
 */
@interface SugarSyncFileImage : NSObject

@property (nonatomic, assign, readonly) int height;
@property (nonatomic, assign, readonly) int width;
@property (nonatomic, assign, readonly) int rotation;

-(instancetype) initWithHeight:(int)aHeight width:(int)aWidth rotation:(int)aRotation NS_DESIGNATED_INITIALIZER;

@end
