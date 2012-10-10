//
//  KeychainSupport.h
//  SugarSyncOSX
//
//  Created by Bill Culp on 9/1/12.
//  Copyright (c) 2012 Cloud9. All rights reserved.
//

#ifndef SugarSyncOSX_KeychainSupport_h
#define SugarSyncOSX_KeychainSupport_h

#include <CoreFoundation/CoreFoundation.h>
#include <Security/Security.h>
#include <CoreServices/CoreServices.h>

OSStatus StorePasswordKeychain (void* serviceName, UInt32 serviceNameLength, void* accountName, UInt32 accountNameLength, void* password,UInt32 passwordLength);
OSStatus GetPasswordKeychain (void* serviceName, UInt32 serviceNameLength, void* accountName, UInt32 accountNameLength, void *passwordData,UInt32 *passwordLength,
                              SecKeychainItemRef *itemRef);

OSStatus ChangePasswordKeychain (SecKeychainItemRef itemRef);

#endif
