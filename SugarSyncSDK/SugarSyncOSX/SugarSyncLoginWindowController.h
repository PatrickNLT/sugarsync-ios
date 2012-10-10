//
//  SugarSyncLoginWindowController.h
//
//  Created by Bill Culp on 8/26/12.
//  Copyright (c) 2012 Cloud9. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.

#import <Cocoa/Cocoa.h>
#import "SugarSyncClient.h"
#import "SSGenericFormatter.h"

/*
 *  SugarSyncLoginWindowController display a modal login dialog to all the user to login to 
 *  SugarSync with userName and password credentials
 */
@interface SugarSyncLoginWindowController : NSWindowController<NSWindowDelegate, ValidationDelegate>

@property (nonatomic, assign) IBOutlet NSTextField *userNameField;
@property (nonatomic, assign) IBOutlet NSTextField *passwordField;
@property (nonatomic, assign) IBOutlet NSButton *loginButton;
@property (nonatomic, assign) IBOutlet NSTextField *error;
@property (nonatomic, assign) SugarSyncClient *client;
@property (nonatomic, retain) void (^completionHandler)(SugarSyncLoginStatus, NSError*);

-(IBAction)login:(id)sender;
-(IBAction)cancel:(id)sender;


@end
