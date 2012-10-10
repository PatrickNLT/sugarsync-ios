//
//  XMLLibUtil.m
//
//  Created by Bill Culp on 8/29/12.
//  Copyright (c) 2012 Cloud9. All rights reserved.
//
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.

#import "SSXMLLibUtil.h"

@implementation SSXMLLibUtil

+(NSDictionary *) dictionaryFromNodeArray:(NSDictionary *)anObject
{
    NSArray *nodeList = [anObject objectForKey:@"nodeChildArray"];
    
    NSAssert(nodeList, @"The object did not respond to nodeChildArray");
    
    NSMutableDictionary *newObject = [NSMutableDictionary dictionaryWithCapacity:nodeList.count];
    
    NSArray *topLevelAttributes = [anObject objectForKey:@"nodeAttributeArray"];
    
    if ( topLevelAttributes )
    {
        NSMutableDictionary *attributeDictionary = [NSMutableDictionary dictionaryWithCapacity:topLevelAttributes.count];
        [newObject setObject:attributeDictionary forKey:@"$attributes"];
        
        [topLevelAttributes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [attributeDictionary setObject:[obj objectForKey:@"nodeContent"] forKey:[obj objectForKey:@"attributeName"]];
            
        }];
        
    }
    
    [nodeList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSArray *attributeArray = [obj objectForKey:@"nodeAttributeArray"];
        
        if ( attributeArray )
        {
            NSMutableDictionary *attributeDictionary = [NSMutableDictionary dictionaryWithCapacity:attributeArray.count];
            
            [newObject setObject:attributeDictionary forKey:[((NSString*)[obj objectForKey:@"nodeName"]) stringByAppendingString:@"$attributes"]];
            
            [attributeArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [attributeDictionary setObject:[obj objectForKey:@"nodeContent"] forKey:[obj objectForKey:@"attributeName"]];
                
            }];
            
        }
        
        NSArray *childNodeArray = [obj objectForKey:@"nodeChildArray"];
        
        if ( childNodeArray )
        {
            [newObject setObject:[SSXMLLibUtil dictionaryFromNodeArray:obj] forKey:[obj objectForKey:@"nodeName"]];
            
        }
        else
        {
            id nodeContent = [obj objectForKey:@"nodeContent"];
            if ( nodeContent )
            {
                [newObject setObject:nodeContent forKey:[obj objectForKey:@"nodeName"]];
            }
        }
        
    }];

    return newObject;
    
}


@end
