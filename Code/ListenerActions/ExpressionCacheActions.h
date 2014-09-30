//
//  ExpressionCacheActions.h
//  Mockingbird Library
//
//  Created by Evan Coyne Maloney on 7/1/13.
//  Copyright (c) 2013 Gilt Groupe. All rights reserved.
//

#import "MBEventListener.h"

/******************************************************************************/
#pragma mark -
#pragma mark MBExpressionCacheActionBase class
/******************************************************************************/

@interface MBExpressionCacheActionBase : MBExecutableListenerAction
@end

/******************************************************************************/
#pragma mark -
#pragma mark MBClearExpressionCacheAction class
/******************************************************************************/

@interface MBClearExpressionCacheAction : MBExpressionCacheActionBase
@end

/******************************************************************************/
#pragma mark -
#pragma mark MBResetExpressionCacheFileAction class
/******************************************************************************/

@interface MBResetExpressionCacheFileAction : MBExpressionCacheActionBase
@end

/******************************************************************************/
#pragma mark -
#pragma mark MBLoadExpressionCacheAction class
/******************************************************************************/

@interface MBLoadExpressionCacheAction : MBExpressionCacheActionBase
@end

/******************************************************************************/
#pragma mark -
#pragma mark MBLoadAndMergeExpressionCacheAction class
/******************************************************************************/

@interface MBLoadAndMergeExpressionCacheAction : MBExpressionCacheActionBase
@end

/******************************************************************************/
#pragma mark -
#pragma mark MBSaveExpressionCacheAction class
/******************************************************************************/

@interface MBSaveExpressionCacheAction : MBExpressionCacheActionBase
@end
