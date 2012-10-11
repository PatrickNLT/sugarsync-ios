//
//  SugarSyncClient.h
//
//  Created by Bill Culp on 8/26/12.
//  Copyright (c) 2012 Cloud9. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.

#import <Foundation/Foundation.h>
#import "SugarSyncAlbum.h"
#import "SugarSyncUser.h"
#import "SugarSyncCollection.h"
#import "SugarSyncFile.h"
#import "SugarSyncUser.h"
#import "SugarSyncFolder.h"
#import "SugarSyncFileVersion.h"
#import "SugarSyncReceivedShare.h"
#import "SugarSyncWorkspace.h"
#import "SugarSyncContact.h"

/*
 * Possible Login Statuses
 */
typedef enum {
    SugarSyncLoginCancelled=0,
    SugarSyncLoginError,
    SugarSyncLoginSuccess
} SugarSyncLoginStatus;


/*
 *  Objective C OS X Client for the SugarSync REST API
 * 
 *  This Client supports the documented functionality at https://www.sugarsync.com/developer
 *
 *  Some functionality has not been documented such as PublicLinks and RecentActivities...
 *  No attempt to go beyond the public spec is included here even though the returned XML could
 *  be easily transformed into typed collection entities.  
 *
 *  Pagination for collection results is also not supported in this version.
 *
 */
@interface SugarSyncClient : NSObject


/*
 * Used to create the singleton instance of the SugarSyncClient
 * May only be called once.
 */
+(SugarSyncClient *) createWithApplicationId:(NSString *)anApplicationId accessKey:(NSString *)anAccessKey privateAccessKey:(NSString *)aPrivateAccessKey
                  userAgent:(NSString *)aUserAgent;

/*
 * After creation of the client this method can be used to retrieve the singleton any time after
 */
+(SugarSyncClient *) sharedInstance;

/*
 * The single SugarSyncUser instance returned from the authentication process
 */
@property (nonatomic, retain, readonly) SugarSyncUser *sugarSyncUser;

/*
 * Check this property to determine whether to prompt the user to login to their SugarSync account
 */
@property (nonatomic, readonly, getter = loggedIn) BOOL isLoggedIn;

/*
 * Displays a modal dialog window in an OS X Cocoa application to prompt for user name and password
 */
-(void) displayLoginDialogWithCompletionHandler:(void (^)(SugarSyncLoginStatus aStatus, NSError *error))handler;

/*
 * The login dialog will automatically call this method but it is provided for convenience if needed
 */
-(void) loginWithUserName:(NSString *) aUserName password:(NSString *)aPassword
        completionHandler:(void (^)(SugarSyncLoginStatus aStatus, NSError *error))handler;

/*
 * Get the SugarSyncUser which contains root URLs for the user account data
 */
-(void) getUserWithCompletionHandler:(void (^)(SugarSyncUser *aUser, NSError *error))handler;

/*
 *  Return a generic SugarSyncCollection object from SugarSyncAPI - Collections can represent Workspaces, Folders, SyncFolders and Albums
 *  The URL passed in a the URL of the resource collection retrieved from the SugarSyncUser instance or another call to the API
 */
-(void) getCollectionWithURL:(NSURL *) aURL completionHandler:(void (^)(NSArray *aCollection, NSError *error))handler;

/*
 * Return a specific SugarSyncWorkspace object from the SugarSync API - 
 * If the workspace at the URL provided does not exist an error with be returned
 */
-(void) getWorkspaceWithURL:(NSURL *) aURL completionHandler:(void (^)(SugarSyncWorkspace *aWorkspace, NSError *error))handler;


/*
 * Update a SugarSyncWorkspace - Note only displayName is updateable.  
 * The Workspace param should have been retrieved from a previous call to getWorkspaceWithURL
 */
-(void) updateWorkspace:(SugarSyncWorkspace *) aWorkspace completionHandler:(void (^)(NSError *error))handler;

/*
 * Get the metadata for a folder represented by SugarSyncFolder
 * The URL parameter should have been retrieved in a previous call to the API
 * If the folder does not exist an error will be returned.
 */
-(void) getFolderWithURL:(NSURL *) aURL completionHandler:(void (^)(SugarSyncFolder *aFolder, NSError *error))handler;

/*
 * Get the contents of a folder.  This will return a list of SugarSyncCollection objects of type Folder,
 * followed by any files represented by SugarSyncFile - note that the folders are NOT represented here by 
 * class SugarSyncFolder. 
 */
-(void) getFolderContentsWithURL:(NSURL *) aURL completionHandler:(void (^)(NSArray *theFolderContents, NSError *error))handler;

/*
 * Create a folder in another folder - Note that you must pass in the Folder URL for the location
 * You cannot create a folder directly in a Workspace.  The callback will return the resource URL for
 * the newly created folder
 */
-(void) createFolderNamed:(NSString*)aName parentFolderURL:(NSURL *) aURL
        completionHandler:(void (^)(NSURL *newFolderURL, NSError *error))handler;


/*
 * Delete a folder using a URL retrieved from a previous call to the API
 *
 * It is not recommended to use this method as orphaned files may result
 * Make sure to prompt the user and delete files and subfolders recursively
 * before doing this.  Best practice is to move files to the trash instead
 * to allow the user to recover them.
 */
-(void) deleteFolderWithURL:(NSURL *) aURL completionHandler:(void (^)(NSError *error))handler;


/*
 * Update a folder retrieved from a previous call to the getFolderWithURL method
 * Only display name is updateable
 */
-(void) updateFolder:(SugarSyncFolder *)aFolder completionHandler:(void (^)(NSError *error))handler;

/*
 * Create a file in a folder - this will create a stub file at the URL of the folder provided.
 */
-(void) createFileNamed:(NSString*)aName mediaType:(NSString*)aMediaType parentFolderURL:(NSURL *) aURL
      completionHandler:(void (^)(NSURL *newFileURL, NSError *error))handler;


/*
 * Copy a file in the same folder to a new file of the provided name.
 * This method will NOT copy a file to another folder
 */
-(void) copyFileWithURL:(NSURL *)aURL parentFolderURL:(NSURL *) parentFolderURL targetFileName:(NSString *)aName
      completionHandler:(void (^)(NSURL *newFileURL, NSError *error))handler;

/*
 * Get a SugarSyncFile object from a file resource URL retrieved from a previous API call.
 * If the item does not exist and error will be returned
 */
-(void) getFileWithURL:(NSURL *)aURL completionHandler:(void (^)(SugarSyncFile *aFile, NSError *error))handler;

/*
 * Delete a file at the URL returned from a previous API call.
 * It is recommended to move the file to the trash storage so that users can recover deleted files
 * instead of using this method
 */
-(void) deleteFileWithURL:(NSURL *)aURL completionHandler:(void (^)(NSError *error))handler;


/*
 * Update a SugarSyncFile object retrieved from an earlier API call
 * Only display name, parent, public link and mediaType are updateable
 */
-(void) updateFile:(SugarSyncFile *)aFile completionHandler:(void (^)(SugarSyncFile *aFile, NSError *error))handler;


/*
 * Get the data for a file. Primary download mechanism for files - returns NSData which the caller
 * can use to save the file contents
 */
-(void) getFileDataWithURL:(NSURL *) aURL completionHandler:(void (^)(NSData *fileData, NSError *error))handler;

/*
 * Transcode an image file all values are required.
 * The API will return an image file at the required dimensions, aspect and rotation
 */
-(void) getTranscodedImageDataWithURL:(NSURL *)aURL forMediaType:(NSString *)aMediaType width:(int)width height:(int)height
                               square:(BOOL)square rotation:(int)rotation completionHandler:(void (^)(NSData *fileData, NSError *error))handler;


/*
 * Upload file data to SugarSync note that the URL must be the URL of an existing file retrieved from a previous
 * call to the API.
 */
-(void) uploadFileDataWithURL:(NSURL *)aURL fileData:(NSData *)fileData completionHandler:(void (^)(NSError *error))handler;


/*
 * Get a SugarSyncFileVersion object representing the meta data for a version of a file
 */
-(void) getFileVersionWithURL:(NSURL *)aURL completionHandler:(void (^)(SugarSyncFileVersion *aFile, NSError *error))handler;

/*
 * Get a collection of SugarSyncFileVersion objects representing the history for a file
 */
-(void) getFileVersionHistoryWithURL:(NSURL *)aURL completionHandler:(void (^)(NSArray *theVersionHistory, NSError *error))handler;

/*
 * Download a specific version of a file passing in a resource URL retrieved from a previous API call
 */
-(void) getFileVersionDataWithURL:(NSURL *)aURL completionHandler:(void (^)(NSData *fileData, NSError *error))handler;

/*
 * Upload file data for a specific version of a file passing in a resource URL retrieved from a previous API call
 */
-(void) uploadFileVersionDataWithURL:(NSURL *)aURL fileData:(NSData *)fileData completionHandler:(void (^)(NSError *error))handler;

/*
 * Create a new version of a file passing in the resource URL of the file.
 */
-(void) createFileVersionWithURL:(NSURL *)aURL completionHandler:(void (^)(NSURL *newFileVersionURL, NSError *error))handler;

/*
 * Get the receivedShares for a users account using the URL from the SugarSyncUser object
 * returns an NSArray of SugarSyncReceivedShare objects
 */
-(void) getReceivedSharesWithURL:(NSURL *)aURL completionHandler:(void (^)(NSArray *theShares, NSError *error))handler;

/*
 * Get a SugarSyncReceivedShare object from a URL previously retrieved from the API
 * If the share does not exist an error will be returned
 */
-(void) getReceivedShareWithURL:(NSURL *)aURL completionHandler:(void (^)(SugarSyncReceivedShare *aReceivedShare, NSError *error))handler;

/*
 * Get a SugarSyncContact from a URL retrieved previously from the API
 */
-(void) getContactWithURL:(NSURL *)aURL completionHandler:(void (^)(SugarSyncContact *aContact, NSError *error))handler;

/*
 * Get a SugarSyncAlbum object using a URL retrieved from a previous API call
 * If the album does not exist an error will be returned
 */
-(void) getAlbumWithURL:(NSURL *)aURL completionHandler:(void (^)(SugarSyncAlbum *anAlbum, NSError *error))handler;

/*
 *  Get the files in a users albums using the resource URL of the album.
 *  An NSArray of SugarSyncFile objects will be returned or an error if the album does not exist.
 */
-(void) getAlbumContentsWithURL:(NSURL *)aURL completionHandler:(void (^)(NSArray *theAlbumContents, NSError *error))handler;

@end

