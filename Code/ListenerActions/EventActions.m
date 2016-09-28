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

+ (nullable NSSet*) requiredAttributes
{
    return [NSSet setWithObject:kMBMLAttributeName];
}

+ (nullable NSSet*) supportedAttributes
{
    return [NSSet setWithObject:kMBMLAttributeObject];
}

- (BOOL) acceptsArbitraryAttributes
{
    return YES;
}

/******************************************************************************/
#pragma mark Action implementation
/******************************************************************************/

- (void) executeForEvent:(nullable NSNotification*)event
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
    MBLogDebug(@"%@", debugMsg);
#endif
    
    MBScopedVariables* scope = nil;
    if (self.countAttributes > 1) {
        NSMutableSet* mutableStdAttrs = [[[self class] requiredAttributes] mutableCopy];
        [mutableStdAttrs unionSet:[[self class] supportedAttributes]];
        [mutableStdAttrs minusSet:[[self class] unsupportedAttributes]];
        NSSet* stdAttrs = [mutableStdAttrs copy];

        for (NSString* attrName in [self attributeNames]) {
            if (![stdAttrs containsObject:attrName]) {
                if (!scope) {
                    scope = [MBScopedVariables new];
                }
                scope[attrName] = [self evaluateAsObject:attrName];
            }
        }
    }

    id object = [self evaluateAsObject:kMBMLAttributeObject];
    object = object ? object : event.object;
    if (object) {
        [MBEvents postEvent:eventName withObject:object];
    } else {
        [MBEvents postEvent:eventName];
    }
    
    if (scope) {
        [scope unsetScopedVariables];
    }
}

@end
