//
//  EnvironmentActions.m
//  Mockingbird Event Handling
//
//  Created by Evan Coyne Maloney on 7/1/13.
//  Copyright (c) 2013 Gilt Groupe. All rights reserved.
//

#import <MBDataEnvironment/MBDataEnvironment.h>

#import "EnvironmentActions.h"
#import "MBEventHandlingConstants.h"

#define DEBUG_LOCAL         0

/******************************************************************************/
#pragma mark -
#pragma mark MBSetEnvironmentInfoAction implementation
/******************************************************************************/

@implementation MBSetEnvironmentInfoAction

/******************************************************************************/
#pragma mark Data model enforcement
/******************************************************************************/

- (BOOL) acceptsArbitraryAttributes
{
    return YES;
}

/******************************************************************************/
#pragma mark Action implementation
/******************************************************************************/

- (void) executeForEvent:(NSNotification*)event
{
    debugTrace();
    
    MBEnvironment* env = [MBEnvironment instance];
    for (NSString* key in [self attributeNames]) {
        if (![key isEqualToString:kMBMLAttributeIf]) {
            @try {
                [env setAttribute:self[key] forName:key];
            }
            @catch (NSException* ex) {
                errorLog(@"The <%@> action failed to set environment info for key \"%@\": %@", self.xmlTagName, key, [ex callStackSymbols]);
            }
        }
    }
}

@end

/******************************************************************************/
#pragma mark -
#pragma mark MBLoadTemplateAction implementation
/******************************************************************************/

@implementation MBLoadTemplateAction

/******************************************************************************/
#pragma mark Data model enforcement
/******************************************************************************/

+ (NSSet*) requiredAttributes
{
    return [NSSet setWithObject:kMBMLAttributeFile];
}

+ (NSSet*) supportedAttributes
{
    return [NSSet setWithObject:kMBMLAttributeForceReload];
}

/******************************************************************************/
#pragma mark Action implementation
/******************************************************************************/

- (void) executeForEvent:(NSNotification*)event
{
    debugTrace();
    
    MBEnvironment* env = [MBEnvironment instance];
    
    NSString* file = [self evaluateAsString:kMBMLAttributeFile];
    if (file) {
        if (![env mbmlFileIsLoaded:file] || [self evaluateAsBoolean:kMBMLAttributeForceReload]) {
            if (![env loadTemplateFile:file]) {
                errorLog(@"The <%@> action failed to load %@ for: %@", self.xmlTagName, file, self.simulatedXML);
            }
        }
    }
}

@end

/******************************************************************************/
#pragma mark -
#pragma mark MBCheckCanOpenURLAction implementation
/******************************************************************************/

@implementation MBCheckCanOpenURLAction

/******************************************************************************/
#pragma mark Data model enforcement
/******************************************************************************/

+ (NSSet*) requiredAttributes
{
    return [NSSet setWithObjects:kMBMLAttributeURL, kMBMLAttributeVar, nil];
}

/******************************************************************************/
#pragma mark Action implementation
/******************************************************************************/

- (void) executeForEvent:(NSNotification*)event
{
    debugTrace();
    
    NSString* urlStr = [self evaluateAsString:kMBMLAttributeURL];
    NSString* var = [self stringValueOfAttribute:kMBMLAttributeVar];
    
    if (urlStr && var) {
        NSURL* url = [NSURL URLWithString:urlStr];
        BOOL canOpen = NO;
        if (url) {
            canOpen = [[UIApplication sharedApplication] canOpenURL:url];
        }
        else {
            errorLog(@"The <%@> could not interpret the value of the %@ attribute (\"%@\" from expression: \"%@\") as a valid URL", self.xmlTagName, kMBMLAttributeURL, [self evaluateAsString:kMBMLAttributeURL], self[kMBMLAttributeURL]);
        }
        NSString* varValue = [MBExpression stringFromBoolean:canOpen];
        [[MBVariableSpace instance] setVariable:var value:varValue];
    }
}

@end

