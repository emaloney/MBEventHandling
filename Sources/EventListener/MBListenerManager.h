//
//  MBListenerManager.h
//  Mockingbird Event Handling
//
//  Created by Evan Coyne Maloney on 8/21/12.
//  Copyright (c) 2012 Gilt Groupe. All rights reserved.
//

@class MBEventListener;
@protocol MBInstanceVendor;

/******************************************************************************/
#pragma mark Constants
/******************************************************************************/

/*! The name of the XML element ("Listener") for declaring event listeners
    and their contained actions. */
extern NSString* const __nonnull kMBEventListenerXMLTag;

/******************************************************************************/
#pragma mark -
#pragma mark MBListenerManager class
/******************************************************************************/

@interface MBListenerManager : MBEnvironmentLoader < MBInstanceVendor >

/******************************************************************************/
#pragma mark Starting/stopping listeners
/******************************************************************************/

/*! Instructs all <code>MBEventListener</code>s managed by the receiver to 
    start listening for events. */
- (void) startAllListeners;

/*! Instructs all <code>MBEventListener</code>s managed by the receiver to
    stop listening for events. */
- (void) stopAllListeners;

/******************************************************************************/
#pragma mark Adding & removing listeners
/******************************************************************************/

/*! Adds an event listener, and if the receiver is associated with the active
    environment, intructs the listener to start listening for events. */
- (void) addListener:(nonnull MBEventListener*)listener;

/*! Removes the event listener from control by the receiver, and instructs
    the listener to stop listening for events. */
- (void) removeListener:(nonnull MBEventListener*)listener;

/*! Removes the event listener with the specified name, and instructs the
    listener to stop listening for events. */
- (void) removeListenerWithName:(nonnull NSString*)name;

/******************************************************************************/
#pragma mark Accessing listeners
/******************************************************************************/

/*! Returns an array containing the names of all listeners managed by the
    receiver. */
- (nonnull NSArray*) listenerNames;

/*! Returns the event listener associated with the specified name. */
- (nullable MBEventListener*) listenerWithName:(nonnull NSString*)name;

/*! Returns an array of all events listened to by the various event
    listeners managed by the receiver. */
- (nonnull NSArray*) listenerEvents;

/*! Returns an array of the MBEventListeners that are listening for the
    specified event. */
- (nonnull NSArray*) listenersForEvent:(nonnull NSString*)event;

@end

