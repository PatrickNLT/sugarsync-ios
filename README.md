SugarSyncSDK (v2.0.0)
============

Objective C framework for the Sugar Sync API on iOS

see https://www.sugarsync.com/developer

For a description of the SugarSync REST API.

This is a fork from the original library (https://github.com/huadee/sugarsync-ios) with a few additions:

* CocoaPods support
* Better XML writer (escapes characters)
* Few API additions (logout, sharedInstance can be used even before initialization)

TODO
====

* Implement XML body for calls needing attributes inside nodes (copyFile and updateFile). These calls are not functional for now.

Installation into a Cocoa project (iOS)
=======================================

CocoaPods (highly recommended)
-----------------------

Use the ``SugarSyncSDK`` pod from [CocoaPods](http://cocoapods.org).

Manual installation
-------------------

You can also import the files manually. If you do, please make sure that you're also importing files from [KissXML](https://github.com/robbiehanson/KissXML) and [KeychainItemWrapper](https://gist.github.com/Zyphrax/3376201). If you intend to use the login UI, add the resource files to a bundle named `SugarSyncSDK.bundle`.

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
           