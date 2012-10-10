//
//  XMLLibUtil.h
//
//  Created by Bill Culp on 8/29/12.
//  Copyright (c) 2012 Cloud9. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.



#import <Foundation/Foundation.h>

/*
 * The XPathQuery class which ports LibXML2 to Objective C
 * returns NSArrays of nodes which represent element hives (entity classes)
 *
 * This class turns those NSArrays back into NSDictionaries
 * so that consumers of the XML nodes dont have to iterate over
 * the nodes guessing what attributes to set
 *
 * More objects are created but the consumer doesnt have to iterate testing string equality
 * on nodeName given that the consumer knows what elements its looking for.
 *
 * Attribute dictionaries for a node can be retrieved using nodeName$attributes
 * Objects with children will return a nested NSDictionary for any subtypes
 *
 */

@interface SSXMLLibUtil : NSObject

+(NSDictionary *) dictionaryFromNodeArray:(NSDictionary *) anObject;

@end
