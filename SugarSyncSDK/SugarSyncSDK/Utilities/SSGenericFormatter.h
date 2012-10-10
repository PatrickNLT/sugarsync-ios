//
//  GenericFormatter.h
//
//  Created by Bill Culp on 10/28/10.
//  Copyright Cloud9 All rights reserved
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.

#import <Foundation/Foundation.h>

@protocol ValidationDelegate;

@interface SSGenericFormatter : NSFormatter

@property (nonatomic, retain) NSCharacterSet *disallowedValues;
@property (nonatomic, retain) NSCharacterSet *allowedValues;
@property (nonatomic, retain) NSString *regex;
@property (nonatomic, assign) int maxLength;
@property (nonatomic, assign) int minLength;
@property (nonatomic, assign, readonly) BOOL isValid;
@property (nonatomic, assign) NSTextField *textField;

-(id) initWithValidationDelegate:(NSObject<ValidationDelegate> *) aDelegate andTextField:(NSTextField *)aTextField;

@end

@protocol ValidationDelegate

@required -(void) revalidate:(SSGenericFormatter *)sender;

@end
