//
//  SugarSyncXMLTemplate.h
//
//  Created by Bill Culp on 8/26/12.
//  Copyright (c) 2012 Cloud9. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.


#import <Foundation/Foundation.h>

/*
 * SugarSyncXMLTemplate represents static SML template resources for internal use by the SugarSyncClient
 */
@interface SugarSyncXMLTemplate : NSObject

+(SugarSyncXMLTemplate*) login;
+(SugarSyncXMLTemplate*) updateWorkspace;
+(SugarSyncXMLTemplate*) createFolder;
+(SugarSyncXMLTemplate*) updateFolder;
+(SugarSyncXMLTemplate*) createFile;
+(SugarSyncXMLTemplate*) copyFile;
+(SugarSyncXMLTemplate*) updateFile;
+(SugarSyncXMLTemplate*) updateFileImage;
+(SugarSyncXMLTemplate*) accessToken;

@property (nonatomic, retain, readonly) NSString *name;

-(NSString *) fill:(NSArray *) params;

@end
