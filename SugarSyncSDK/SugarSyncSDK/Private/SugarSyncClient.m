//
//  SugarSyncClient.m
//
//  Created by Bill Culp on 8/26/12.
//  Copyright (c) 2012 Cloud9. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.


#import "SugarSyncClient.h"
#import "SugarSyncLoginViewController.h"
#import "SugarSyncXMLTemplate.h"
#import "SSHttpFetcher.h"
#import "XPathQuery.h"
#import "SSXMLLibUtil.h"
#import "SSErrorUtil.h"
#import "SSC9Log.h"
#import "KeychainItemWrapper.h"


//shared instance
static SugarSyncClient *_sugarSyncClientSingleton;

//API Locations
static NSURL *AppAuthorizationAPI;
static NSURL *AuthorizationAPI;

//Cached DateFormatter
static NSDateFormatter *AccessTokenExpiryFormatter;

//Error Constants
static NSString *SugarSyncClientErrorDomain = @"SugarSyncClientDomain";

typedef enum {
    SugarSyncStatusMaxOKRange = 299,
    SugarSyncErrorBadRequest = 400,
    SugarSyncErrorAuthorizationRequired = 401,
    SugarSyncErrorForbidden = 403,
    SugarSyncErrorNotFound = 404,
    SugarSyncErrorNotAcceptable = 406,
    SugarSyncErrorServerError = 500,
    SugarSyncErrorNoDataReturned = 699
} SugarSyncErrorCodes;

//HTTP Header Constants
static NSString *HeaderKeyLocation = @"Location";
static NSString *HeaderKeyUserAgent = @"User-Agent";
static NSString *HeaderKeyContentType = @"Content-Type";
static NSString *HeaderKeyAuthorization = @"Authorization";
static NSString *HeaderKeyAccept = @"Accept";
static NSString *HeaderValueContentType = @"application/xml; charset=UTF-8";

//XPath Queries
static NSString *XPathAuthorizationDocument = @"/authorization";
static NSString *XPathUserDocument = @"/user";
static NSString *XPathFolderDocument = @"/folder";
static NSString *XPathReceivedShareDocument = @"/receivedShare";
static NSString *XPathReceivedShareNode = @"/receivedShares/receivedShare";
static NSString *XPathContactDocument=@"/contact";
static NSString *XPathWorkspaceDocument = @"/workspace";
static NSString *XPathCollectionNode = @"/collectionContents/collection";
static NSString *XPathFileNode = @"/collectionContents/file";
static NSString *XPathFileDocument = @"/file";
static NSString *XPathFileVersionDocument = @"/fileVersion";
static NSString *XPathFileVersionNode = @"/fileVersions/fileVersion";
static NSString *XPathAlbumDocument = @"/album";
static NSString *XMLKeyNodeContent = @"nodeContent";

@implementation SugarSyncClient {

@private
    NSURL *refreshToken;
    NSURL *accessToken;
    NSURL *userResource;
    NSString *applicationId;
    NSString *accessKey;
    NSString *privateAccessKey;
    NSString *applicationUserAgent;
    NSTimeInterval accessTokenExpiry;
    BOOL ignoreTokenExpiry;
    BOOL refreshingToken;
    SugarSyncLoginViewController *loginViewController;
}

#pragma mark Class Methods

+(void) initialize
{
    AppAuthorizationAPI = [[NSURL URLWithString:@"https://api.sugarsync.com/app-authorization"] retain];
    AuthorizationAPI = [[NSURL URLWithString:@"https://api.sugarsync.com/authorization"] retain];

    AccessTokenExpiryFormatter = [[NSDateFormatter alloc] init];
    [AccessTokenExpiryFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'.'SSSZZZZ"];
    
}

+(SugarSyncClient *) createWithApplicationId:(NSString *)anApplicationId accessKey:(NSString *)anAccessKey privateAccessKey:(NSString *)aPrivateAccessKey userAgent:(NSString *)aUserAgent
{
    @synchronized ([SugarSyncClient class])
    {
        NSAssert(!_sugarSyncClientSingleton, @"create cannot be called after client has been created");
        
        _sugarSyncClientSingleton = [[SugarSyncClient alloc] initWithApplicationId:anApplicationId accessKey:anAccessKey privateAccessKey:aPrivateAccessKey userAgent:aUserAgent];
        
        return _sugarSyncClientSingleton;
    }
    
}

+(SugarSyncClient *) sharedInstance
{
    @synchronized ([SugarSyncClient class])
    {
        NSAssert(_sugarSyncClientSingleton, @"getInstance cannot be called until the client has been created");
        
        return _sugarSyncClientSingleton;

    }
}
           
#pragma mark Initialization
-(id) initWithApplicationId:(NSString *)appId accessKey:(NSString *)anAccessKey privateAccessKey:(NSString *)aPrivateAccessKey userAgent:(NSString *)aUserAgent;
{
    self = [super init];
    
    applicationId = appId;
    accessKey = anAccessKey;
    privateAccessKey = aPrivateAccessKey;
    applicationUserAgent = aUserAgent;
    refreshingToken = YES;
    
    return self;
}


#pragma mark Instance Methods

#pragma mark Login

-(BOOL) loggedIn
{
    if ( !refreshToken )
    {
        [self getPersistentRefreshToken];
        
        if ( refreshToken )
        {
            refreshingToken = NO;
            
        }

    }

    return refreshToken != nil;
    
}


-(void) displayLoginDialogWithCompletionHandler:(void (^)(SugarSyncLoginStatus aStatus, NSError *error))handler
{
    NSBundle *myBundle = [NSBundle bundleWithPath:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Frameworks/SugarSyncSDK.framework"]];
    
    NSString *nib = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ?
        @"SugarSyncLoginView_ipad" : @"SugarSyncLoginView_iphone";
    
    loginViewController = [[SugarSyncLoginViewController alloc] initWithNibName:nib bundle:myBundle];
    loginViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    loginViewController.client = self;
    loginViewController.completionHandler = Block_copy(handler);
    
    [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentModalViewController:loginViewController animated:YES];
    
}

-(void) loginWithUserName:(NSString *)aUserName password:(NSString *)aPassword completionHandler:(void (^)(SugarSyncLoginStatus aStatus, NSError *error))handler
{
    NSString *resourceXML = [SugarSyncXMLTemplate.login fill:@[aUserName, aPassword, applicationId, accessKey, privateAccessKey]];
    
    [self createResource:resourceXML atLocation:AppAuthorizationAPI resourceKey:@"refresh token" completionHandler:^(NSURL *newResource, NSError *anError) {
        if ( anError )
        {
            if ( loginViewController )
            {
                loginViewController.error.text = anError.code == SugarSyncErrorAuthorizationRequired ?
                    @"The user name and password are incorrect." :
                    [NSString stringWithFormat:@"Login Failed. (error %d)", anError.code];
                loginViewController.error.hidden = NO;
            }
            else
            {
                handler(SugarSyncLoginError, anError);
            }
        }
        else
        {
            refreshToken = [newResource retain];
            
            [self persistRefreshToken];
            
            refreshingToken = NO;
            
            if ( loginViewController )
            {
                [loginViewController dismissViewControllerAnimated:YES completion:nil];
            }
            
            handler(SugarSyncLoginSuccess, nil);
            
        }
    }];
    
}

-(void) getUserWithCompletionHandler:(void (^)(SugarSyncUser *aUser, NSError *error))handler
{
    if ( !_sugarSyncUser )
    {
        refreshingToken = NO;
        
        [self refreshAccessToken:^(NSError *error) {
            if ( !error )
            {
                [self getResource:userResource resourceKey:@"user" requiredXMLResponse:XPathUserDocument completionHandler:^(NSData *theResource, NSArray *xmlResponse, NSError *anError) {
                    
                    if ( !anError )
                    {
                        _sugarSyncUser = [[SugarSyncUser alloc] initFromXMLContent:xmlResponse[0]];
                    }
                    
                    handler(_sugarSyncUser, anError);
                    
                }];
            }
            else
            {
                handler(nil, error);
            }
        }];
        
    }
    else
    {
        handler(_sugarSyncUser, nil);
    }
    
}

#pragma mark Collection

-(void) getCollectionWithURL:(NSURL *)aURL completionHandler:(void (^)(NSArray *, NSError *))handler
{
    [self getResource:aURL resourceKey:@"collection" completionHandler:^(NSData *theResource, NSError *anError) {
        NSMutableArray *collection = [NSMutableArray arrayWithCapacity:0];
        
        if ( !anError )
        {
            NSArray *nodeList = PerformXMLXPathQuery( theResource, XPathCollectionNode );
            
            if ( nodeList.count )
            {
                collection = [NSMutableArray arrayWithCapacity:40];
                
                for ( int i=0; i < nodeList.count; i++)
                {
                    [collection addObject:[[[SugarSyncCollection alloc] initFromXMLContent:nodeList[i]] autorelease]];
                }
            }
        }
        
        handler(collection, anError);
        
    }];
        
}

#pragma mark Workspace

-(void) getWorkspaceWithURL:(NSURL *)aURL completionHandler:(void (^)(SugarSyncWorkspace *, NSError *))handler
{
    [self getResource:aURL resourceKey:@"workspace" requiredXMLResponse:XPathWorkspaceDocument completionHandler:^(NSData *theResource, NSArray *xmlResponse, NSError *anError) {
        SugarSyncWorkspace *aWorkspace = nil;
        
        if ( !anError )
        {
            aWorkspace = [[[SugarSyncWorkspace alloc] initFromXMLContent:xmlResponse[0]] autorelease];
        }
        
        handler(aWorkspace,anError);
        
    }];
}

-(void) updateWorkspace:(SugarSyncWorkspace *)aWorkspace completionHandler:(void (^)(NSError *))handler
{
    NSString *resourceXML = [aWorkspace fillXMLTemplate:SugarSyncXMLTemplate.updateWorkspace];
    
    [self updateResource:resourceXML atLocation:aWorkspace.resourceURL resourceKey:@"workspace" completionHandler:^(NSError *anError) {
        handler(anError);
    }];
    
}

#pragma mark Folder

-(void) getFolderWithURL:(NSURL *)aURL completionHandler:(void (^)(SugarSyncFolder *, NSError *))handler
{
    [self getResource:aURL resourceKey:@"folder" requiredXMLResponse:XPathFolderDocument completionHandler:^(NSData *theResource, NSArray *xmlResponse, NSError *anError) {
        SugarSyncFolder *aFolder = nil;
        
        if ( !anError )
        {
            aFolder = [[[SugarSyncFolder alloc] initFromXMLContent:xmlResponse[0]] autorelease];
        }
        
        handler(aFolder, anError);
        
    }];
}

-(void) getFolderContentsWithURL:(NSURL *)aURL completionHandler:(void (^)(NSArray *, NSError *))handler
{
    [self getResource:aURL resourceKey:@"folder contents" completionHandler:^(NSData *theResource, NSError *anError) {
        NSMutableArray *folderContents = [NSMutableArray arrayWithCapacity:0];
        
        if ( !anError )
        {
            NSArray *folderList = PerformXMLXPathQuery( theResource, XPathCollectionNode );
            NSArray *fileList = PerformXMLXPathQuery( theResource, XPathFileNode );
            
            folderContents = [NSMutableArray arrayWithCapacity:folderList.count + fileList.count];
            
            for ( int i=0; i < folderList.count; i++)
            {
                [folderContents addObject:[[[SugarSyncCollection alloc] initFromXMLContent:folderList[i]] autorelease]];
            }
            
            for ( int i=0; i < fileList.count; i++)
            {
                [folderContents addObject:[[[SugarSyncCollectionFile alloc] initFromXMLContent:fileList[i]] autorelease]];
                
            }
        }
        
        handler(folderContents, anError);
        
    }];

    
}

-(void) createFolderNamed:(NSString *)aName parentFolderURL:(NSURL *)parentFolderURL completionHandler:(void (^)(NSURL *, NSError *))handler
{
    NSString *resourceXML = [SugarSyncXMLTemplate.createFolder fill:@[aName]];
    
    [self createResource:resourceXML atLocation:parentFolderURL resourceKey:@"folder" completionHandler:^(NSURL *newResource, NSError *anError) {
        handler(newResource, anError);
    }];
    
}

-(void) deleteFolderWithURL:(NSURL *)aURL completionHandler:(void (^)(NSError *))handler
{
    [self deleteResource:aURL resourceKey:@"folder" completionHandler:^(NSError *anError) {
        handler(anError);
    }];
}

-(void) updateFolder:(SugarSyncFolder *)aFolder completionHandler:(void (^)(NSError *))handler
{
    NSString *resourceXML = [aFolder fillXMLTemplate:SugarSyncXMLTemplate.updateFolder];
    
    [self updateResource:resourceXML atLocation:aFolder.resourceURL resourceKey:@"folder" completionHandler:^(NSError *anError) {
        handler(anError);
    }];
    
}

#pragma mark Album

-(void) getAlbumWithURL:(NSURL *)aURL completionHandler:(void (^)(SugarSyncAlbum *, NSError *))handler
{
    [self getResource:aURL resourceKey:@"album" requiredXMLResponse:XPathAlbumDocument completionHandler:^(NSData *theResource, NSArray *xmlResponse, NSError *anError) {
        SugarSyncAlbum *anAlbum = nil;
        
        if ( !anError )
        {
            anAlbum = [[[SugarSyncAlbum alloc] initFromXMLContent:xmlResponse[0]] autorelease];
        }
        
        handler(anAlbum, anError);
        
    }];
    
}

-(void) getAlbumContentsWithURL:(NSURL *)aURL completionHandler:(void (^)(NSArray *, NSError *))handler
{
    [self getFolderContentsWithURL:aURL completionHandler:^(NSArray *theFolderContents, NSError *error) {
        handler(theFolderContents, error);
    }];
}

#pragma mark File

-(void) getFileWithURL:(NSURL *)aURL completionHandler:(void (^)(SugarSyncFile *, NSError *))handler
{
    [self getResource:aURL resourceKey:@"file" requiredXMLResponse:XPathFileDocument completionHandler:^(NSData *theResource, NSArray *xmlResponse, NSError *anError) {
        SugarSyncFile *aFile = nil;
        
        if ( !anError )
        {
            aFile = [[[SugarSyncFile alloc] initFromXMLContent:xmlResponse[0]] autorelease];
        }
        
        handler(aFile, anError);
        
    }];
    
}

-(void) deleteFileWithURL:(NSURL *)aURL completionHandler:(void (^)(NSError *))handler
{
    [self deleteResource:aURL resourceKey:@"file" completionHandler:^(NSError *anError) {
        handler(anError);
    }];
}

-(void) createFileNamed:(NSString *)aName mediaType:(NSString *)aMediaType parentFolderURL:(NSURL *)aURL completionHandler:(void (^)(NSURL *, NSError *))handler
{
    NSString *resourceXML = [SugarSyncXMLTemplate.createFile fill:@[aName, aMediaType]];
    
    [self createResource:resourceXML atLocation:aURL resourceKey:@"file" completionHandler:^(NSURL *newResource, NSError *anError) {
        handler(newResource, anError);
    }];
    
}

-(void) copyFileWithURL:(NSURL *)aURL parentFolderURL:(NSURL *) parentFolderURL targetFileName:(NSString *)aName completionHandler:(void (^)(NSURL *, NSError *))handler
{
    NSString *resourceXML = [SugarSyncXMLTemplate.copyFile fill:@[aURL, aName]];
    
    [self createResource:resourceXML atLocation:parentFolderURL resourceKey:@"file" completionHandler:^(NSURL *newResource, NSError *anError) {
        handler(newResource, anError);
    }];
    
}

-(void) updateFile:(SugarSyncFile *)aFile completionHandler:(void (^)(SugarSyncFile *aFile, NSError *))handler
{
    NSString *resourceXML = [aFile fillXMLTemplate:aFile.image? SugarSyncXMLTemplate.updateFileImage : SugarSyncXMLTemplate.updateFile];
    
    [self updateResource:resourceXML atLocation:aFile.resourceURL resourceKey:@"file" requiredXMLResponse:XPathFileDocument completionHandler:^(NSData *theResource, NSArray *xmlResponse, NSError *anError) {
        
        SugarSyncFile *aFile = nil;
        if ( !anError )
        {
            aFile = [[[SugarSyncFile alloc] initFromXMLContent:xmlResponse[0]] autorelease];
        }
        
        handler(aFile, anError);
        
    }];

}

#pragma mark Download/Upload

-(void) getFileDataWithURL:(NSURL *)aURL completionHandler:(void (^)(NSData *, NSError *))handler
{
    //we could get a raw resource URL or a URL from SugarSyncFile.fileData best not to care
    if ( ![[aURL lastPathComponent] isEqualToString:@"data"] )
    {
        aURL  = [aURL URLByAppendingPathComponent:@"data"];
    }
    
    [self getResource:aURL resourceKey:@"fileData" completionHandler:^(NSData *theResource, NSError *anError) {
        handler(theResource, anError);
    }];
}

-(void) getFileVersionDataWithURL:aURL completionHandler:(void (^)(NSData *, NSError *))handler
{
    [self getFileDataWithURL:aURL completionHandler:^(NSData *fileData, NSError *error) {
        handler(fileData, error);
    }];
}

-(void) uploadFileVersionDataWithURL:(NSURL *)aURL fileData:(NSData *)fileData completionHandler:(void (^)(NSError *))handler;
{
    [self uploadFileDataWithURL:aURL fileData:fileData completionHandler:^(NSError *error) {
        handler(error);
    }];
    
}

-(void) uploadFileDataWithURL:(NSURL *)aURL fileData:(NSData *)theData completionHandler:(void (^)(NSError *))handler
{
    //we could get a raw resource URL or a URL from SugarSyncFile.fileData best not to care
    if ( ![[aURL lastPathComponent] isEqualToString:@"data"] )
    {
        aURL  = [aURL URLByAppendingPathComponent:@"data"];
    }
    
    [self updateResourceBinary:theData atLocation:aURL resourceKey:@"fileData" completionHandler:^(NSError *anError) {
        handler(anError);
    }];
    
}

#pragma mark Transcode Image Data

-(void) getTranscodedImageDataWithURL:(NSURL *)aURL forMediaType:(NSString *)aMediaType width:(int)width height:(int)height square:(BOOL)square rotation:(int)rotation completionHandler:(void (^)(NSData *, NSError *))handler
{
    //we could get a raw resource URL or a URL from SugarSyncFile.fileData best not to care
    if ( ![[aURL lastPathComponent] isEqualToString:@"data"] )
    {
        aURL  = [aURL URLByAppendingPathComponent:@"data"];
    }
    
    NSString *acceptHeaderValue = [NSString stringWithFormat:@"%@; pxmax=%d; pymax=%d; sq=(%d); r=(%d)", aMediaType, width, height, square?1:0, rotation];
    
    NSDictionary *acceptHeader = @{HeaderKeyAccept : acceptHeaderValue};
    
    [self getResource:aURL resourceKey:@"transcodedImageData" userHeaders:acceptHeader completionHandler:^(NSData *theResource, NSError *anError) {
        handler(theResource, anError);
        
    }];
}

#pragma mark Version History

-(void) getFileVersionWithURL:(NSURL *)aURL completionHandler:(void (^)(SugarSyncFileVersion *, NSError *))handler
{
    [self getResource:aURL resourceKey:@"fileVersion" requiredXMLResponse:XPathFileVersionDocument completionHandler:^(NSData *theResource, NSArray *xmlResponse, NSError *anError) {
        SugarSyncFileVersion *aFileVersion = nil;
        
        if ( !anError )
        {
            aFileVersion = [[[SugarSyncFileVersion alloc] initFromXMLContent:xmlResponse[0]] autorelease];
        }
        
        handler(aFileVersion, anError);
        
    }];
}

-(void) getFileVersionHistoryWithURL:(NSURL *)aURL completionHandler:(void (^)(NSArray *, NSError *))handler
{
    if ( ![[aURL lastPathComponent] isEqualToString:@"version"] )
    {
        aURL  = [aURL URLByAppendingPathComponent:@"version"];
    }
    
    [self getResource:aURL resourceKey:@"fileVersion" completionHandler:^(NSData *theResource, NSError *anError) {
        NSMutableArray *collection = [NSMutableArray arrayWithCapacity:0];
        
        if ( !anError )
        {
            NSArray *nodeList = PerformXMLXPathQuery( theResource, XPathFileVersionNode );
            
            if ( nodeList.count )
            {
                collection = [NSMutableArray arrayWithCapacity:40];
                
                for ( int i=0; i < nodeList.count; i++)
                {
                    [collection addObject:[[[SugarSyncFileVersion alloc] initFromXMLContent:nodeList[i]] autorelease]];
                }
            }
        }
        
        handler(collection, anError);
        
    }];
    
}

-(void) createFileVersionWithURL:(NSURL *)aURL completionHandler:(void (^)(NSURL *, NSError *))handler
{
    [self createResource:@"" atLocation:[aURL URLByAppendingPathComponent:@"version"] resourceKey:@"fileVersion" completionHandler:^(NSURL *newResource, NSError *anError){
        handler(newResource, anError);
    }];
    
}


#pragma mark Received Share
-(void) getReceivedShareWithURL:(NSURL *)aURL completionHandler:(void (^)(SugarSyncReceivedShare *, NSError *))handler
{
    [self getResource:aURL resourceKey:@"receivedShare" requiredXMLResponse:XPathReceivedShareDocument completionHandler:^(NSData *theResource, NSArray *xmlResponse, NSError *anError) {
        SugarSyncReceivedShare *aShare = nil;
        
        if ( !anError )
        {
            aShare = [[[SugarSyncReceivedShare alloc] initFromXMLContent:xmlResponse[0]] autorelease];
        }
        
        handler(aShare, anError);
        
    }];

}

-(void) getReceivedSharesWithURL:(NSURL *)aURL completionHandler:(void (^)(NSArray *, NSError *))handler
{
    [self getResource:aURL resourceKey:@"receivedShare" completionHandler:^(NSData *theResource, NSError *anError) {
        NSMutableArray *shares = [NSMutableArray arrayWithCapacity:0];
        
        if ( !anError )
        {
            NSArray *sharesList = PerformXMLXPathQuery( theResource, XPathReceivedShareNode );
            if ( sharesList.count )
            {
                shares = [NSMutableArray arrayWithCapacity:40];
                for (int i=0; i < sharesList.count; i++)
                {
                    [shares addObject:[[[SugarSyncReceivedShare alloc] initFromXMLContent:sharesList[i]] autorelease]];
                }
                
            }
            
        }
        
        handler(shares, anError);
    }];
    
}

#pragma mark Contact

-(void) getContactWithURL:(NSURL *)aURL completionHandler:(void (^)(SugarSyncContact *, NSError *))handler
{
    [self getResource:aURL resourceKey:@"contact" requiredXMLResponse:XPathContactDocument completionHandler:^(NSData *theResource, NSArray *xmlResponse, NSError *anError) {
        SugarSyncContact *aContact = nil;
        
        if ( !anError )
        {
            aContact = [[[SugarSyncContact alloc] initFromXMLContent:xmlResponse[0]] autorelease];
        }
        
        handler(aContact, anError);
        
    }];
    
}



#pragma mark ========Internal Methods=======

#pragma mark refresh token persistence

-(void) getPersistentRefreshToken
{
    NSString *itemKey = [[[NSBundle mainBundle] bundleIdentifier] stringByAppendingString:@":SugarSync"];
        
    KeychainItemWrapper *keyChain = [[KeychainItemWrapper alloc] initWithIdentifier:itemKey accessGroup:nil];
    
    NSString *persistentToken = [keyChain objectForKey:kSecValueData];
    
    if (persistentToken && persistentToken.length)
    {
#ifdef DEBUG_SUGARSYNC_CLIENT
        [C9Log format:@"setting refresh token %@ from persistence", persistentToken];
#endif
        refreshToken = [[NSURL URLWithString:persistentToken] retain];
    }
    else
    {
        refreshToken = nil;
    }
    
    [keyChain release];
    
}

-(void) persistRefreshToken
{
    NSString *itemKey = [[[NSBundle mainBundle] bundleIdentifier] stringByAppendingString:@":SugarSync"];
    NSString *account = @"sugarSyncRefreshToken";
    
    KeychainItemWrapper *keyChain = [[KeychainItemWrapper alloc] initWithIdentifier:itemKey accessGroup:nil];
    
    [keyChain setObject:account forKey:kSecAttrAccount];
    [keyChain setObject:refreshToken.description forKey:kSecValueData];

    [keyChain release];
}

#pragma mark Access Token

/*
 *  1) refreshToken ? NO - avoids a loop on checking the token while actually refreshing it
 *  2) ignoreTokenExpiry is a fall back in case we dont get a date we can parse or the token expiry is hosed
 *  3) the last check is the normal case we check our token expiry and dont refresh it if its valid
 */
-(BOOL) isAccessTokenExpired
{
    return refreshingToken ? NO : ignoreTokenExpiry ? YES : accessTokenExpiry < [[NSDate date] timeIntervalSince1970] - 60;
}

-(void) setTokenExpirationWithDateTimeString:(NSString *)aString
{
    NSDate *tokenExpirationDate = [AccessTokenExpiryFormatter dateFromString:aString];
    
    if ( !tokenExpirationDate )
    {
        [SSC9Log format:@"Cannot trust the token expiry %@ could not be parsed.  Ignoring token expiry for this session", aString];
        ignoreTokenExpiry = YES;
    }
    else
    {
        accessTokenExpiry = [tokenExpirationDate timeIntervalSince1970];
        
        //lets check it out to make sure its valid in the future
    
        if ( [self isAccessTokenExpired ])
        {
            [SSC9Log format:@"Cannot trust the token expiry %@ was not valid in the future.  Ignoring token expiry for this session", aString];
            ignoreTokenExpiry = YES;
        }
    }
    
}

-(void) refreshAccessToken:(void (^)(NSError *error))handler
{
    if ( ![self isAccessTokenExpired] )
    {
        handler(nil);
        return;
    }

#ifdef DEBUG_SUGARSYNC_CLIENT
    [C9Log enter];
#endif
    
    refreshingToken = YES;
    
    NSString *resourceXML = [SugarSyncXMLTemplate.accessToken fill:@[accessKey, privateAccessKey, refreshToken]];

    [self createResource:resourceXML atLocation:AuthorizationAPI resourceKey:@"accessToken" requiredXMLResponse:XPathAuthorizationDocument completionHandler:^(NSURL *newResource, NSArray *xmlResponse, NSError *anError)
     {
         if ( anError )
         {
             refreshingToken = NO;
             handler(anError);
             return;
         }
         
         if ( accessToken )
         {
             [accessToken release];
         }
         
         accessToken = [newResource retain];
         
         refreshingToken = NO;
         
         NSDictionary *auth = [SSXMLLibUtil dictionaryFromNodeArray:xmlResponse[0]];
         
         if ( !ignoreTokenExpiry )
         {
             [self setTokenExpirationWithDateTimeString:[auth objectForKey:@"expiration"]];
         }

         if ( !userResource )
         {
             userResource = [[NSURL URLWithString:[auth objectForKey:@"user"]] retain];
         }
         
         handler(nil);
     }];
    
}

#pragma mark === Base REST Methods ===

#pragma mark Create Resources

-(NSError *) parseErrorForCreateResource:(SSHttpFetcher *) http resourceKey:(NSString *)aResourceKey
{
    NSError * anError = nil;
    
    if ( http.error )
    {
        anError = http.error;
    }
    else if ( http.response.statusCode > SugarSyncStatusMaxOKRange )
    {
        anError =  [SSErrorUtil errorWithDomain:SugarSyncClientErrorDomain code:http.response.statusCode description:[NSString stringWithFormat:@"the %@ operation failed", aResourceKey] reason:[self errorMessageForCode:http.response.statusCode]];
    }
    else if ( ![[http.response allHeaderFields] objectForKey:HeaderKeyLocation] )
    {
        anError =  [SSErrorUtil errorWithDomain:SugarSyncClientErrorDomain code:SugarSyncErrorNoDataReturned description:[NSString stringWithFormat:@"the %@ operation failed", aResourceKey] reason:[self errorMessageForCode:SugarSyncErrorNoDataReturned]];
    }
    
    if ( anError )
    {
        [self logErrorWithHttpResponse:anError responseData:http.data];
    }
    
    
    return anError;
}


-(void) createResource:(NSString *)resourceXML atLocation:(NSURL *)resourceURL resourceKey:(NSString *)aResourceKey completionHandler:(void (^) (NSURL *newResource, NSError* anError))aCompletionHandler
{
    [self createResource:resourceXML atLocation:resourceURL resourceKey:aResourceKey continuationHandler:^(SSHttpFetcher *http, NSURL *newResource, NSError *anError) {
        aCompletionHandler(newResource, anError);
    }];
}

-(void) createResource:(NSString *)resourceXML atLocation:(NSURL *)resourceURL resourceKey:(NSString *)aResourceKey requiredXMLResponse:(NSString *)anXPathQuery completionHandler:(void (^) (NSURL* newResource, NSArray *xmlResponse, NSError* anError))aCompletionHandler
{
    [self createResource:resourceXML atLocation:resourceURL resourceKey:aResourceKey continuationHandler:^(SSHttpFetcher *http, NSURL *newResource, NSError *anError) {
        NSArray *nodeList = nil;
        if ( !anError )
        {
            if ( anXPathQuery )
            {
                nodeList = PerformXMLXPathQuery(http.data, anXPathQuery);
                if ( !nodeList || nodeList.count == 0)
                {
                    anError =  [SSErrorUtil errorWithDomain:SugarSyncClientErrorDomain code:SugarSyncErrorNoDataReturned description:[NSString stringWithFormat:@"create %@ failed", aResourceKey] reason:[self errorMessageForCode:SugarSyncErrorNoDataReturned]];
                    
                    [self logErrorWithHttpResponse:anError responseData:http.data];
                }
            }
        }
        aCompletionHandler(newResource, nodeList, anError);
        
        
    }];
}


-(void) createResource:(NSString *)resourceXML atLocation:(NSURL *)resourceURL resourceKey:(NSString *)aResourceKey continuationHandler:(void (^) (SSHttpFetcher *http, NSURL *newResource, NSError* anError))aContinuationHandler
{
    [self refreshAccessToken:^(NSError *error) {
        if ( error )
        {
            aContinuationHandler(nil, nil, error);
        }
        else
        {
            SSHttpFetcher *http = [self fetcherForPost:resourceURL];
            __block NSURL *newResource;
            __block NSError *anError;

            [http post:resourceXML completionHandler:^{
                anError = [self parseErrorForCreateResource:http resourceKey:aResourceKey];
                
                if ( !anError )
                {
                    newResource = [NSURL URLWithString:[[http.response allHeaderFields] objectForKey:HeaderKeyLocation]];
                }
                
                aContinuationHandler(http, newResource, anError);
            }];
        }
    }];

}

#pragma mark Get Resources

-(NSError *) parseError:(SSHttpFetcher *) http resourceKey:(NSString *)aResourceKey
{
    NSError * anError = nil;
    
    if ( http.error )
    {
        anError = http.error;
    }
    else if ( http.response.statusCode > SugarSyncStatusMaxOKRange )
    {
        anError =  [SSErrorUtil errorWithDomain:SugarSyncClientErrorDomain code:http.response.statusCode description:[NSString stringWithFormat:@"the %@ operation failed", aResourceKey] reason:[self errorMessageForCode:http.response.statusCode]];
    }
    
    if ( anError )
    {
        [self logErrorWithHttpResponse:anError responseData:http.data];
    }

    return anError;
}


-(void) getResource:(NSURL *)resourceURL resourceKey:(NSString *)aResourceKey completionHandler:(void (^) (NSData *theResource, NSError* anError))aCompletionHandler
{
    [self getResource:resourceURL resourceKey:aResourceKey continuationHandler:^(SSHttpFetcher *http, NSData *theResource, NSError *anError) {
        aCompletionHandler(theResource, anError);
    }];
}

-(void) getResource:(NSURL *)resourceURL resourceKey:(NSString *)aResourceKey requiredXMLResponse:(NSString *)anXPathQuery completionHandler:(void (^) (NSData *theResource, NSArray *xmlResponse, NSError* anError))aCompletionHandler
{
    [self getResource:resourceURL resourceKey:aResourceKey continuationHandler:^(SSHttpFetcher *http, NSData *theResource, NSError *anError) {
        NSArray *nodeList = nil;
        if ( !anError )
        {
            if ( anXPathQuery )
            {
                nodeList = PerformXMLXPathQuery(http.data, anXPathQuery);
                if ( !nodeList || nodeList.count == 0)
                {
                    anError =  [SSErrorUtil errorWithDomain:SugarSyncClientErrorDomain code:SugarSyncErrorNoDataReturned description:[NSString stringWithFormat:@"get %@ failed", aResourceKey] reason:[self errorMessageForCode:SugarSyncErrorNoDataReturned]];
                    
                    [self logErrorWithHttpResponse:anError responseData:http.data];
                }
            }
        }
        aCompletionHandler(theResource, nodeList, anError);
    }];
}


-(void) getResource:(NSURL *)resourceURL resourceKey:(NSString *)aResourceKey userHeaders:(NSDictionary *) headers completionHandler:(void (^) (NSData *theResource, NSError* anError))aCompletionHandler
{
    [self refreshAccessToken:^(NSError *error) {
        if ( error )
        {
            aCompletionHandler(nil, error);
        }
        else
        {
            SSHttpFetcher *http = [self fetcher:resourceURL];
            __block NSError *anError;
            
            [headers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                [http setHeaderValue:obj forKey:key];
            }];
            
            [http get:^{
                anError = [self parseError:http resourceKey:aResourceKey];
                
                aCompletionHandler(http.data, anError);
            }];
        }
    }];
}

-(void) getResource:(NSURL *)resourceURL resourceKey:(NSString *)aResourceKey continuationHandler:(void (^) (SSHttpFetcher *http, NSData *theResource, NSError* anError))aContinuationHandler
{
    [self refreshAccessToken:^(NSError *error) {
        if ( error )
        {
            aContinuationHandler(nil, nil, error);
        }
        else
        {
            SSHttpFetcher *http = [self fetcher:resourceURL];
            __block NSError *anError;
            
            [http get:^{
                anError = [self parseError:http resourceKey:aResourceKey];
                
                aContinuationHandler(http, http.data, anError);
            }];
        }
    }];
}
#pragma mark Update Resources

-(void) updateResource:(NSString *)resourceXML atLocation:(NSURL *)resourceURL resourceKey:(NSString *)aResourceKey completionHandler:(void (^) (NSError* anError))aCompletionHandler
{
    [self refreshAccessToken:^(NSError *error) {
        if ( error )
        {
            aCompletionHandler(error);
        }
        else
        {
            SSHttpFetcher *http = [self fetcherForPut:resourceURL];
            __block NSError *anError;
            
            [http put:resourceXML completionHandler:^{
                anError = [self parseError:http resourceKey:aResourceKey];
                
                aCompletionHandler(anError);
            }];
        }
    }];

}

-(void) updateResource:(NSString *)resourceXML atLocation:(NSURL *)resourceURL resourceKey:(NSString *)aResourceKey requiredXMLResponse:(NSString *)anXPathQuery completionHandler:(void (^) (NSData *theResource, NSArray *xmlResponse, NSError* anError))aCompletionHandler
{
    [self refreshAccessToken:^(NSError *error) {
        if ( error )
        {
            aCompletionHandler(nil, nil, error);
        }
        else
        {
            SSHttpFetcher *http = [self fetcherForPut:resourceURL];
            
            [http put:resourceXML completionHandler:^{
                NSError *anError = [self parseError:http resourceKey:aResourceKey];
                NSArray *nodeList = nil;
                
                if ( !anError )
                {
                    if ( anXPathQuery )
                    {
                        nodeList = PerformXMLXPathQuery(http.data, anXPathQuery);
                        if ( !nodeList || nodeList.count == 0)
                        {
                            anError =  [SSErrorUtil errorWithDomain:SugarSyncClientErrorDomain code:SugarSyncErrorNoDataReturned description:[NSString stringWithFormat:@"update %@ failed", aResourceKey] reason:[self errorMessageForCode:SugarSyncErrorNoDataReturned]];
                            
                        }
                    }

                }
                
                aCompletionHandler(http.data, nodeList, anError);
            }];
        }
    }];
    
}

-(void) updateResourceBinary:(NSData *)resourceBytes atLocation:(NSURL *)resourceURL resourceKey:(NSString *)aResourceKey completionHandler:(void (^) (NSError* anError))aCompletionHandler
{
    [self refreshAccessToken:^(NSError *error) {
        if ( error )
        {
            aCompletionHandler(error);
        }
        else
        {
            SSHttpFetcher *http = [self fetcherForPut:resourceURL];
            __block NSError *anError;
            
            [http putBinary:resourceBytes completionHandler:^{
                anError = [self parseError:http resourceKey:aResourceKey];
                
                aCompletionHandler(anError);
            }];
        }
    }];
    
}

#pragma mark Delete Resources

-(void) deleteResource:(NSURL *)aURL resourceKey:(NSString *)aResourceKey completionHandler:(void (^) (NSError* anError))aCompletionHandler
{
    [self refreshAccessToken:^(NSError *error) {
        if ( error )
        {
            aCompletionHandler(error);
        }
        else
        {
            SSHttpFetcher *http = [self fetcherForDelete:aURL];
            __block NSError *anError;
            
            [http delete:^{
                anError = [self parseError:http resourceKey:aResourceKey];
                
                aCompletionHandler(anError);
            }];
        }
    }];
}

#pragma mark Utility

-(SSHttpFetcher *) fetcher:(NSURL *)aURL
{
    SSHttpFetcher *http = [[[SSHttpFetcher alloc] initWithURL:aURL] autorelease];
    
    [http setHeaderValue:accessToken.description forKey:HeaderKeyAuthorization];
    [http setHeaderValue:applicationUserAgent forKey:HeaderKeyUserAgent];
    
    return http;
    
}

-(SSHttpFetcher *) fetcherForPost:(NSURL *)aURL
{
    SSHttpFetcher *http = [[[SSHttpFetcher alloc] initWithURL:aURL] autorelease];
    
    if ( accessToken )
    {
        [http setHeaderValue:accessToken.description forKey:HeaderKeyAuthorization];
    }
    
    [http setHeaderValue:applicationUserAgent forKey:HeaderKeyUserAgent];
    [http setHeaderValue:HeaderValueContentType forKey:HeaderKeyContentType];
    
    return http;
    
}

-(SSHttpFetcher *) fetcherForPut:(NSURL *)aURL
{
    return [self fetcherForPost:aURL];
}

-(SSHttpFetcher *) fetcherForDelete:(NSURL *)aURL
{
    return [self fetcherForPost:aURL];
}

-(NSString *) errorMessageForCode:(long)aCode
{
    NSString *errorMessage = nil;
    
    switch (aCode) {
        case SugarSyncErrorBadRequest:
            errorMessage = @"The request was malformed (error 400)";
            break;
        case SugarSyncErrorAuthorizationRequired:
            errorMessage = @"Authorization required (error 401)";
            break;
        case SugarSyncErrorForbidden:
            errorMessage = @"Access denied (error 403)";
            break;
        case SugarSyncErrorNotAcceptable:
            errorMessage = @"The parameters were incorrect (error 406)";
            break;
        case SugarSyncErrorNotFound:
            errorMessage = @"The resource was not found (error 404)";
            break;
        case SugarSyncErrorServerError:
            errorMessage = @"The server encountered an error (error 500)";
            break;
        //this is a made up error code in case we get OK from the server but the data expected is not there
        case SugarSyncErrorNoDataReturned:
            errorMessage = @"Data was expected but not returned by the server (error 699)";
            break;
        default:
            errorMessage = [NSString stringWithFormat:@"Unable to complete the operation (error %ld)", aCode];
            
    }
    
    return errorMessage;
}

-(void) logError:(NSError *)anError
{
    [SSC9Log format:@"Error code %ld, %@, (%@)", anError.code, anError.localizedDescription, anError.localizedFailureReason];
}

-(void) logErrorWithHttpResponse:(NSError *)anError responseData:(NSData *)theData
{
    [SSC9Log format:@"Error code %ld, %@, (%@)", anError.code, anError.localizedDescription, anError.localizedFailureReason];
    [SSC9Log log:[SSHttpFetcher resultToString:theData]];
}


@end
