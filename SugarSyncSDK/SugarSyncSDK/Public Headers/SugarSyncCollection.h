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

typedef NS_ENUM(NSInteger, SugarSyncCollectionType) {
    SugarSyncCollectionWorkspace=1,
    SugarSyncCollectionAlbum,
    SugarSyncCollectionFolder,
    SugarSyncCollectionSyncFolder
} ;

/*
 *  A SugarSyncCollection is a generic list of objects which can represent various types of entities
 *  See enum SugarSyncCollectionType
 */
@interface SugarSyncCollection : NSObject

@property (nonatomic, strong, readonly) NSString *displayName;
@property (nonatomic, strong, readonly) NSURL *ref;
@property (nonatomic, strong, readonly) NSURL *contents;
@property (nonatomic, assign, readonly) int iconId;
@property (nonatomic, assign, readonly) SugarSyncCollectionType type;

-(instancetype) initFromXMLContent:(NSDictionary *)xmlData NS_DESIGNATED_INITIALIZER;
@end

/*
 *  A SugarSyncCollectionFile is a reference to a file only found in SugarSyncCollections
 *  This reference in not updateable and only returned in Collections - 
 *  Not to be confused with SugarSyncFile which is the full file metadata
 */
@interface SugarSyncCollectionFile : NSObject

@property (nonatomic, strong, readonly) NSString *displayName;
@property (nonatomic, strong, readonly) NSString *mediaType;
@property (nonatomic, strong, readonly) NSURL *ref;
@property (nonatomic, assign, readonly) long size;
@property (nonatomic, strong, readonly) NSString *lastModified;
@property (nonatomic, strong, readonly) NSURL *fileData;
@property (nonatomic, assign, readonly) BOOL presentOnServer;

-(instancetype) initFromXMLContent:(NSDictionary *)xmlData NS_DESIGNATED_INITIALIZER;

@end
