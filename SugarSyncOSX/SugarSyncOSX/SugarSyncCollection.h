//
//  SugarSyncCollection.h
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

typedef enum {
    SugarSyncCollectionWorkspace=1,
    SugarSyncCollectionAlbum,
    SugarSyncCollectionFolder,
    SugarSyncCollectionSyncFolder
} SugarSyncCollectionType;

/*
 *  A SugarSyncCollection is a generic list of objects which can represent various types of entities
 *  See enum SugarSyncCollectionType
 */
@interface SugarSyncCollection : NSObject

@property (nonatomic, retain, readonly) NSString *displayName;
@property (nonatomic, retain, readonly) NSURL *ref;
@property (nonatomic, retain, readonly) NSURL *contents;
@property (nonatomic, assign, readonly) int iconId;
@property (nonatomic, assign, readonly) SugarSyncCollectionType type;

-(id) initFromXMLContent:(NSDictionary *)xmlData;
@end

/*
 *  A SugarSyncCollectionFile is a reference to a file only found in SugarSyncCollections
 *  This reference in not updateable and only returned in Collections - 
 *  Not to be confused with SugarSyncFile which is the full file metadata
 */
@interface SugarSyncCollectionFile : NSObject

@property (nonatomic, retain, readonly) NSString *displayName;
@property (nonatomic, retain, readonly) NSString *mediaType;
@property (nonatomic, retain, readonly) NSURL *ref;
@property (nonatomic, assign, readonly) long size;
@property (nonatomic, retain, readonly) NSString *lastModified;
@property (nonatomic, retain, readonly) NSURL *fileData;
@property (nonatomic, assign, readonly) BOOL presentOnServer;

-(id) initFromXMLContent:(NSDictionary *)xmlData;

@end
