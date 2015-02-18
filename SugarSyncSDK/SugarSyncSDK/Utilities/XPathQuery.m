//
//  XPathQuery.m
//  FuelFinder
//
//  Created by Matt Gallagher on 4/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import "XPathQuery.h"

#import <libxml/tree.h>
#import <libxml/parser.h>
#import <libxml/HTMLparser.h>
#import <libxml/xpath.h>
#import <libxml/xpathInternals.h>

NSDictionary *DictionaryForNode(xmlNodePtr currentNode, NSMutableDictionary *parentResult)
{
	NSMutableDictionary *resultForNode = [NSMutableDictionary dictionary];
	
	if (currentNode->name)
	{
		NSString *currentNodeContent =
			@((const char *)currentNode->name);
		resultForNode[@"nodeName"] = currentNodeContent;
	}
	
	if (currentNode->content && currentNode->type != XML_DOCUMENT_TYPE_NODE)
	{
		NSString *currentNodeContent =
			@((const char *)currentNode->content);
		
		if ([resultForNode[@"nodeName"] isEqual:@"text"] && parentResult)
		{
			currentNodeContent = [currentNodeContent
				stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			
			NSString *existingContent = parentResult[@"nodeContent"];
			NSString *newContent;
			if (existingContent)
			{
				newContent = [existingContent stringByAppendingString:currentNodeContent];
			}
			else
			{
				newContent = currentNodeContent;
			}

			parentResult[@"nodeContent"] = newContent;
			return nil;
		}
		
		resultForNode[@"nodeContent"] = currentNodeContent;
	}
	
	xmlAttr *attribute = currentNode->properties;
	if (attribute)
	{
		NSMutableArray *attributeArray = [NSMutableArray array];
		while (attribute)
		{
			NSMutableDictionary *attributeDictionary = [NSMutableDictionary dictionary];
			NSString *attributeName =
				@((const char *)attribute->name);
			if (attributeName)
			{
				attributeDictionary[@"attributeName"] = attributeName;
			}
			
			if (attribute->children)
			{
				NSDictionary *childDictionary = DictionaryForNode(attribute->children, attributeDictionary);
				if (childDictionary)
				{
					attributeDictionary[@"attributeContent"] = childDictionary;
				}
			}
			
			if ([attributeDictionary count] > 0)
			{
				[attributeArray addObject:attributeDictionary];
			}
			attribute = attribute->next;
		}
		
		if ([attributeArray count] > 0)
		{
			resultForNode[@"nodeAttributeArray"] = attributeArray;
		}
	}

	xmlNodePtr childNode = currentNode->children;
	if (childNode)
	{
		NSMutableArray *childContentArray = [NSMutableArray array];
		while (childNode)
		{
			NSDictionary *childDictionary = DictionaryForNode(childNode, resultForNode);
			if (childDictionary)
			{
				[childContentArray addObject:childDictionary];
			}
			childNode = childNode->next;
		}
		if ([childContentArray count] > 0)
		{
			resultForNode[@"nodeChildArray"] = childContentArray;
		}
	}
	
	return resultForNode;
}

NSArray *PerformXPathQuery(xmlDocPtr doc, NSString *query)
{
    xmlXPathContextPtr xpathCtx; 
    xmlXPathObjectPtr xpathObj; 

    /* Create xpath evaluation context */
    xpathCtx = xmlXPathNewContext(doc);
    if(xpathCtx == NULL)
	{
		NSLog(@"Unable to create XPath context.");
		return nil;
    }
    
    /* Evaluate xpath expression */
    xpathObj = xmlXPathEvalExpression((xmlChar *)[query cStringUsingEncoding:NSUTF8StringEncoding], xpathCtx);
    if(xpathObj == NULL) {
		NSLog(@"Unable to evaluate XPath.");
		return nil;
    }
	
	xmlNodeSetPtr nodes = xpathObj->nodesetval;
	if (!nodes)
	{
		NSLog(@"Nodes was nil.");
		return nil;
	}
	
	NSMutableArray *resultNodes = [NSMutableArray array];
	for (NSInteger i = 0; i < nodes->nodeNr; i++)
	{
		NSDictionary *nodeDictionary = DictionaryForNode(nodes->nodeTab[i], nil);
		if (nodeDictionary)
		{
			[resultNodes addObject:nodeDictionary];
		}
	}

    /* Cleanup */
    xmlXPathFreeObject(xpathObj);
    xmlXPathFreeContext(xpathCtx); 
    
    return resultNodes;
}

NSArray *PerformHTMLXPathQuery(NSData *document, NSString *query)
{
    xmlDocPtr doc;

    /* Load XML document */ /*(int) cast to remove warning*/
	doc = htmlReadMemory([document bytes], (int)[document length], "", NULL, HTML_PARSE_NOWARNING | HTML_PARSE_NOERROR);
	
    if (doc == NULL)
	{
		NSLog(@"Unable to parse.");
		return nil;
    }
	
	NSArray *result = PerformXPathQuery(doc, query);
    xmlFreeDoc(doc); 
	
	return result;
}

NSArray *PerformXMLXPathQuery(NSData *document, NSString *query)
{
    xmlDocPtr doc;
	
    /* Load XML document */ /*(int) cast to remove warning*/
	doc = xmlReadMemory([document bytes], (int)[document length], "", NULL, XML_PARSE_RECOVER);
	
    if (doc == NULL)
	{
		NSLog(@"Unable to parse.");
		return nil;
    }
	
	NSArray *result = PerformXPathQuery(doc, query);
    xmlFreeDoc(doc); 
	
	return result;
}
