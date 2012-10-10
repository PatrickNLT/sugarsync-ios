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
-(id) initFromXMLContent:(NSDictionary *)xmlData
{
    self = [super init];
    
    NSNumberFormatter * numberFormat = [NSNumberFormatter new];
    [numberFormat setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSDictionary *obj = [SSXMLLibUtil dictionaryFromNodeArray:xmlData];
    _ref = [[NSURL URLWithString:[obj objectForKey:@"ref"]] retain];
    _lastModified = [[obj objectForKey:@"lastModified"] retain];
    _size  = [[numberFormat numberFromString:[obj objectForKey:@"size"]] longValue]; 
    _mediaType = [[obj objectForKey:@"mediaType"] retain];
    _fileData = [[NSURL URLWithString:[obj objectForKey:@"fileData"]] retain];
    _presentOnServer = [[obj objectForKey:@"presentOnServer"] isEqualToString:@"true"] ? YES :NO;
    
    //for some reason ref is coming back null on calls to get file version - fixing this up
    if ( !_ref && _fileData )
    {
        _ref = [[_fileData URLByDeletingLastPathComponent] retain];
    }
    
    [numberFormat release];

    return self;
}


-(NSString *) description
{
    return [NSString stringWithFormat:@"SugarSyncFileVersion\n==============\nref         :%@\nmediaType   :%@\nlastModified:%@\nsize        :%ld\nfileData    :%@\nonServer    :%@\n==============",  _ref, _mediaType, _lastModified, _size, _fileData, _presentOnServer ?@"YES":@"NO"];
}

#pragma mark Deallocation
-(void) dealloc
{
    [_ref release];
    _ref = nil;
    
    [_mediaType release];
    _mediaType = nil;
    
    [_lastModified release];
    _lastModified = nil;
    
    [_fileData release];
    _fileData = nil;

    [super dealloc];
    

}

@end
