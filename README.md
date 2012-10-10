SugarSyncOSX
============

Objective C framwork for the Sugar Sync API on OSX

see https://www.sugarsync.com/developer

For a description of the SugarSync REST API.

Installation into a cocoa project (OSX)
=======================================

In XCode

Add the framework to your project build<br/> 
Add a copy files build phase to copy the framework to the Frameworks directory

Using the library
========================================
```objc
#import <SugarSyncOSX/SugarSyncOSX.h>

SugarSyncClient *sugarSyncClient = [SugarSyncClient createWithApplicationId:anAppId
                                                                  accessKey:anAccessKey
                                                           privateAccessKey:aPrivAccessKey
                                                                  userAgent:aUserAgent];
                                                                  
if ( !sugarSyncClient.isLoggedIn )
    {
        [sugarSyncClient displayLoginDialogWithCompletionHandler:^(SugarSyncLoginStatus aStatus, NSError *error) {
        
        //Shows a modal login dialog
        

see https://www.sugarsync.com/developer for information on how to use the API

```
           