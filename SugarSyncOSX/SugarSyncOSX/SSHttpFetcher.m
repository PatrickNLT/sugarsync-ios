//
//  HttpFetcher.m
//
//  Created by Bill Culp on 10/28/10.
//  Copyright Cloud9 All rights reserved
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.


#import "SSHttpFetcher.h"
#import "SSC9Log.h"

@implementation SSHttpFetcher {
    BOOL isHTTPS;
    NSMutableDictionary *userHeaders;
    void (^completionHandler) (void);
    NSMutableURLRequest *request;
}

#pragma mark Class Methods

+(NSString *) resultToString:(NSData *)theData
{
    return [[[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding] autorelease];
}


#pragma mark Initialization

-(id) initWithURL:(NSURL *) aURL
{
#ifdef DEBUG_HTTP_FETCHER
    [C9Log log:aURL];
#endif
    self = [super init];
    _URL = [aURL retain];
    isHTTPS = [aURL.path characterAtIndex:4] == 's';
    
    return self;
}

#pragma mark Instance Methods

-(void) createRequestForMethod:(NSString *) aMethod data:(NSData *)data completionHandler:(void (^)(void))aCompletionHandler
{
    request = [NSMutableURLRequest requestWithURL:_URL];
    [request setHTTPShouldHandleCookies:YES];
    
    if ( userHeaders )
    {
        [userHeaders enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [request setValue:obj forHTTPHeaderField:key];
        }];
    }
    
    request.HTTPMethod = aMethod;
    
    if ( data )
    {
        request.HTTPBody = data;
    }
    
    if ( aCompletionHandler )
    {
        completionHandler = [Block_copy(aCompletionHandler) retain];
    }
    
    _data = [NSMutableData new];
}

-(void) execute
{
    [NSURLConnection connectionWithRequest:request delegate:self];
}

-(void) setHeaderValue:(NSString *)aValue forKey:(NSString *)aKey
{
#ifdef DEBUG_HTTP_FETCHER
    [C9Log format:@"%@:%@", aKey, aValue];
#endif
    
    if ( !userHeaders )
    {
        userHeaders = [[NSMutableDictionary dictionaryWithCapacity:10] retain];
    }
    
    [userHeaders setObject:aValue forKey:aKey];
}

-(void) post:(NSString *) aBody completionHandler:(void (^)(void))aCompletionHandler
{
#ifdef DEBUG_HTTP_FETCHER
    [C9Log log:aBody];
#endif
    
    NSParameterAssert(aBody);

    [self createRequestForMethod:@"POST" data:[aBody dataUsingEncoding:NSUTF8StringEncoding] completionHandler:aCompletionHandler];
    
    [self execute];
        
}

-(void) postBinary:(NSData *) aBody completionHandler:(void (^)(void))aCompletionHandler
{
#ifdef DEBUG_HTTP_FETCHER
    [C9Log log:aBody];
#endif
    
    NSParameterAssert(aBody);
    
    [self createRequestForMethod:@"POST" data:aBody completionHandler:aCompletionHandler];
    
    [self execute];
}

-(void) put:(NSString *) aBody completionHandler:(void (^)(void))aCompletionHandler
{
#ifdef DEBUG_HTTP_FETCHER
    [C9Log log:aBody];
#endif
    NSParameterAssert(aBody);
    
    [self createRequestForMethod:@"PUT" data:[aBody dataUsingEncoding:NSUTF8StringEncoding] completionHandler:aCompletionHandler];
    
    [self execute];
    
}

-(void) putBinary:(NSData *) aBody completionHandler:(void (^)(void))aCompletionHandler
{
#ifdef DEBUG_HTTP_FETCHER
    [C9Log log:aBody];
#endif
    NSParameterAssert(aBody);
    
    [self createRequestForMethod:@"PUT" data:aBody completionHandler:aCompletionHandler];
    
    [self execute];
    
}


-(void) get:(void (^)(void))aCompletionHandler
{
#ifdef DEBUG_HTTP_FETCHER
    [C9Log enter];
#endif
   
    [self createRequestForMethod:@"GET" data:nil completionHandler:aCompletionHandler];
    
    [self execute];

    
}

-(void) delete:(void (^)(void))aCompletionHandler
{
#ifdef DEBUG_HTTP_FETCHER
    [C9Log enter];
#endif
    
    [self createRequestForMethod:@"DELETE" data:nil completionHandler:aCompletionHandler];
    
    [self execute];
    
}

#pragma mark NSURLConnection Delegates

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
#ifdef DEBUG_HTTP_FETCHER
    [C9Log enter];
#endif
    BOOL iCan = NO;

    if ( isHTTPS )
    {
    	iCan = [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
    }
    
    return iCan;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
#ifdef DEBUG_HTTP_FETCHER
    [C9Log enter];
#endif
    
    if ( isHTTPS )
    {
    	[challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    }

}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)someData
{
#ifdef DEBUG_HTTP_FETCHER
    [C9Log enter];
#endif
    [((NSMutableData*)_data) appendData:someData];

}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)anError
{
#ifdef DEBUG_HTTP_FETCHER
    [C9Log enter];
#endif
    _error = [anError retain];
    [_data release];
    _data = nil;
    
    if ( completionHandler )
    {
        completionHandler();
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)aResponse
{
#ifdef DEBUG_HTTP_FETCHER
    [C9Log enter];
#endif
    [((NSMutableData*)_data) setLength:0];
    _response = (NSHTTPURLResponse *)[aResponse retain];
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
#ifdef DEBUG_HTTP_FETCHER
    [C9Log enter];
#endif
    if ( completionHandler )
    {
        completionHandler();
    }
}

#pragma mark Deallocation

-(void) dealloc
{
    [_URL release];
    _URL = nil;
    [_error release];
    _error = nil;
    [_data release];
    _data = nil;
    [_response release];
    _response = nil;
    
    [completionHandler release];
    completionHandler = nil;
    [super dealloc];

}
@end
