//
//  SugarSyncFile.m
//
//  Created by Bill Culp on 8/27/12.
//  Copyright (c) 2012 Cloud9. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.


#import "SugarSyncFile.h"
#import "SSXMLLibUtil.h"

static NSURL *FileAPI;

@implementation SugarSyncFile

#pragma mark Class Methods
+(void) initialize
{
    FileAPI = [[NSURL URLWithString:@"https://api.sugarsync.com/file/"] retain];
}


#pragma mark Initialization
-(instancetype) initFromXMLContent:(NSDictionary *)xmlData
{
    self = [super init];
    
    NSNumberFormatter * numberFormat = [NSNumberFormatter new];
    [numberFormat setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSDictionary *obj = [SSXMLLibUtil dictionaryFromNodeArray:xmlData];
    _displayName = [obj[@"displayName"] retain];
    _dsid = [obj[@"dsid"] retain];
    _lastModified = [obj[@"lastModified"] retain];
    _timeCreated = [obj[@"timeCreated"] retain];
    _size  = [[numberFormat numberFromString:obj[@"size"]] longValue]; 
    _mediaType = [obj[@"mediaType"] retain];
    _fileData = [[NSURL URLWithString:obj[@"fileData"]] retain];
    _presentOnServer = [obj[@"presentOnServer"] isEqualToString:@"true"] ? YES :NO;
    _versions = [[NSURL URLWithString:obj[@"versions"]] retain];
    _parent = [[NSURL URLWithString:obj[@"parent"]] retain];
    
    NSDictionary *attrs = obj[@"publicLink$attributes"];
    _publicLinkEnabled = [attrs[@"enabled"] isEqualToString:@"true"] ? YES :NO;
    
    _publicLink = [[NSURL URLWithString:obj[@"publicLink"]] retain];

    NSDictionary *image = obj[@"image"];
    
    if ( image )
    {
        int height = [[numberFormat numberFromString:image[@"height"]] intValue];
        int width = [[numberFormat numberFromString:image[@"width"]] intValue];
        int rotation = [[numberFormat numberFromString:image[@"rotation"]] intValue];
        
        _image = [[[SugarSyncFileImage alloc] initWithHeight:height width:width rotation:rotation] retain];
    }
    
    [numberFormat release];
    
    return self;
}

-(NSURL *) resourceURL
{
    return [FileAPI URLByAppendingPathComponent:[_dsid stringByReplacingOccurrencesOfString:@"/" withString:@":"]];
}

-(NSString *) fillXMLTemplate:(SugarSyncXMLTemplate *)aTemplate
{
    NSString *resource = [self resourceURL].description;
    
    if ( !_image )
    {
        return [aTemplate fill:@[_displayName, _dsid, _timeCreated, _parent, [NSString stringWithFormat:@"%ld", _size], _lastModified, _mediaType, _presentOnServer ? @"true":@"false", resource, resource, _publicLinkEnabled?@"true":@"false"]];
    }
    else
    {
        return [aTemplate fill:@[_displayName, _dsid, _timeCreated, _parent, [NSString stringWithFormat:@"%ld", _size], _lastModified, _mediaType, _presentOnServer ? @"true":@"false", resource, resource, _publicLinkEnabled?@"true":@"false", [NSString stringWithFormat:@"%d", _image.height], [NSString stringWithFormat:@"%d", _image.width], [NSString stringWithFormat:@"%d", _image.rotation]]];
    }
}


-(NSString *) description
{
    if ( !_image )
    {
        return [NSString stringWithFormat:@"SugarSyncFile\n==============\ndisplayName :%@\ndsid        :%@\nparent      :%@\nmediaType   :%@\nsize        :%ld\ntimeCreated :%@\nlastModified:%@\nfileData    :%@\nversions    :%@\nonServer    :%@\nisPublic    :%@\npublicLink  :%@\n==============", _displayName, _dsid, _parent, _mediaType, _size, _timeCreated, _lastModified, _fileData, _versions, _presentOnServer ?@"YES":@"NO",
                _publicLinkEnabled ? @"YES" :@"NO", _publicLink];
    }
    else
    {
        return [NSString stringWithFormat:@"SugarSyncFile\n==============\ndisplayName :%@\ndsid        :%@\nparent      :%@\nmediaType   :%@\nsize        :%ld\ntimeCreated :%@\nlastModified:%@\nfileData    :%@\nversions    :%@\nonServer    :%@\nisPublic    :%@\npublicLink  :%@\nimage       :height:%d width:%d rotation:%d\n==============", _displayName, _dsid, _parent, _mediaType, _size, _timeCreated, _lastModified, _fileData, _versions, _presentOnServer ?@"YES":@"NO",
                _publicLinkEnabled ? @"YES" :@"NO", _publicLink, _image.height, _image.width, _image.rotation];
        
    }
}

#pragma mark Deallocation

-(void) dealloc
{
    [_displayName  release];
    _displayName = nil;
    
    [_dsid release];
    _dsid = nil;
    
    [_lastModified release];
    _lastModified = nil;
    
    [_timeCreated release];
    _timeCreated = nil;
    
    [_mediaType release];
    _mediaType = nil;
    
    [_fileData release];
    _fileData = nil;
    
    [_versions release];
    _versions = nil;
    
    [_parent release];
    _parent = nil;
   
    [_image release];
    _image = nil;
    
    [super dealloc];
}
@end

#pragma mark SugarSyncFileImage Utility Class
@implementation SugarSyncFileImage

-(instancetype) initWithHeight:(int)aHeight width:(int)aWidth rotation:(int)aRotation
{
    self = [super init];
    
    _height = aHeight;
    _width = aWidth;
    _rotation = aRotation;
    
    return self;
}

@end
