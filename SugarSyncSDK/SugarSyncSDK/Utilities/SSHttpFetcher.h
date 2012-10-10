//
//  HttpFetcher.h
//
//  Created by Bill Culp on 10/28/10.
//  Copyright Cloud9 All rights reserved
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.

#import <Foundation/Foundation.h>


/* 
 * HTTPFetcher is a simple wrapper around NSURLConnection
 */
@interface SSHttpFetcher : NSObject 

@property (nonatomic, readonly, retain) NSURL *URL;
@property (nonatomic, readonly, retain) NSData *data;
@property (nonatomic, readonly, retain) NSError *error;
@property (nonatomic, readonly, retain) NSHTTPURLResponse *response;

+(NSString *) resultToString:(NSData *)theData;

-(id) initWithURL:(NSURL *) aURL;
-(void) setHeaderValue:(NSString *)aValue forKey:(NSString *) aKey;

-(void) put:(NSString *)aBody completionHandler:(void (^)(void))aCompletionHandler;
-(void) putBinary:(NSData *) aBody completionHandler:(void (^)(void))aCompletionHandler;
-(void) post:(NSString *) aBody completionHandler:(void (^)(void))aCompletionHandler;
-(void) postBinary:(NSData *) aBody completionHandler:(void (^)(void))aCompletionHandler;
-(void) get:(void (^)(void))aCompletionHandler;
-(void) delete:(void (^)(void))aCompletionHandler;

@end
