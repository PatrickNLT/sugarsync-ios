//
//  SugarSyncLoginViewController.m
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

@implementation SugarSyncLoginViewController

#pragma mark Cocoa Delegates

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self revalidate:nil];

}

-(void) viewDidAppear:(BOOL)animated
{
    [self.userNameField becomeFirstResponder];

}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [self performSelector:@selector(revalidate:) withObject:nil afterDelay:.5f];
    return YES;
    
}

#pragma mark ValidationDelegate

-(void) revalidate:(id)sender
{
    self.error.hidden = YES;
    
    if ( self.userNameField.text.length >=USERNAME_MIN  && self.userNameField.text.length <=USERNAME_MAX  &&
         self.passwordField.text.length >=PASSWORD_MIN  && self.passwordField.text.length <=PASSWORD_MAX )
    {
        self.loginButton.enabled = YES;
    }
    else
    {
        self.loginButton.enabled = NO;
    }
    
}


#pragma mark User Actions

-(IBAction) login:(id)sender
{
    [_client loginWithUserName:_userNameField.text password:_passwordField.text completionHandler:self.completionHandler];
    
}

-(IBAction)cancel:(id)sender
{

    [self dismissViewControllerAnimated:YES completion:nil];
    _completionHandler(SugarSyncLoginCancelled, nil);

}


#pragma mark Deallocation

-(void) dealloc
{
    self.completionHandler = nil;
    [super dealloc];
}



@end
