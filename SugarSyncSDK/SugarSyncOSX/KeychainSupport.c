//
//  KeychainSupport.c
//  SugarSyncOSX
//
//  Created by Bill Culp on 9/1/12.
//  Copyright (c) 2012 Cloud9. All rights reserved.
//

#include "KeychainSupport.h"

//Call SecKeychainAddGenericPassword to add a new password to the keychain:
OSStatus StorePasswordKeychain (void* serviceName, UInt32 serviceNameLength, void* accountName, UInt32 accountNameLength, void* password,UInt32 passwordLength)
{
    OSStatus status;
    status = SecKeychainAddGenericPassword (
                                            NULL,              // default keychain
                                            serviceNameLength, // length of service name
                                            serviceName,       // service name
                                            accountNameLength, // length of account name
                                            accountName,       // account name
                                            passwordLength,    // length of password
                                            password,          // pointer to password data
                                            NULL               // the item reference
                                            );
    return (status);
}

//Call SecKeychainFindGenericPassword to get a password from the keychain:
OSStatus GetPasswordKeychain (void* serviceName, UInt32 serviceNameLength, void* accountName, UInt32 accountNameLength, void *passwordData,UInt32 *passwordLength,
                              SecKeychainItemRef *itemRef)
{
    OSStatus status1 ;
    
    
    status1 = SecKeychainFindGenericPassword (
                                              NULL,               // default keychain
                                              serviceNameLength,  // length of service name
                                              serviceName,        // service name
                                              accountNameLength,  // length of account name
                                              accountName,        // account name
                                              passwordLength,     // length of password
                                              passwordData,       // pointer to password data
                                              itemRef             // the item reference
                                              );
    return (status1);
}

//Call SecKeychainItemModifyAttributesAndData to change the password for
// an item already in the keychain:
OSStatus ChangePasswordKeychain (SecKeychainItemRef itemRef)
{
    OSStatus status;
    void * password = "myNewP4sSw0rD";
    UInt32 passwordLength = (int)strlen(password);
    
    status = SecKeychainItemModifyAttributesAndData (
                                                     itemRef,         // the item reference
                                                     NULL,            // no change to attributes
                                                     passwordLength,  // length of password
                                                     password         // pointer to password data
                                                     );
    return (status);
}
