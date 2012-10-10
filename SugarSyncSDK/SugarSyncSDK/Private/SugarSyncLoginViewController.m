//
//  SugarSyncLoginWindowController.m
//
//  Created by Bill Culp on 8/26/12.
//  Copyright (c) 2012 Cloud9. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.


#import "SugarSyncLoginViewController.h"

static int const USERNAME_MIN = 5;
static int const USERNAME_MAX = 50;
static int const PASSWORD_MIN = 5;
static int const PASSWORD_MAX = 20;

@implementation SugarSyncLoginViewController {
    BOOL ignoreWindowWillCloseNotification;
}

#pragma mark Cocoa Delegates

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    SSGenericFormatter *userNameFormatter = [[SSGenericFormatter alloc] initWithValidationDelegate:self andTextField:self.userNameField];
    userNameFormatter.minLength = USERNAME_MIN;
    userNameFormatter.maxLength = USERNAME_MAX;
    
    SSGenericFormatter *passwordFormatter = [[SSGenericFormatter alloc] initWithValidationDelegate:self andTextField:self.passwordField];
    passwordFormatter.minLength = PASSWORD_MIN;
    passwordFormatter.maxLength = PASSWORD_MAX;
    
    [userNameFormatter release];
    [passwordFormatter release];
    
    [self revalidate:nil];

}

-(void) viewWillDisappear:(BOOL)animated
{
    if ( !ignoreWindowWillCloseNotification )
    {
        _completionHandler(SugarSyncLoginCancelled, nil);
    }
            
}

#pragma mark ValidationDelegate

-(void) revalidate:(SSGenericFormatter *)sender
{
    self.error.hidden = YES;
    /*if ( ((SSGenericFormatter *)self.userNameField.formatter).isValid &&
        ((SSGenericFormatter *)self.passwordField.formatter).isValid )
    {
        self.loginButton.enabled = YES;
    }
    else
    {
        self.loginButton.enabled = NO;
    }
*/
    
}


#pragma mark User Actions

-(IBAction) login:(id)sender
{
    [_client loginWithUserName:_userNameField.text password:_passwordField.text completionHandler:self.completionHandler];
    
}

-(IBAction)cancel:(id)sender
{
    //[self close];
    _completionHandler(SugarSyncLoginCancelled, nil);

}


#pragma mark Deallocation

-(void) dealloc
{
    self.completionHandler = nil;
    [super dealloc];
}



@end
