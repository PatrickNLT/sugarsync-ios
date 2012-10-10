//
//  GenericFormatter.m
//
//  Created by Bill Culp on 8/7/12.
//  Copyright (c) 2012 Cloud9. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.


#import "SSGenericFormatter.h"

@implementation SSGenericFormatter {
    NSObject<ValidationDelegate> *delegate;
}


-(id) initWithValidationDelegate:(NSObject<ValidationDelegate> *)aDelegate andTextField:(NSTextField *)aTextField
{
    self = [super init];
    delegate = aDelegate;
    self.textField = aTextField;
    aTextField.formatter = self;
    return self;
}


- (NSString *)stringForObjectValue:(id)object {
    return (NSString *)object;
}

- (BOOL)getObjectValue:(id *)object forString:(NSString *)string errorDescription:(NSString **)error {
    *object = string;
    return YES;
}

- (BOOL)isPartialStringValid:(NSString **)partialStringPtr
       proposedSelectedRange:(NSRangePointer)proposedSelRangePtr
              originalString:(NSString *)origString
       originalSelectedRange:(NSRange)origSelRange
            errorDescription:(NSString **)error {
    
    BOOL oldIsValid = _isValid;
    
    if ( self.disallowedValues )
    {
        if ([*partialStringPtr rangeOfCharacterFromSet:self.disallowedValues].location != NSNotFound) {
            
            return NO;
        }
    }
    
    if ( self.allowedValues )
    {
        if ([*partialStringPtr rangeOfCharacterFromSet:self.disallowedValues].location == NSNotFound) {
            
            return NO;
        }
        
    }
    
    if ( self.maxLength > 0 )
    {
        if ( [*partialStringPtr length] > self.maxLength )
        {
            return NO;
        }
        
    }
    
    if ( [*partialStringPtr length] > self.minLength )
    {
        _isValid = YES;
    }
    else
    {
        _isValid = NO;
    }
    
    if ( oldIsValid != _isValid )
    {
        [delegate performSelector:@selector(revalidate:) withObject:self afterDelay:.2];
    }
    
    return YES;
    
}

- (NSAttributedString *)attributedStringForObjectValue:(id)anObject withDefaultAttributes:(NSDictionary *)attributes {
    return nil;
}

@end
