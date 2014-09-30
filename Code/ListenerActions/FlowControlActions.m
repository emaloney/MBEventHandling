//
//  FlowControlActions.m
//  Mockingbird Event Handling
//
//  Created by Evan Coyne Maloney on 2/24/14.
//  Copyright (c) 2014 Gilt Groupe. All rights reserved.
//

#import <MBToolbox/NSString+MBIndentation.h>

#import "FlowControlActions.h"
#import "MBEventHandlingConstants.h"

#define DEBUG_LOCAL                     0

/******************************************************************************/
#pragma mark -
#pragma mark MBBreakAction implementation
/******************************************************************************/

@implementation MBBreakAction

+ (NSSet*) requiredAttributes
{
    return [NSSet setWithObject:kMBMLAttributeIf];
}

+ (NSSet*) unsupportedAttributes
{
    return [NSSet setWithObject:kMBMLAttributeAfterDelay];
}

- (void) eventReceived:(NSNotification*)event
            byListener:(MBEventListener*)listener
             container:(MBEventHandlerContainer*)container
{
    debugTrace();
    
    container.flowControlState = MBFlowControlStateBreak;
}

@end

/******************************************************************************/
#pragma mark -
#pragma mark MBAssertAction implementation
/******************************************************************************/

@implementation MBAssertAction

+ (NSSet*) requiredAttributes
{
    return [NSSet setWithObject:kMBMLAttributeCondition];
}

+ (NSSet*) supportedAttributes
{
    return [NSSet setWithObject:kMBMLAttributeMessage];
}

+ (NSSet*) unsupportedAttributes
{
    return [NSSet setWithObject:kMBMLAttributeAfterDelay];
}

- (void) eventReceived:(NSNotification*)event
            byListener:(MBEventListener*)listener
             container:(MBEventHandlerContainer*)container
{
    debugTrace();
    
    NSString* message = [self evaluateAsString:kMBMLAttributeMessage];

    NSString* log = nil;
    if (message) {
        log = [NSString stringWithFormat:@"\"%@\" is false (%@)", [self stringValueOfAttribute:kMBMLAttributeCondition], message];
    } else {
        log = [NSString stringWithFormat:@"\"%@\" is false", [self stringValueOfAttribute:kMBMLAttributeCondition]];
    }
    
    BOOL keepGoing = [self evaluateAsBoolean:kMBMLAttributeCondition];
    if (!keepGoing) {
        container.flowControlState = MBFlowControlStateBreak;
        errorLog(@"Assert condition failed: %@", log);
    }
}

@end

/******************************************************************************/
#pragma mark -
#pragma mark MBWhenAction implementation
/******************************************************************************/

@implementation MBWhenAction

+ (NSSet*) requiredAttributes
{
    return [NSSet setWithObject:kMBMLAttributeIf];
}

- (void) eventReceived:(NSNotification*)event
            byListener:(MBEventListener*)listener
             container:(MBEventHandlerContainer*)container
{
    debugTrace();

    /*
     This action simply contains other actions and is invoked when the if="..."
     clause evaluates to YES. Because the processing is handled by the superclass,
     we have a rather simple implementation. There's nothing to do other than
     report that we accept the if attribute. This method implementation here
     exists only for the debugTrace() call above.
     */
    [super eventReceived:event byListener:listener container:container];
}

@end

/******************************************************************************/
#pragma mark -
#pragma mark MBCaseAction implementation
/******************************************************************************/

@implementation MBCaseAction

+ (NSSet*) requiredAttributes
{
    return [NSSet setWithObject:kMBMLAttributeIf];
}

+ (NSSet*) supportedAttributes
{
    return [NSSet setWithObject:kMBMLAttributeContinue];
}

- (BOOL) shouldHandleEvent:(NSNotification*)event
        receivedByListener:(MBEventListener*)listener
                 container:(MBEventHandlerContainer*)container
{
    debugTrace();

    if (container.flowControlState == MBFlowControlStateCaseBlockBreak) {
        return NO;
    }
    else {
        container.flowControlState = MBFlowControlStateCaseBlock;
        return [super shouldHandleEvent:event receivedByListener:listener container:container];
    }
}

- (void) eventReceived:(NSNotification*)event
            byListener:(MBEventListener*)listener
             container:(MBEventHandlerContainer*)container
{
    debugTrace();

    [super eventReceived:event byListener:listener container:container];

    BOOL shouldContinue = [self evaluateAsBoolean:kMBMLAttributeContinue];
    container.flowControlState = (shouldContinue ? MBFlowControlStateCaseBlock : MBFlowControlStateCaseBlockBreak);
}

@end

/******************************************************************************/
#pragma mark -
#pragma mark MBDefaultCaseAction class
/******************************************************************************/

@implementation MBDefaultCaseAction

+ (NSSet*) unsupportedAttributes
{
    return [NSSet setWithObject:kMBMLAttributeIf];
}

- (BOOL) shouldHandleEvent:(NSNotification*)event
        receivedByListener:(MBEventListener*)listener
                 container:(MBEventHandlerContainer*)container
{
    debugTrace();

    if (!MBFlowControlStateIsCaseBlock(container.flowControlState)) {
        errorLog(@"<%@> actions may only come after <%@> actions; the <%@> declaration within this action block is unexpected and it will not be executed:\n%@", self.xmlTagName, [MBCaseAction dataEntityName], self.xmlTagName, [container.simulatedXML stringByIndentingEachLineWithTab]);
        return NO;
    }

    BOOL retVal = [super shouldHandleEvent:event receivedByListener:listener container:container];
    if (!retVal) {
        // return to the default flow control state here, since
        // eventReceived:byListener:container: will not be executed
        container.flowControlState = MBFlowControlStateContinue;
    }

    return retVal;
}

- (void) eventReceived:(NSNotification*)event
            byListener:(MBEventListener*)listener
             container:(MBEventHandlerContainer*)container
{
    debugTrace();

    [super eventReceived:event byListener:listener container:container];

    // return to the default flow control state...
    // the <DefaultCase> always represents the last case in a chain;
    // therefore, we continue from here, which will allow a new set of <Case>
    // statements to follow a <DefaultCase>. kinda like the "default:" label
    // at the end of a set of "case:"s within a switch () { ... } statement
    container.flowControlState = MBFlowControlStateContinue;
}

@end
