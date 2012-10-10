//
//  SugarSyncCollection.m
//
//  Created by Bill Culp on 8/27/12.
//  Copyright (c) 2012 Cloud9. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.


#import "SugarSyncCollection.h"
#import "SSXMLLibUtil.h"

@implementation SugarSyncCollection

#pragma mark Initialization

+(NSString *) stringForCollectionType:(SugarSyncCollectionType) type
{
    NSString * typeString;
    
    switch (type) {
        case SugarSyncCollectionWorkspace:
            typeString = @"Workspace";
            break;
        case SugarSyncCollectionAlbum:
            typeString = @"Album";
            break;
        case SugarSyncCollectionFolder:
            typeString = @"Folder";
            break;
        case SugarSyncCollectionSyncFolder:
            typeString = @"SyncFolder";
            break;
            
        default:
            typeString = @"?";
    }

    return typeString;
}

+(SugarSyncCollectionType) collectionTypeForString:(NSString *)aString
{
    SugarSyncCollectionType type = -1;
    
    if ( [aString isEqualToString:@"workspace"] )
    {
        type = SugarSyncCollectionWorkspace;
    }
    else if ( [aString isEqualToString:@"syncFolder"] )
    {
        type = SugarSyncCollectionSyncFolder;
    }
    else if ( [aString isEqualToString:@"folder"] )
    {
        type = SugarSyncCollectionFolder;
    }
    else if ( [aString isEqualToString:@"album"] )
    {
        type = SugarSyncCollectionAlbum;
    }
    
    return type;
}

-(id) initFromXMLContent:(NSDictionary *)xmlData
{
    self = [super init];
    
    NSDictionary *obj = [SSXMLLibUtil dictionaryFromNodeArray:xmlData];
    
    NSDictionary *attrs = [obj objectForKey:@"$attributes"];
    NSString *aType = [attrs objectForKey:@"type"];
        
    _type = [SugarSyncCollection collectionTypeForString:aType];
    _displayName = [[obj objectForKey:@"displayName"] retain];
    _ref = [[NSURL URLWithString:[obj objectForKey:@"ref"]] retain];
    _contents = [[NSURL URLWithString:[obj objectForKey:@"contents"]] retain];
    
    if ( _type == SugarSyncCollectionWorkspace )
    {
        NSNumberFormatter * numberFormat = [NSNumberFormatter new];
        [numberFormat setNumberStyle:NSNumberFormatterDecimalStyle];

        _iconId = [[numberFormat numberFromString:[obj objectForKey:@"iconId"]] intValue];
        
        [numberFormat release];
    }
    else
    {
        _iconId = -1;
    }

    return self;
    
}

-(NSString *) description
{
    NSString *typeString = [SugarSyncCollection stringForCollectionType:_type];

    if ( _type == SugarSyncCollectionWorkspace )
    {
        return [NSString stringWithFormat:@"SugarSyncCollection (%@)\n==============\ndisplayName :%@\nref         :%@\ncontents    :%@\niconId      :%d\n==============", typeString, _displayName, _ref, _contents, _iconId];
    }
    else
    {
        return [NSString stringWithFormat:@"SugarSyncCollection (%@)\n==============\ndisplayName :%@\nref         :%@\ncontents    :%@\n==============", typeString,      _displayName, _ref, _contents];
    }
}


#pragma mark Deallocation
-(void) dealloc
{
    [_displayName release];
    _displayName = nil;
    
    [_ref release];
    _ref = nil;
    
    [_contents release];
    _contents = nil;
    
    [super dealloc];
}
@end


@implementation SugarSyncCollectionFile

#pragma mark Initialization
-(id) initFromXMLContent:(NSDictionary *)xmlData
{
    self = [super init];
    
    NSNumberFormatter * numberFormat = [NSNumberFormatter new];
    [numberFormat setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSDictionary *obj = [SSXMLLibUtil dictionaryFromNodeArray:xmlData];
    _displayName = [[obj objectForKey:@"displayName"] retain];
    _ref = [[NSURL URLWithString:[obj objectForKey:@"ref"]] retain];
    _lastModified = [[obj objectForKey:@"lastModified"] retain];
    _size  = [[numberFormat numberFromString:[obj objectForKey:@"size"]] longValue]; 
    _mediaType = [[obj objectForKey:@"mediaType"] retain];
    _fileData = [[NSURL URLWithString:[obj objectForKey:@"fileData"]] retain];
    _presentOnServer = [[obj objectForKey:@"presentOnServer"] isEqualToString:@"true"] ? YES :NO;
    
    [numberFormat release];
    
    return self;
}

-(NSString *) description
{
    return [NSString stringWithFormat:@"SugarSyncCollectionFile\n==============\ndisplayName :%@\nref         :%@\nmediaType   :%@\nlastModified:%@\nsize        :%ld\nfileData    :%@\nonServer    :%@\n==============", _displayName, _ref, _mediaType, _lastModified, _size, _fileData, _presentOnServer ?@"YES":@"NO"];
}

#pragma mark Deallocation

-(void) dealloc
{
    [_displayName release];
    _displayName = nil;
    
    [_ref release];
    _ref = nil;
    
    [_lastModified release];
    _lastModified = nil;
    
    [_mediaType release];
    _mediaType = nil;
    
    [_fileData release];
    _fileData = nil;
    
    [super dealloc];
}

@end
