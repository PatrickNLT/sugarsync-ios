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

-(instancetype) initFromXMLContent:(NSDictionary *)xmlData
{
    self = [super init];
    
    NSDictionary *obj = [SSXMLLibUtil dictionaryFromNodeArray:xmlData];
    
    NSDictionary *attrs = obj[@"$attributes"];
    NSString *aType = attrs[@"type"];
        
    _type = [SugarSyncCollection collectionTypeForString:aType];
    _displayName = obj[@"displayName"];
    _ref = [NSURL URLWithString:obj[@"ref"]];
    _contents = [NSURL URLWithString:obj[@"contents"]];
    
    if ( _type == SugarSyncCollectionWorkspace )
    {
        NSNumberFormatter * numberFormat = [NSNumberFormatter new];
        [numberFormat setNumberStyle:NSNumberFormatterDecimalStyle];

        _iconId = [[numberFormat numberFromString:obj[@"iconId"]] intValue];
        
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
@end


@implementation SugarSyncCollectionFile

#pragma mark Initialization
-(instancetype) initFromXMLContent:(NSDictionary *)xmlData
{
    self = [super init];
    
    NSNumberFormatter * numberFormat = [NSNumberFormatter new];
    [numberFormat setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSDictionary *obj = [SSXMLLibUtil dictionaryFromNodeArray:xmlData];
    _displayName = obj[@"displayName"];
    _ref = [NSURL URLWithString:obj[@"ref"]];
    _lastModified = obj[@"lastModified"];
    _size  = [[numberFormat numberFromString:obj[@"size"]] longValue]; 
    _mediaType = obj[@"mediaType"];
    _fileData = [NSURL URLWithString:obj[@"fileData"]];
    _presentOnServer = [obj[@"presentOnServer"] isEqualToString:@"true"] ? YES :NO;
    
    
    return self;
}

-(NSString *) description
{
    return [NSString stringWithFormat:@"SugarSyncCollectionFile\n==============\ndisplayName :%@\nref         :%@\nmediaType   :%@\nlastModified:%@\nsize        :%ld\nfileData    :%@\nonServer    :%@\n==============", _displayName, _ref, _mediaType, _lastModified, _size, _fileData, _presentOnServer ?@"YES":@"NO"];
}

#pragma mark Deallocation


@end
