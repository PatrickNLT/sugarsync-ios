SugarSyncSDK
============

Objective C framework for the Sugar Sync API on iOS

see https://www.sugarsync.com/developer

For a description of the SugarSync REST API.

Installation into a cocoa project (iOS)
=======================================

In XCode

Add the framework to your project build<br/> 
Add a copy files build phase to copy the framework to the Frameworks directory
(Even though iOS doesnt expect bundles in the Frameworks directory this is
where internal resources to SugarSyncSDK will be loaded from)

Using the library
========================================
```objc
#import <SugarSyncSDK/SugarSyncClient.h>

SugarSyncClient *sugarSyncClient = [SugarSyncClient createWithApplicationId:anAppId
                                                                  accessKey:anAccessKey
                                                           privateAccessKey:aPrivAccessKey
                                                                  userAgent:aUserAgent];
                                                                  
if ( !sugarSyncClient.isLoggedIn )
    {
        [sugarSyncClient displayLoginDialogWithCompletionHandler:^(SugarSyncLoginStatus aStatus, NSError *error) {
        
        //Shows a modal login view
        

see https://www.sugarsync.com/developer for information on how to use the API

```
           