//
//  MBListenerManager.m
//  Mockingbird Library
//
//  Created by Evan Coyne Maloney on 8/21/12.
//  Copyright (c) 2012 Gilt Groupe. All rights reserved.
//

#import <RaptureXML@Gilt/RXMLElement.h>
#import <MBToolbox/NSString+MBIndentation.h>
#import <MBDataEnvironment/MBEnvironment.h>

#import "MBListenerManager.h"
#import "Mockingbird-EventHandling.h"
#import "MBEventListener.h"

#define DEBUG_LOCAL         0
#define DEBUG_VERBOSE       0

/******************************************************************************/
#pragma mark Constants
/******************************************************************************/

NSString* const kMBEventListenerXMLTag = @"Listener";

/******************************************************************************/
#pragma mark -
#pragma mark MBListenerManager implementation
/******************************************************************************/

@implementation MBListenerManager
{
    NSMutableArray* _pendingListeners;
    NSMutableDictionary* _nameToListener;
    NSMutableDictionary* _eventToListeners;
}

/******************************************************************************/
#pragma mark Instance vendor
/******************************************************************************/

+ (instancetype) instance
{
    return (MBListenerManager*)[[MBEnvironment instance] environmentLoaderOfClass:self];
}

/******************************************************************************/
#pragma mark Object lifecycle
/******************************************************************************/

- (id) init
{
    self = [super init];
    if (self) {
        _pendingListeners = [NSMutableArray new];
        _nameToListener = [NSMutableDictionary new];
        _eventToListeners = [NSMutableDictionary new];
    }
    return self;
}

/******************************************************************************/
#pragma mark MBML parsing
/******************************************************************************/

- (NSArray*) acceptedTagNames
{
    return @[kMBEventListenerXMLTag];
}

- (BOOL) parseElement:(RXMLElement*)mbml forMatch:(NSString*)match
{
    [self addListener:[[MBEventListener alloc] initWithXML:mbml]];
    
    return YES;
}

/******************************************************************************/
#pragma mark Adding & removing listeners
/******************************************************************************/

- (void) addListener:(MBEventListener*)newListener
{
    verboseDebugTrace();
    
    if (!self.isActive) {
        [_pendingListeners addObject:newListener];
    }
    else {
        [self _activateListener:newListener];
        if (!newListener.isListening) {
            [newListener startListening];
        }
    }
}

- (void) removeListenerWithName:(NSString*)name
{
    verboseDebugTrace();
    
    MBEventListener* listener = _nameToListener[name];
    if (listener) {
        [self removeListener:listener];
    }
}

- (void) removeListener:(MBEventListener*)listener
{
    verboseDebugTrace();

    [listener stopListening];
        
    [_nameToListener removeObjectForKey:listener.name];
    
    NSArray* events = listener.events;
    for (NSString* event in events) {
        NSMutableArray* listeners = _eventToListeners[event];
        [listeners removeObject:listener];
        if (!listeners.count) {
            [_eventToListeners removeObjectForKey:event];
        }
    }
}

- (void) removeAllListeners
{
    verboseDebugTrace();
    
    [self stopAllListeners];
    
    [_nameToListener removeAllObjects];
    [_eventToListeners removeAllObjects];
}

/******************************************************************************/
#pragma mark Accessing listeners
/******************************************************************************/

- (NSArray*) listenerNames
{
    return [_nameToListener allKeys];
}

- (MBEventListener*) listenerWithName:(NSString*)name
{
    return _nameToListener[name];
}

- (NSArray*) listenerEvents
{
    return [_eventToListeners allKeys];
}

- (NSArray*) listenersForEvent:(NSString*)event
{
    NSArray* listeners = _eventToListeners[event];
    if (listeners.count > 0) {
        return [NSArray arrayWithArray:listeners];
    }
    return nil;
}

/******************************************************************************/
#pragma mark Starting/stopping listeners
/******************************************************************************/

- (void) _activateListener:(MBEventListener*)newListener
{
    if ([newListener validateDataModelIfNeeded]) {
        NSString* name = newListener.name;
        MBEventListener* curListener = _nameToListener[name];
        if (curListener) {
            if (!curListener.suppressOverwriteWarning) {
                errorLog(@"WARNING: The event listener named \"%@\" is being overwritten!\n\n\tExisting listener: %@\tNew listener: %@\tTo avoid this warning, specify %@=\"F\" on the <%@>", name, [[curListener description] stringByIndentingEachLineWithTabs:2], [[newListener description] stringByIndentingEachLineWithTabs:2], kMBMLAttributeWarnOnOverwrite, newListener.xmlTagName);
            }
            if (!newListener.warnOnOverwriteSpecified) {
                newListener.suppressOverwriteWarning = curListener.suppressOverwriteWarning;
            }
            [self removeListener:curListener];  // this also stops the old listener
        }
        
        _nameToListener[name] = newListener;
        for (NSString* event in newListener.events) {
            NSMutableArray* listeners = _eventToListeners[event];
            if (!listeners) {
                listeners = [NSMutableArray array];
                _eventToListeners[event] = listeners;
            }
            [listeners addObject:newListener];
        }
    }
    else {
        errorLog(@"This Listener declaration isn't valid and it will therefore be ignored: %@", newListener);
    }
}

- (void) startAllListeners
{
    debugTrace();

    for (NSString* name in _nameToListener) {
        MBEventListener* listener = _nameToListener[name];
        if (!listener.isListening) {
            [listener startListening];
        }
    }
}

- (void) stopAllListeners
{
    debugTrace();
    
    for (NSString* name in _nameToListener) {
        MBEventListener* listener = _nameToListener[name];
        if (listener.isListening) {
            [listener stopListening];
        }
    }
}

/******************************************************************************/
#pragma mark Environment state change notification hooks
/******************************************************************************/

- (void) environmentWillActivate:(MBEnvironment*)env
{
    debugTrace();
    
    [super environmentWillActivate:env];
    
    for (MBEventListener* listener in _pendingListeners) {
        [self _activateListener:listener];
    }
    [_pendingListeners removeAllObjects];
}

- (void) environmentDidActivate:(MBEnvironment*)env
{
    debugTrace();
    
    [super environmentDidActivate:env];
    
    [self startAllListeners];
}

- (void) environmentWillDeactivate:(MBEnvironment*)env
{
    debugTrace();
    
    [self stopAllListeners];
    
    [super environmentWillDeactivate:env];
}

- (void) environmentDidLoad:(MBEnvironment*)env
{
    debugTrace();
    
    [super environmentDidLoad:env];

    [self startAllListeners];
}

@end
