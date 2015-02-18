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
    NSArray *nodeList = anObject[@"nodeChildArray"];
    
    NSAssert(nodeList, @"The object did not respond to nodeChildArray");
    
    NSMutableDictionary *newObject = [NSMutableDictionary dictionaryWithCapacity:nodeList.count];
    
    NSArray *topLevelAttributes = anObject[@"nodeAttributeArray"];
    
    if ( topLevelAttributes )
    {
        NSMutableDictionary *attributeDictionary = [NSMutableDictionary dictionaryWithCapacity:topLevelAttributes.count];
        newObject[@"$attributes"] = attributeDictionary;
        
        [topLevelAttributes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            attributeDictionary[obj[@"attributeName"]] = obj[@"nodeContent"];
            
        }];
        
    }
    
    [nodeList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSArray *attributeArray = obj[@"nodeAttributeArray"];
        
        if ( attributeArray )
        {
            NSMutableDictionary *attributeDictionary = [NSMutableDictionary dictionaryWithCapacity:attributeArray.count];
            
            newObject[[((NSString*)obj[@"nodeName"]) stringByAppendingString:@"$attributes"]] = attributeDictionary;
            
            [attributeArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                attributeDictionary[obj[@"attributeName"]] = obj[@"nodeContent"];
                
            }];
            
        }
        
        NSArray *childNodeArray = obj[@"nodeChildArray"];
        
        if ( childNodeArray )
        {
            newObject[obj[@"nodeName"]] = [SSXMLLibUtil dictionaryFromNodeArray:obj];
            
        }
        else
        {
            id nodeContent = obj[@"nodeContent"];
            if ( nodeContent )
            {
                newObject[obj[@"nodeName"]] = nodeContent;
            }
        }
        
    }];

    return newObject;
    
}


@end
