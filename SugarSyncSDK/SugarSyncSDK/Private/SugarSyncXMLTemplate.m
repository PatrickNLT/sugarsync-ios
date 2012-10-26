//
//  SugarSyncXMLTemplate.m
//
//  Created by Bill Culp on 8/26/12.
//  Copyright (c) 2012 Cloud9. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.

#import "SugarSyncXMLTemplate.h"

static NSMutableDictionary *_sugarSyncLoadedTemplates;
static NSString *TemplateLogin = @"login";
static NSString *TemplateUpdateWorkspace = @"updateWorkspace";
static NSString *TemplateCreateFolder = @"createFolder";
static NSString *TemplateUpdateFolder = @"updateFolder";
static NSString *TemplateCreateFile = @"createFile";
static NSString *TemplateCopyFile = @"copyFile";
static NSString *TemplateUpdateFile = @"updateFile";
static NSString *TemplateUpdateFileImage = @"updateFileImage";
static NSString *TemplateAccessToken = @"accessToken";

@implementation SugarSyncXMLTemplate {
    NSArray *components;
}


#pragma mark Class Methods

+(SugarSyncXMLTemplate *) loadTemplateNamed:(NSString *)aTemplateName
{
    NSBundle *myBundle = [NSBundle bundleWithPath:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Frameworks/SugarSyncSDK.framework"]];
    NSString *filePath = [myBundle pathForResource:aTemplateName ofType:@"xml"];
    
    NSError *error = nil;
    
    if ( !filePath )
    {
        [NSException raise:@"SugarSyncTemplateNotFoundException" format:@"The template named %@ could not be loaded from the application bundle resources.  Make sure you have a copy files target in your build to copy the XML templates to your app's resource directory", aTemplateName];
    }
    
    SugarSyncXMLTemplate *template = [[[SugarSyncXMLTemplate alloc] initWithTemplate:[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error] named:aTemplateName] autorelease];
    
    if ( error )
    {
        [NSException raise:@"SugarSyncTemplateNotFoundException" format:@"The template named %@ could not be loaded from the application bundle resources.  Make sure you have a copy files target in your build to copy the XML templates to your app's resource directory", aTemplateName];
        
    }

    
    return template;
}

+(SugarSyncXMLTemplate *) templateNamed:(NSString *)aTemplateName
{
    SugarSyncXMLTemplate *template = nil;
    
    if ( _sugarSyncLoadedTemplates )
    {
        template = [_sugarSyncLoadedTemplates objectForKey:template];
        
        if ( !template )
        {
            @synchronized ([SugarSyncXMLTemplate class])
            {
                template = [SugarSyncXMLTemplate loadTemplateNamed:aTemplateName];
                [_sugarSyncLoadedTemplates setObject:template forKey:aTemplateName];
            }
            
        }
    }
    else
    {
        @synchronized ([SugarSyncXMLTemplate class])
        {
            _sugarSyncLoadedTemplates = [[NSMutableDictionary dictionaryWithCapacity:100] retain];
            template = [SugarSyncXMLTemplate loadTemplateNamed:aTemplateName];
            [_sugarSyncLoadedTemplates setObject:template forKey:aTemplateName];
        }
        
    }
    
    return template;
    
}

+(SugarSyncXMLTemplate*) login
{
    return [SugarSyncXMLTemplate templateNamed:TemplateLogin];
}

+(SugarSyncXMLTemplate*) updateWorkspace
{
    return [SugarSyncXMLTemplate templateNamed:TemplateUpdateWorkspace];
}

+(SugarSyncXMLTemplate*) createFolder
{
    return [SugarSyncXMLTemplate templateNamed:TemplateCreateFolder];
}

+(SugarSyncXMLTemplate*) updateFolder
{
    return [SugarSyncXMLTemplate templateNamed:TemplateUpdateFolder];
}

+(SugarSyncXMLTemplate*) createFile
{
    return [SugarSyncXMLTemplate templateNamed:TemplateCreateFile];
}

+(SugarSyncXMLTemplate*) copyFile
{
    return [SugarSyncXMLTemplate templateNamed:TemplateCopyFile];
}

+(SugarSyncXMLTemplate*) updateFile
{
    return [SugarSyncXMLTemplate templateNamed:TemplateUpdateFile];
}

+(SugarSyncXMLTemplate*) updateFileImage
{
    return [SugarSyncXMLTemplate templateNamed:TemplateUpdateFileImage];
}

+(SugarSyncXMLTemplate*) accessToken
{
    return [SugarSyncXMLTemplate templateNamed:TemplateAccessToken];
}



#pragma mark Initialization

-(id) initWithTemplate:(NSString *)aTemplateString named:(NSString *)aName
{
    self = [super init];
    
    _name = [aName retain];
    
    components = [[aTemplateString componentsSeparatedByString:@"%@"] retain];
    
    return self;
}

#pragma mark Instance Methods

-(NSString *) fill:(NSArray *) params
{
    NSParameterAssert(params.count == components.count-1);
    
    NSString *filledTemplate = components[0];
    
    for (int i=1; i< components.count; i++)
    {
        filledTemplate = [filledTemplate stringByAppendingFormat:@"%@%@", params[i-1], components[i]];
    }

    return filledTemplate;

}


@end
