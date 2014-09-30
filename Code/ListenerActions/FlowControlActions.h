//
//  FlowControlActions.h
//  Mockingbird Library
//
//  Created by Evan Coyne Maloney on 2/24/14.
//  Copyright (c) 2014 Gilt Groupe. All rights reserved.
//

#import "MBEventListener.h"

/******************************************************************************/
#pragma mark -
#pragma mark MBBreakAction class
/******************************************************************************/

/*!
 An action that, when executed, prevents the Listener from executing further
 actions while processing the event.
 */
@interface MBBreakAction : MBExecutableListenerAction
@end

/******************************************************************************/
#pragma mark -
#pragma mark MBAssertAction class
/******************************************************************************/

/*!
 An action that, when executed, asserts that a specific condition is true. If
 it is not true, the action logs a message to the console and prevents further
 actions from executing.
 */
@interface MBAssertAction : MBExecutableListenerAction
@end

/******************************************************************************/
#pragma mark -
#pragma mark MBWhenAction class
/******************************************************************************/

/*!
 An action that contains other actions and conditionally executes them
 when a given condition evaluates to true.
 */
@interface MBWhenAction : MBEventHandlerContainer
@end

/******************************************************************************/
#pragma mark -
#pragma mark MBCaseAction class
/******************************************************************************/

/*!
 */
@interface MBCaseAction : MBEventHandlerContainer
@end

/******************************************************************************/
#pragma mark -
#pragma mark MBDefaultCaseAction class
/******************************************************************************/

/*!
 */
@interface MBDefaultCaseAction : MBCaseAction
@end
