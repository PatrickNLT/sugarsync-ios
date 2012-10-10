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

@class SugarSyncXMLTemplate;

@class SugarSyncFileImage;

/*
 * SugarSyncFile represents the full metadata for a file object in the SugarSync API
 */
@interface SugarSyncFile : NSObject

@property (nonatomic, retain) NSString *displayName;
@property (nonatomic, retain) NSURL *parent;
@property (nonatomic, retain) NSString *mediaType;
@property (nonatomic, assign) BOOL publicLinkEnabled;

//readonly properties
@property (nonatomic, retain, readonly) NSString *dsid;
@property (nonatomic, assign, readonly) long size;
@property (nonatomic, retain, readonly) NSString *lastModified;
@property (nonatomic, retain, readonly) NSString *timeCreated;
@property (nonatomic, retain, readonly) NSURL *fileData;
@property (nonatomic, retain, readonly) NSURL *versions;
@property (nonatomic, retain, readonly) NSURL *publicLink;
@property (nonatomic, retain, readonly) SugarSyncFileImage *image;
@property (nonatomic, assign, readonly) BOOL presentOnServer;


-(id) initFromXMLContent:(NSDictionary *)xmlData;
-(NSURL *) resourceURL;
-(NSString *) fillXMLTemplate:(SugarSyncXMLTemplate *)aTemplate;
@end

/*
 * SugarSyncFileImage provides extra metadata for images
 */
@interface SugarSyncFileImage : NSObject

@property (nonatomic, assign, readonly) int height;
@property (nonatomic, assign, readonly) int width;
@property (nonatomic, assign, readonly) int rotation;

-(id) initWithHeight:(int)aHeight width:(int)aWidth rotation:(int)aRotation;

@end
