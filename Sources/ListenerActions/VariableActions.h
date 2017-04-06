//
//  VariableActions.h
//  Mockingbird Event Handling
//
//  Created by Evan Coyne Maloney on 6/27/13.
//  Copyright (c) 2013 Gilt Groupe. All rights reserved.
//

#import "MBEventListener.h"

/******************************************************************************/
#pragma mark -
#pragma mark MBVariableActionBase class
/******************************************************************************/

@interface MBVariableActionBase : MBExecutableListenerAction
@end

/******************************************************************************/
#pragma mark -
#pragma mark MBSetVariableActionBase class
/******************************************************************************/

@interface MBSetVariableActionBase : MBVariableActionBase
@end

/******************************************************************************/
#pragma mark -
#pragma mark MBBooleanVariableValueActionBase class
/******************************************************************************/

@interface MBBooleanVariableValueActionBase : MBSetVariableActionBase
@end

/******************************************************************************/
#pragma mark -
#pragma mark MBSetVarAction class
/******************************************************************************/

@interface MBSetVarAction : MBSetVariableActionBase
@end

/******************************************************************************/
#pragma mark -
#pragma mark MBSetTransientVarAction class
/******************************************************************************/

@interface MBSetTransientVarAction : MBSetVariableActionBase
@end

/******************************************************************************/
#pragma mark -
#pragma mark MBSetTransientBooleanVarAction class
/******************************************************************************/

@interface MBSetTransientBooleanVarAction : MBBooleanVariableValueActionBase
@end

/******************************************************************************/
#pragma mark -
#pragma mark MBUnsetVarAction class
/******************************************************************************/

@interface MBUnsetVarAction : MBVariableActionBase
@end

/******************************************************************************/
#pragma mark -
#pragma mark MBPushVarAction class
/******************************************************************************/

@interface MBPushVarAction : MBSetVariableActionBase
@end

/******************************************************************************/
#pragma mark -
#pragma mark MBPopVarAction class
/******************************************************************************/

@interface MBPopVarAction : MBVariableActionBase
@end

/******************************************************************************/
#pragma mark -
#pragma mark MBSetBooleanVarAction class
/******************************************************************************/

@interface MBSetBooleanVarAction : MBBooleanVariableValueActionBase
@end

/******************************************************************************/
#pragma mark -
#pragma mark MBPushBooleanVarAction class
/******************************************************************************/

@interface MBPushBooleanVarAction : MBBooleanVariableValueActionBase
@end

