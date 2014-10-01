//
//  EventActions.m
//  Mockingbird Event Handling
//
//  Created by Evan Coyne Maloney on 7/1/13.
//  Copyright (c) 2013 Gilt Groupe. All rights reserved.
//

#import <MBDataEnvironment/MBDataEnvironment.h>

#import "EventActions.h"
#import "MBEventHandlingConstants.h"

#define DEBUG_LOCAL         0

/******************************************************************************/
#pragma mark -
#pragma mark MBPostEventAction implementation
/******************************************************************************/

@implementation MBPostEventAction

/******************************************************************************/
#pragma mark Data model enforcement
/******************************************************************************/

+ (NSSet*) requiredAttributes
{
    return [NSSet setWithObject:kMBMLAttributeName];
}

- (BOOL) acceptsArbitraryAttributes
{
    return YES;
}

/******************************************************************************/
#pragma mark Action implementation
/******************************************************************************/

- (void) executeForEvent:(NSNotification*)event
{
    NSString* eventName = [self evaluateAsString:kMBMLAttributeName];
    
#if DEBUG_MODE
    NSMutableString* debugMsg = [NSMutableString stringWithFormat:@"Posting event: %@", event.name];
    if (event.object) {
        [debugMsg appendFormat:@"; object: %@", event.object];
    }
    if (event.userInfo) {
        [debugMsg appendFormat:@"; userInfo: %@", event.userInfo];
    }
    debugLog(@"%@", debugMsg);
#endif
    
    MBScopedVariables* scope = nil;
    if (self.countAttributes > 1) {
        NSSet* standardEventAttrs = [MBListenerAction supportedAttributes];
        for (NSString* attrName in [self attributeNames]) {
            if (![attrName isEqualToString:kMBMLAttributeName] && ![standardEventAttrs containsObject:attrName]) {
                if (!scope) {
                    scope = [MBScopedVariables new];
                }
                [scope setScopedVariable:attrName value:[self evaluateAsObject:attrName]];
            }
        }
    }
    
    id sender = event.object;
    if (sender) {
        [MBEvents postEvent:eventName fromSender:sender];
    } else {
        [MBEvents postEvent:eventName];
    }
    
    if (scope) {
        [scope unsetScopedVariables];
    }
}

@end
