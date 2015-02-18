//
//  SugarSyncFileVersion.m
//
//  Created by Bill Culp on 8/27/12.
//  Copyright (c) 2012 Cloud9. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.


#import "SugarSyncFileVersion.h"
#import "SSXMLLibUtil.h"

@implementation SugarSyncFileVersion

#pragma mark Initialization
-(instancetype) initFromXMLContent:(NSDictionary *)xmlData
{
    self = [super init];
    
    NSNumberFormatter * numberFormat = [NSNumberFormatter new];
    [numberFormat setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSDictionary *obj = [SSXMLLibUtil dictionaryFromNodeArray:xmlData];
    _ref = [NSURL URLWithString:obj[@"ref"]];
    _lastModified = obj[@"lastModified"];
    _size  = [[numberFormat numberFromString:obj[@"size"]] longValue]; 
    _mediaType = obj[@"mediaType"];
    _fileData = [NSURL URLWithString:obj[@"fileData"]];
    _presentOnServer = [obj[@"presentOnServer"] isEqualToString:@"true"] ? YES :NO;
    
    //for some reason ref is coming back null on calls to get file version - fixing this up
    if ( !_ref && _fileData )
    {
        _ref = [_fileData URLByDeletingLastPathComponent];
    }
    

    return self;
}


-(NSString *) description
{
    return [NSString stringWithFormat:@"SugarSyncFileVersion\n==============\nref         :%@\nmediaType   :%@\nlastModified:%@\nsize        :%ld\nfileData    :%@\nonServer    :%@\n==============",  _ref, _mediaType, _lastModified, _size, _fileData, _presentOnServer ?@"YES":@"NO"];
}

#pragma mark Deallocation

@end
