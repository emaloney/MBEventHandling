//
//  MBListenerManager.m
//  Mockingbird Event Handling
//
//  Created by Evan Coyne Maloney on 8/21/12.
//  Copyright (c) 2012 Gilt Groupe. All rights reserved.
//

#import <RaptureXML@Gilt/RXMLElement.h>
#import <MBDataEnvironment/MBDataEnvironment.h>

#import "MBListenerManager.h"
#import "MBEventListener.h"
#import "MBEventHandlingConstants.h"

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

- (void) addListener:(nonnull MBEventListener*)listener
{
    MBLogVerboseTrace();
    
    if (!self.isActive) {
        [_pendingListeners addObject:listener];
    }
    else {
        [self _activateListener:listener];
        if (!listener.isListening) {
            [listener startListening];
        }
    }
}

- (void) removeListenerWithName:(nonnull NSString*)name
{
    MBLogVerboseTrace();
    
    MBEventListener* listener = _nameToListener[name];
    if (listener) {
        [self removeListener:listener];
    }
}

- (void) removeListener:(nonnull MBEventListener*)listener
{
    MBLogVerboseTrace();

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
    MBLogVerboseTrace();
    
    [self stopAllListeners];
    
    [_nameToListener removeAllObjects];
    [_eventToListeners removeAllObjects];
}

/******************************************************************************/
#pragma mark Accessing listeners
/******************************************************************************/

- (nonnull NSArray*) listenerNames
{
    return [_nameToListener allKeys];
}

- (nullable MBEventListener*) listenerWithName:(nonnull NSString*)name
{
    return _nameToListener[name];
}

- (nonnull NSArray*) listenerEvents
{
    return [_eventToListeners allKeys];
}

- (NSArray*) listenersForEvent:(NSString*)event
{
    NSArray* listeners = _eventToListeners[event];
    if (listeners.count > 0) {
        return [NSArray arrayWithArray:listeners];
    }
    return [NSArray new];
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
                MBLogWarning(@"The event listener named \"%@\" is being overwritten!\n\n\tExisting listener: %@\tNew listener: %@\tTo avoid this warning, specify %@=\"F\" on the <%@>", name, [[curListener description] stringByIndentingEachLineWithTabs:2], [[newListener description] stringByIndentingEachLineWithTabs:2], kMBMLAttributeWarnOnOverwrite, newListener.xmlTagName);
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
        MBLogError(@"This Listener declaration isn't valid and it will therefore be ignored: %@", newListener);
    }
}

- (void) startAllListeners
{
    MBLogDebugTrace();

    for (NSString* name in _nameToListener) {
        MBEventListener* listener = _nameToListener[name];
        if (!listener.isListening) {
            [listener startListening];
        }
    }
}

- (void) stopAllListeners
{
    MBLogDebugTrace();
    
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
    MBLogDebugTrace();
    
    [super environmentWillActivate:env];
    
    for (MBEventListener* listener in _pendingListeners) {
        [self _activateListener:listener];
    }
    [_pendingListeners removeAllObjects];
}

- (void) environmentDidActivate:(MBEnvironment*)env
{
    MBLogDebugTrace();
    
    [super environmentDidActivate:env];
    
    [self startAllListeners];
}

- (void) environmentWillDeactivate:(MBEnvironment*)env
{
    MBLogDebugTrace();
    
    [self stopAllListeners];
    
    [super environmentWillDeactivate:env];
}

- (void) environmentDidLoad:(MBEnvironment*)env
{
    MBLogDebugTrace();
    
    [super environmentDidLoad:env];

    [self startAllListeners];
}

@end
