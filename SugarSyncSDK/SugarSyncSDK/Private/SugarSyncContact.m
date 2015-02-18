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

-(instancetype) initFromXMLContent:(NSDictionary *)xmlData
{
    self = [super init];
    
    NSDictionary *obj = [SSXMLLibUtil dictionaryFromNodeArray:xmlData];
    _primaryEmailAddress = obj[@"primaryEmailAddress"];
    _firstName = obj[@"firstName"];
    _lastName = obj[@"lastName"];
    
    return self;
}

-(NSString *) description
{
    return [NSString stringWithFormat:@"SugarSyncContact\n==============\nprimaryEmailAddress:%@\nfirstName          :%@\nlastName           :%@\n==============", _primaryEmailAddress, _firstName, _lastName];
}


#pragma mark Deallocation
@end
