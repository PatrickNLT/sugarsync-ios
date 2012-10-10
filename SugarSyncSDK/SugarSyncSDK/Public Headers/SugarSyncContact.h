//
//  SugarSyncContact.h
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
 * SugarSyncContact represents the full metadata for a contact SugarSync API
 */
@interface SugarSyncContact : NSObject

@property (nonatomic, retain, readonly) NSString *primaryEmailAddress;
@property (nonatomic, retain, readonly) NSString *firstName;
@property (nonatomic, retain, readonly) NSString *lastName;

-(id) initFromXMLContent:(NSDictionary *)xmlData;

@end
