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
#import "SugarSyncXMLTemplate.h"

static NSURL *FileAPI;

@implementation SugarSyncFile

#pragma mark Class Methods
+(void) initialize
{
    FileAPI = [[NSURL URLWithString:@"https://api.sugarsync.com/file/"] retain];
}


#pragma mark Initialization
-(id) initFromXMLContent:(NSDictionary *)xmlData
{
    self = [super init];
    
    NSNumberFormatter * numberFormat = [NSNumberFormatter new];
    [numberFormat setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSDictionary *obj = [SSXMLLibUtil dictionaryFromNodeArray:xmlData];
    _displayName = [[obj objectForKey:@"displayName"] retain];
    _dsid = [[obj objectForKey:@"dsid"] retain];
    _lastModified = [[obj objectForKey:@"lastModified"] retain];
    _timeCreated = [[obj objectForKey:@"timeCreated"] retain];
    _size  = [[numberFormat numberFromString:[obj objectForKey:@"size"]] longValue]; 
    _mediaType = [[obj objectForKey:@"mediaType"] retain];
    _fileData = [[NSURL URLWithString:[obj objectForKey:@"fileData"]] retain];
    _presentOnServer = [[obj objectForKey:@"presentOnServer"] isEqualToString:@"true"] ? YES :NO;
    _versions = [[NSURL URLWithString:[obj objectForKey:@"versions"]] retain];
    _parent = [[NSURL URLWithString:[obj objectForKey:@"parent"]] retain];
    
    NSDictionary *attrs = [obj objectForKey:@"publicLink$attributes"];
    _publicLinkEnabled = [[attrs objectForKey:@"enabled"] isEqualToString:@"true"] ? YES :NO;
    
    _publicLink = [[NSURL URLWithString:[obj objectForKey:@"publicLink"]] retain];

    NSDictionary *image = [obj objectForKey:@"image"];
    
    if ( image )
    {
        int height = [[numberFormat numberFromString:[image objectForKey:@"height"]] intValue];
        int width = [[numberFormat numberFromString:[image objectForKey:@"width"]] intValue];
        int rotation = [[numberFormat numberFromString:[image objectForKey:@"rotation"]] intValue];
        
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

-(id) initWithHeight:(int)aHeight width:(int)aWidth rotation:(int)aRotation
{
    self = [super init];
    
    _height = aHeight;
    _width = aWidth;
    _rotation = aRotation;
    
    return self;
}

@end
