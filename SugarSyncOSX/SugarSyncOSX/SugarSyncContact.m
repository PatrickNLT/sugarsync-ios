//
//  SugarSyncContact.m
//
//  Created by Bill Culp on 8/27/12.
//  Copyright (c) 2012 Cloud9. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.


#import "SugarSyncContact.h"
#import "SSXMLLibUtil.h"

@implementation SugarSyncContact

#pragma mark Initialization

-(id) initFromXMLContent:(NSDictionary *)xmlData
{
    self = [super init];
    
    NSDictionary *obj = [SSXMLLibUtil dictionaryFromNodeArray:xmlData];
    _primaryEmailAddress = [[obj objectForKey:@"primaryEmailAddress"] retain];
    _firstName = [[obj objectForKey:@"firstName"] retain];
    _lastName = [[obj objectForKey:@"lastName"] retain];
    
    return self;
}

-(NSString *) description
{
    return [NSString stringWithFormat:@"SugarSyncContact\n==============\nprimaryEmailAddress:%@\nfirstName          :%@\nlastName           :%@\n==============", _primaryEmailAddress, _firstName, _lastName];
}


#pragma mark Deallocation
-(void) dealloc
{
    [_primaryEmailAddress release];
    _primaryEmailAddress = nil;
    
    [_lastName release];
    _lastName = nil;
    
    [_firstName release];
    _firstName = nil;
    
    [super dealloc];
}
@end
