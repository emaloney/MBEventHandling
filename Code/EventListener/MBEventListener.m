//
//  MBEventListener.m
//  Mockingbird Library
//
//  Created by Evan Coyne Maloney on 4/12/13.
//  Copyright (c) 2013 Gilt Groupe. All rights reserved.
//

#import <RaptureXML@Gilt/RXMLElement.h>
#import <MBToolbox/NSString+MBIndentation.h>
#import <MBDataEnvironment/MBScopedVariables.h>
#import <MBDataEnvironment/MBExpression.h>
#import <MBDataEnvironment/MBVariableSpace.h>
#import <MBDataEnvironment/MBEnvironment.h>

#import "MBEventListener.h"
#import "FlowControlActions.h"
#import "MBEventHandlingConstants.h"

#define DEBUG_LOCAL                     0
#define DEBUG_VERBOSE                   0
#define DEBUG_TRACE_ALL_ACTIONS         0
#define DEBUG_TRACE_PROFILE_ACTIONS     0

/******************************************************************************/
#pragma mark Constants
/******************************************************************************/

NSString* const kMBMLActionTag                          = @"Action";
NSString* const kMBEventListenerNotificationVariable    = @"Event";
NSString* const kMBEventListenerTraceActionsVariable    = @"Debug:traceActions";

/******************************************************************************/
#pragma mark -
#pragma mark MBEventHandler implementation
/******************************************************************************/

@implementation MBEventHandler

/******************************************************************************/
#pragma mark Data model support
/******************************************************************************/

+ (NSString*) dataEntityName
{
    NSString* name = [super dataEntityName];
    if ([name hasSuffix:kMBMLActionTag]) {
        name = [name substringToIndex:name.length - 6];
    }
    return name;
}

/******************************************************************************/
#pragma mark Data model enforcement
/******************************************************************************/

+ (NSSet*) supportedAttributes
{
    return [NSSet setWithObjects:kMBMLAttributeTrace,
            kMBMLAttributeIf,
            nil];
}

/******************************************************************************/
#pragma mark Class lookup
/******************************************************************************/

+ (Class) classForEventHandler:(NSString*)eventHandlerName
{
    Class cls = [MBEnvironment libraryClassForName:[eventHandlerName stringByAppendingString:kMBMLActionTag]];
    if (![cls isSubclassOfClass:[MBEventHandler class]]) {
        return nil;
    }
    return cls;
}

/******************************************************************************/
#pragma mark Event handling
/******************************************************************************/

- (BOOL) shouldHandleEvent:(NSNotification*)event
        receivedByListener:(MBEventListener*)listener
                 container:(MBEventHandlerContainer*)container;
{
    return [self evaluateAsBoolean:kMBMLAttributeIf defaultValue:YES];
}

- (void) eventReceived:(NSNotification*)event
            byListener:(MBEventListener*)listener
             container:(MBEventHandlerContainer*)container
{
    MBErrorNotImplemented();
}

- (BOOL) traceExecution
{
    if (_traceExecution)
        return YES;

    if ([self evaluateAsBoolean:kMBMLAttributeTrace])
        _traceExecution = YES;

    if ([MBExpression booleanFromValue:[[MBVariableSpace instance] variableForName:kMBEventListenerTraceActionsVariable]])
        _traceExecution = YES;

    return _traceExecution;
}

@end

/******************************************************************************/
#pragma mark -
#pragma mark MBEventHandlerContainer class
/******************************************************************************/

@implementation MBEventHandlerContainer

/******************************************************************************/
#pragma mark Data model enforcement
/******************************************************************************/

- (Class) implementingClassForRelativeOfType:(NSString*)relationType fromTag:(NSString*)tag
{
    return [MBEventHandler classForEventHandler:tag];
}

/******************************************************************************/
#pragma mark Property handling
/******************************************************************************/

- (NSArray*) eventHandlers
{
    return [self relativesWithDefaultRelation];
}

- (void) _executeHandler:(MBEventHandler*)handler
             inContainer:(MBEventHandlerContainer*)container
        triggeredByEvent:(NSNotification*)event
      receivedByListener:(MBEventListener*)listener
              afterDelay:(NSTimeInterval)delay
{
    NSString* traceID = nil;
    BOOL trace = self.traceExecution || handler.traceExecution;
    BOOL traceBlock = NO;
    if (trace) {
        traceID = [listener traceIdentifierForEvent:event];

        NSString* delayStr = @"";
        if (delay > 0) {
            delayStr = [NSString stringWithFormat:@" after %g second delay", delay];
        }

        traceBlock = [handler isKindOfClass:[MBEventHandlerContainer class]];
        if (traceBlock) {
            NSLog(@"--> %@ -- Entered <%@> block%@:\n%@", traceID, handler.xmlTagName, delayStr, [handler.simulatedXML stringByIndentingEachLineWithTab]);
        } else {
            NSLog(@"--> %@ -- Executing%@: %@", traceID, delayStr, handler.simulatedXML);
        }
    }

    @try {
        NSTimeInterval executionStartTime = 0;
        if (DEBUG_FLAG(DEBUG_TRACE_PROFILE_ACTIONS) && trace) {
            executionStartTime = [NSDate timeIntervalSinceReferenceDate];
        }

        [handler eventReceived:event byListener:listener container:container];

        if (traceBlock) {
            NSLog(@"--> %@ -- Exited <%@> block.", traceID, handler.xmlTagName);
        }

        if (DEBUG_FLAG(DEBUG_TRACE_PROFILE_ACTIONS) && trace) {
            NSLog(@"--> %@ -- Finished executing <%@> action in %g seconds", traceID, handler.xmlTagName, [NSDate timeIntervalSinceReferenceDate] - executionStartTime);
        }
    }
    @catch (NSException* ex) {
        errorLog(@"Exception while executing the <%@> action triggered by the event \"%@\" being handled by the listener:\n%@\n", handler.xmlTagName, event.name, [listener.simulatedXML stringByIndentingEachLineWithTab]);
        exceptionLog(ex);
    }
}

- (void) eventReceived:(NSNotification*)event
            byListener:(MBEventListener*)listener
             container:(MBEventHandlerContainer*)container
{
    NSString* traceID = nil;
    if (self.traceExecution) {
        traceID = [listener traceIdentifierForEvent:event];
    }

    self.traceExecution = self.traceExecution || container.traceExecution;

    self.flowControlState = MBFlowControlStateContinue;

    for (MBEventHandler* handler in self.eventHandlers) {
        BOOL traceThis = self.traceExecution || handler.traceExecution;
        if (traceThis && !traceID) {
            traceID = [listener traceIdentifierForEvent:event];
        }

        if ([handler shouldHandleEvent:event receivedByListener:listener container:container]) {
            NSTimeInterval delay = -1;
            if ([handler hasAttribute:kMBMLAttributeAfterDelay]) {
                delay = [[handler evaluateAsNumber:kMBMLAttributeAfterDelay] doubleValue];
            }
            if (delay < 0) {
                [self _executeHandler:handler
                          inContainer:container
                     triggeredByEvent:event
                   receivedByListener:listener
                           afterDelay:0];

                // note that we don't process flow control state below; that's
                // because actions executed after a delay can't affect flow
                if (self.flowControlState == MBFlowControlStateBreak) {
                    if (traceThis) {
                        NSLog(@"--> Skipping further actions in this block due to: %@", handler.simulatedXML);
                    }
                    return;
                }
            }
            else {
                if (traceThis) {
                    NSLog(@"--> %@ -- Will execute after %g second delay: %@", traceID, delay, self.simulatedXML);
                }

                dispatch_time_t execTime = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
                dispatch_after(execTime, dispatch_get_main_queue(), ^{
                    [self _executeHandler:handler
                              inContainer:container
                         triggeredByEvent:event
                       receivedByListener:listener
                               afterDelay:delay];
                });
            }
        }
        else {
            if (traceThis) {
                BOOL isBlock = [handler isKindOfClass:[MBEventHandlerContainer class]];
                if (!isBlock) {
                    NSLog(@"--> %@ -- Skipping: %@", traceID, handler.simulatedXML);
                } else {
                    NSLog(@"--> %@ -- Skipping <%@> block:\n%@", traceID, handler.xmlTagName, [handler.simulatedXML stringByIndentingEachLineWithTab]);
                }
            }
        }
    }
}

@end

/******************************************************************************/
#pragma mark -
#pragma mark MBEventListener implementation
/******************************************************************************/

@implementation MBEventListener

/******************************************************************************/
#pragma mark Object lifecycle
/******************************************************************************/

- (void) dealloc 
{
    if (_isListening) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

/******************************************************************************/
#pragma mark Data model support
/******************************************************************************/

+ (NSString*) dataEntityName
{
    return @"Listener";
}

+ (NSSet*) supportedAttributes
{
    return [NSSet setWithObjects:kMBMLAttributeName,
            kMBMLAttributeEvent,
            kMBMLAttributeWarnOnOverwrite,
            nil];
}

- (BOOL) validateAttributes
{
    if (![super validateAttributes]) {
        return NO;
    }

    if (!_name || !_name.length) {
        errorLog(@"Declaring an event listener without a name is no longer supported; this listener will be ignored: %@", self.simulatedXML);
        return NO;
    }
    
    NSString* eventListStr = [self valueOfAttribute:kMBMLAttributeEvent];
    if (!eventListStr) {
        eventListStr = _name;
    }
    NSArray* events = [[eventListStr evaluateAsString] componentsSeparatedByString:@","];
    NSMutableArray* eventList = [NSMutableArray arrayWithCapacity:events.count];
    for (NSString* event in events) {
        [eventList addObject:MBTrimString(event)];
    }
    if (eventList.count < 1) {
        errorLog(@"<%@>s must specify one or more comma-separated events to listen for in the \"%@\" attribute: %@", self.xmlTagName, kMBMLAttributeEvent, self.simulatedXML);
        return NO;
    }
    else {
        _events = [eventList copy];
    }
    self.traceExecution = DEBUG_FLAG(DEBUG_TRACE_ALL_ACTIONS) || [self evaluateAsBoolean:kMBMLAttributeTrace];
    
    return YES;
}

/******************************************************************************/
#pragma mark Debugging support
/******************************************************************************/

- (NSString*) debugDescriptor
{
    NSMutableString* desc = [NSMutableString stringWithString:@"<"];
    [desc appendString:self.xmlTagName];

    NSString* name = self.name;
    if (name) {
        [desc appendString:@" name=\""];
        [desc appendString:name];
        [desc appendString:@"\""];
    }

    [desc appendString:@">"];

    return desc;
}

- (void) addDescriptionFieldsTo:(MBFieldListFormatter*)fmt
{
    [super addDescriptionFieldsTo:fmt];

    [fmt setField:@"events" value:[self.events componentsJoinedByString:@", "]];
}

/******************************************************************************/
#pragma mark Property handling
/******************************************************************************/

- (void) setWarnOnOverwrite:(NSString*)warn
{
    verboseDebugTrace();
    
    _warnOnOverwriteSpecified = YES;
    _suppressOverwriteWarning = ![warn evaluateAsBoolean];
}

/******************************************************************************/
#pragma mark Starting/stopping listening
/******************************************************************************/

- (void) startListening
{
    debugTrace();
    
    if (!_isListening) {
        for (__strong NSString* event in self.events) {
            if ([event isEqualToString:@"*"]) {
                event = nil;        // catch-all listener
            }
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(_eventTriggered:)
                                                         name:event
                                                       object:nil];

        }
        debugLog(@"The <%@> named \"%@\" is now listening for %lu event%@: %@", self.xmlTagName, _name, (unsigned long)_events.count, (_events.count == 1 ? @"" : @"s"), [_events componentsJoinedByString:@"; "]);

        _isListening = YES;
    }
}

- (void) stopListening
{
    debugTrace();
    
    if (_isListening) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        _isListening = NO;

        debugLog(@"The <%@> named \"%@\" has stopped listening for %lu event%@: %@", self.xmlTagName, _name, (unsigned long)_events.count, (_events.count == 1 ? @"" : @"s"), [_events componentsJoinedByString:@"; "]);
    }
}

/******************************************************************************/
#pragma mark Event handling
/******************************************************************************/

- (NSString*) traceIdentifierForEvent:(NSNotification*)event
{
    NSString* eventName = event.name;
    NSString* listenerName = self.name;
    if ([eventName isEqualToString:listenerName]) {
        return [NSString stringWithFormat:@"Listener \"%@\"", listenerName];
    } else {
        return [NSString stringWithFormat:@"Listener \"%@\" handling event \"%@\"", listenerName, eventName];
    }
}

- (void) _eventTriggered:(NSNotification*)event
{
    debugTrace();

    if (![[NSThread currentThread] isMainThread]) {
        [self performSelectorOnMainThread:_cmd withObject:event waitUntilDone:NO];
        return;
    }

    NSTimeInterval listenerStartTime = 0;
    if (self.traceExecution) {
        listenerStartTime = [NSDate timeIntervalSinceReferenceDate];
    }

    BOOL ignoring = NO;
    MBScopedVariables* scope = [MBScopedVariables enterVariableScope];
    @try {
        [scope setScopedVariable:kMBEventListenerNotificationVariable value:event];

        // this check should always happen within the event's MBML
        // variable scope, so the listener's if="..." clause can
        // contain expressions referencing those variables
        if ([self shouldHandleEvent:event receivedByListener:self container:self]) {
            if (self.traceExecution) {
                NSLog(@"--> Event \"%@\" received; triggering listener:\n%@", event.name, [self.simulatedXML stringByIndentingEachLineWithTab]);
            }
            [self eventReceived:event byListener:self container:self];
        } else {
            ignoring = YES;
        }
    }
    @catch (NSException* ex) {
        errorLog(@"Exception while executing listener actions for event \"%@\": %@", event.name, [ex callStackSymbols]);
    }
    @finally {
        [MBScopedVariables exitVariableScope];
    }

    if (self.traceExecution && !ignoring) {
        NSLog(@"--> Listener \"%@\" done processing actions for \"%@\" in %g seconds", _name, event.name, [NSDate timeIntervalSinceReferenceDate] - listenerStartTime);
    }
}

@end

/******************************************************************************/
#pragma mark -
#pragma mark MBListenerAction implementation
/******************************************************************************/

@implementation MBListenerAction

/******************************************************************************/
#pragma mark Data model support
/******************************************************************************/

+ (NSSet*) supportedAttributes
{
    return [NSSet setWithObjects:kMBMLAttributeIf,
            kMBMLAttributeAfterDelay,
            nil];
}

- (void) populateDataModelFromXML:(RXMLElement*)container
{
    [super populateDataModelFromXML:container];

    if ([self acceptsTextContent]) {
        NSString* content = container.text;
        if (content.length) {
            self.content = content;
        }
    }
}

- (NSSet*) ignoredAttributes
{
    if ([self acceptsArbitraryAttributes]) {
        return nil;
    }
    else if ([self ignoresNonstandardAttributes]) {
        NSMutableSet* rejectedAttrs = [NSMutableSet setWithArray:[self attributeNames]];
        [rejectedAttrs minusSet:[MBListenerAction supportedAttributes]];
        return rejectedAttrs;
    }
    else {
        return [super ignoredAttributes];
    }
}

/******************************************************************************/
#pragma mark Configuring the action's behavior
/******************************************************************************/

- (BOOL) acceptsTextContent
{
    return NO;
}

- (BOOL) acceptsArbitraryAttributes
{
    return NO;
}

- (BOOL) ignoresNonstandardAttributes
{
    return NO;
}

@end

/******************************************************************************/
#pragma mark -
#pragma mark MBExecutableListenerAction implementation
/******************************************************************************/

@implementation MBExecutableListenerAction

/******************************************************************************/
#pragma mark Action execution
/******************************************************************************/

- (void) eventReceived:(NSNotification*)event
            byListener:(MBEventListener*)listener
             container:(MBEventHandlerContainer*)container
{
    debugTrace();
    
    [self executeForEvent:event];

    container.flowControlState = MBFlowControlStateContinue;
}

- (void) executeForEvent:(NSNotification*)event
{
    MBErrorNotImplemented();
}

- (void) execute
{
    debugTrace();

    [self executeForEvent:nil];
}

- (BOOL) validateAndExecuteForEvent:(NSNotification*)event
{
    debugTrace();

    if ([self validateDataModelIfNeeded]) {
        [self eventReceived:event byListener:nil container:nil];
        return YES;
    }
    else {
        errorLog(@"Won't execute <%@> action because it is not valid: %@", self.xmlTagName, self.simulatedXML);
    }
    return NO;
}

@end

/******************************************************************************/
#pragma mark -
#pragma mark MBDebugAction implementation
/******************************************************************************/

@implementation MBDebugAction

- (BOOL) acceptsArbitraryAttributes
{
    return YES;
}

- (void) executeForEvent:(NSNotification*)event
{
    debugTrace();
    
    for (NSString* key in [self attributeNames]) {
        if (![key isEqualToString:kMBMLAttributeIf] && ![key isEqualToString:kMBMLAttributeBreak]) {
            NSString* expr = [self stringValueOfAttribute:key];
            id val = [expr evaluateAsObject];
            if ([val isKindOfClass:[NSString class]]) {
                NSLog(@"\n\t--> <%@>: %@ resolves to %lu-char string: %@\n", self.xmlTagName, key, (unsigned long)((NSString*)val).length, val);
            }
            else if (val) {
                NSLog(@"\n\t--> <%@>: %@ resolves to %@: %@\n", self.xmlTagName, key, [val class], [val description]);
            }
            else {
                NSLog(@"\n\t--> <%@>: %@ resolves to null value\n", self.xmlTagName, key);
            }
        }
    }
    
    if ([self booleanValueOfAttribute:kMBMLAttributeBreak]) {
#if DEBUG
        NSString* msg = [NSString stringWithFormat:@"caused by: %@", self.simulatedXML];
        triggerDebugBreakMsg(msg);
#else
        NSLog(@"--> Using a %@ action to enter the debugger is only supported in debug builds.", self.xmlTagName);
#endif
    }
}

@end


