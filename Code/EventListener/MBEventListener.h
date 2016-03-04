//
//  MBEventListener.h
//  Mockingbird Event Handling
//
//  Created by Evan Coyne Maloney on 4/12/13.
//  Copyright (c) 2013 Gilt Groupe. All rights reserved.
//

@import MBDataEnvironment;

@class MBEventListener;
@class MBEventHandlerContainer;

/******************************************************************************/
#pragma mark Constants
/******************************************************************************/

/*! While an event listener is handling an NSNotification, this MBML variable
    ("Event") contain the NSNotification instance being handled. */
extern NSString* const __nonnull kMBEventListenerNotificationVariable;

/*! If the value of this MBML expression ("$Debug:traceActions") evaluates
    to YES, the execution of actions will be logged to the console. */
extern NSString* const __nonnull kMBEventListenerTraceActionsExpression;

/******************************************************************************/
#pragma mark MBFlowControlState type
/******************************************************************************/

typedef enum : NSInteger {
    MBFlowControlStateContinue          = 0,                                                        // actions will continue executing
    MBFlowControlStateBreak             = (1 << 0),                                                 // prevents execution of further actions in container
    MBFlowControlStateCaseBlock         = (1 << 1),                                                 // a <Case> block was selected for processing
    MBFlowControlStateCaseBlockBreak    = (MBFlowControlStateCaseBlock | MBFlowControlStateBreak)   // <Case> block processed, no further <Case>s or <DefaultCase>s will be processed in the current chain
} MBFlowControlState;

#define MBFlowControlStateIsCaseBlock(x)  ((x & MBFlowControlStateCaseBlock) == MBFlowControlStateCaseBlock)

/******************************************************************************/
#pragma mark -
#pragma mark MBEventHandler class
/******************************************************************************/

/*!
 The base class for classes that handle `NSNotification` events.
 */
@interface MBEventHandler : MBDataModel

/*----------------------------------------------------------------------------*/
#pragma mark Class lookup
/*!    @name Class lookup                                                     */
/*----------------------------------------------------------------------------*/

/*!
 Attempts to determine the implementing class of the event handler with the
 given name.
 
 @param     eventHandlerName the name of the event handler.
 
 @return    The implementing class, or nil if none could be found.
 */
+ (nullable Class) classForEventHandler:(nonnull NSString*)eventHandlerName;

/*----------------------------------------------------------------------------*/
#pragma mark Processing events
/*!    @name Processing events                                                */
/*----------------------------------------------------------------------------*/

/*!
 Allows the receiver to control whether a given event should be passed
 to its `eventReceived:byListener:forContainer:` method.
 
 If this method returns `YES` for a given event, the receiver's
 `eventReceived:byListener:forContainer:` method will then be called.

 The default implementation returns `YES` when the receiver has no "`if`"
 attribute or when expression contained in the receiver's "`if`"
 attribute evaluates to `YES`.

 @param     event the event that was received.
 
 @param     listener the event listener that received the event. May be `nil`
            if event handling is being invoked manually.
 
 @param     container the receiver's container. May be the `listener` itself,
            or may be `nil` if event handling is being invoked manually.

 @return    `YES` if the receiver is interested in handling the event;
            `NO` otherwise.
 */
- (BOOL) shouldHandleEvent:(nonnull NSNotification*)event
        receivedByListener:(nullable MBEventListener*)listener
                 container:(nullable MBEventHandlerContainer*)container;

/*!
 Must be implemented by subclasses to process an event.

 @warning   The default implementation throws an exception when called.
 
 @param     event the event that was received.
 
 @param     listener the event listener that received the event. May be `nil`
            if event handling is being invoked manually.
 
 @param     container the receiver's container. May be the `listener` itself,
            or may be `nil` if event handling is being invoked manually.
 */
- (void) eventReceived:(nonnull NSNotification*)event
            byListener:(nullable MBEventListener*)listener
             container:(nullable MBEventHandlerContainer*)container;

/*----------------------------------------------------------------------------*/
#pragma mark Debugging support
/*!    @name Debugging support                                                */
/*----------------------------------------------------------------------------*/

/*! When `YES`, debug information will be logged to the console when events
    are handled. */
@property(nonatomic, assign) BOOL traceExecution;

@end

/******************************************************************************/
#pragma mark -
#pragma mark MBEventHandlerContainer class
/******************************************************************************/

@interface MBEventHandlerContainer : MBEventHandler

/*----------------------------------------------------------------------------*/
#pragma mark Accessing the contained event handlers
/*!    @name Accessing the contained event handlers                           */
/*----------------------------------------------------------------------------*/

/*! The `MBEventHandler` instances within this container. */
@property(nonnull, nonatomic, readonly) NSArray* eventHandlers;

/*----------------------------------------------------------------------------*/
#pragma mark Event handler flow control
/*!    @name Event handler flow control                                       */
/*----------------------------------------------------------------------------*/

/*! When processing actions in response to receiving an event, an individual
    action may change the value of this property, which will affect how (and
    whether) further actions in the container are executed. */
@property(nonatomic, assign) MBFlowControlState flowControlState;

@end

/******************************************************************************/
#pragma mark -
#pragma mark MBEventListener class
/******************************************************************************/

/*!
 A class that can listen to one or more events and execute one or more
 `MBEventHandler`s when upon receiving an event.
 */
@interface MBEventListener : MBEventHandlerContainer

/*----------------------------------------------------------------------------*/
#pragma mark Listener name and trigger events
/*!    @name Listener name and trigger events                                 */
/*----------------------------------------------------------------------------*/

/*! The name of the listener. If no name is explicitly specified as an MBML
    attribute, this will contain the value of the "`event`" attribute. */
@property(nullable, nonatomic, readonly) NSString* name;

/*! The list of events for which the receiver will listen. */
@property(nonnull, nonatomic, readonly) NSArray* events;

/*----------------------------------------------------------------------------*/
#pragma mark Listener overwriting warnings
/*!    @name Listener overwriting warnings                                    */
/*----------------------------------------------------------------------------*/

/*! Returns `YES` if the receiver contains a "`warnOnOverwrite`" attribute. */
@property(nonatomic, readonly) BOOL warnOnOverwriteSpecified;

/*! Returns `YES` if the receiver's "`warnOnOverwrite`" attribute evaluated to
    `YES` when the receiver was instantiated. */
@property(nonatomic, assign) BOOL suppressOverwriteWarning;

/*----------------------------------------------------------------------------*/
#pragma mark Starting & stopping listening for events
/*!    @name Starting & stopping listening for events                         */
/*----------------------------------------------------------------------------*/

/*!
 Causes the receiver to start listening for events.
 
 When an event is received, any `eventHandlers` contained by the receiver will
 be given a chance to process the event.
 */
- (void) startListening;

/*!
 Causes the receiver to stop listening for events.
 */
- (void) stopListening;


/*! Indicates whether the receiver is currently listeneing for events. Only
    when listening will the receiver handle events. */
@property(nonatomic, readonly) BOOL isListening;

/*----------------------------------------------------------------------------*/
#pragma mark Debugging support
/*!    @name Debugging support                                                */
/*----------------------------------------------------------------------------*/

/*!
 Returns a string that will be used for outputting debugging information
 in conjunction with execution tracing.
 
 @param     event the event.
 */
- (nonnull NSString*) traceIdentifierForEvent:(nonnull NSNotification*)event;

@end

/******************************************************************************/
#pragma mark -
#pragma mark MBListenerAction class
/******************************************************************************/

/*!
 Provides a low-level API for performing actions in response to events received
 by listeners.

 Subclasses must implement the `eventReceived:byListener:container:` method
 to handle events.
 
 Action implementations should usually subclass `MBExecutableListenerAction`,
 which provides a higher-level API for executing actions.
 */
@interface MBListenerAction : MBEventHandler

/*----------------------------------------------------------------------------*/
#pragma mark Configuring the action's behavior
/*!    @name Configuring the action's behavior                                */
/*----------------------------------------------------------------------------*/

/*!
 Indicates whether the action accepts text content within its XML tags.
 
 Default implementation returns `NO`.
 
 @return    `YES` if text content is accepted; `NO` otherwise.
 */
- (BOOL) acceptsTextContent;

/*!
 Indicates whether the action accepts an arbitrary set of attributes. Default
 implementation returns NO. If YES, attribute validation will not occur and
 arbitrary events will be accepted without issuing console warnings.
 
 @return    `YES` if the listener accepts arbitrary attributes; `NO` otherwise.
 */
- (BOOL) acceptsArbitraryAttributes;

/*!
 Indicates whether the action ignores nonstandard attributes (i.e., those other
 than "`if`", "`afterDelay`" and "`warnOnOverwrite`".)
 
 Default implementation returns `NO`. If `YES`, attribute validation will fail
 if any attributes appear other than the standard action attributes listed 
 above.
 
 @return    `YES` if the listener ignores nonstandard attributes; `NO`
            otherwise.
 */
- (BOOL) ignoresNonstandardAttributes;

@end

/******************************************************************************/
#pragma mark -
#pragma mark MBExecutableListenerAction class
/******************************************************************************/

/*!
 The base class for listener action implementations that can be directly
 executed.

 Presents a higher-level API for handling events, used by actions that do not
 require knowledge about the listener handling the event and the action's
 container.
 
 Subclasses must implement the `executeForEvent:` method to handle events.
 
 Subclasses should not override `eventReceived:byListener:container:`.
 */
@interface MBExecutableListenerAction : MBListenerAction

/*----------------------------------------------------------------------------*/
#pragma mark Action execution
/*!    @name Action execution                                                 */
/*----------------------------------------------------------------------------*/

/*!
 Implemented by subclasses to perform the action when an event is received.

 This method is called by the default implementation of the method
 `eventReceived:byListener:container:`.

 @param     event the NSNotification that triggered the event listener.
            This parameter may be `nil` if the action is not being executed
            as the result of an event trigger (in other words, when the
            listener action is being invoked manually).
 */
- (void) executeForEvent:(nullable NSNotification*)event;

/*!
 Allows manual execution of the action, without being triggered by an event.

 The default implementation simply passes `nil` to `executeForEvent:`.
 */
- (void) execute;

/*!
 Attempts to validate the receiver's data model and, if successful,
 executes the event using the passed-in notification.

 @param     event the `NSNotification` that triggered the event listener.
            This parameter may be `nil` if the action is not being executed
            as the result of an event trigger (in other words, when the
            listener action is being invoked manually).

 @return    `YES` if the data model validated and the event was executed;
            `NO` if the event did not execute because the data model wasn't
            valid.
 */
- (BOOL) validateAndExecuteForEvent:(nullable NSNotification*)event;

@end

/******************************************************************************/
#pragma mark -
#pragma mark MBDebugAction class
/******************************************************************************/

/*!
 An action that outputs some debugging information when executed.
 */
@interface MBDebugAction : MBExecutableListenerAction
@end

