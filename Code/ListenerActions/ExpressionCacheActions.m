//
//  ExpressionCacheActions.m
//  Mockingbird Library
//
//  Created by Evan Coyne Maloney on 7/1/13.
//  Copyright (c) 2013 Gilt Groupe. All rights reserved.
//

#import <MBDataEnvironment/MBExpressionCache.h>

#import "ExpressionCacheActions.h"

#define DEBUG_LOCAL         0

/******************************************************************************/
#pragma mark -
#pragma mark MBExpressionCacheActionBase implementation
/******************************************************************************/

@implementation MBExpressionCacheActionBase

/******************************************************************************/
#pragma mark Data model enforcement
/******************************************************************************/

- (BOOL) ignoresNonstandardAttributes
{
    return YES;
}

@end

/******************************************************************************/
#pragma mark -
#pragma mark MBClearExpressionCacheAction implementation
/******************************************************************************/

@implementation MBClearExpressionCacheAction

/******************************************************************************/
#pragma mark Action implementation
/******************************************************************************/

- (void) executeForEvent:(NSNotification*)event
{
    debugTrace();
    
    [[MBExpressionCache instance] clearCache];
}

@end

/******************************************************************************/
#pragma mark -
#pragma mark MBResetExpressionCacheFileAction implementation
/******************************************************************************/

@implementation MBResetExpressionCacheFileAction

/******************************************************************************/
#pragma mark Action implementation
/******************************************************************************/

- (void) executeForEvent:(NSNotification*)event
{
    debugTrace();

    [[MBExpressionCache instance] resetFilesystemCache];
}

@end

/******************************************************************************/
#pragma mark -
#pragma mark MBLoadExpressionCacheAction implementation
/******************************************************************************/

@implementation MBLoadExpressionCacheAction

/******************************************************************************/
#pragma mark Action implementation
/******************************************************************************/

- (void) executeForEvent:(NSNotification*)event
{
    debugTrace();

    [[MBExpressionCache instance] loadCache];
}

@end

/******************************************************************************/
#pragma mark -
#pragma mark MBLoadAndMergeExpressionCacheAction implementation
/******************************************************************************/

@implementation MBLoadAndMergeExpressionCacheAction

/******************************************************************************/
#pragma mark Action implementation
/******************************************************************************/

- (void) executeForEvent:(NSNotification*)event
{
    debugTrace();

    [[MBExpressionCache instance] loadAndMergeCache];
}

@end

/******************************************************************************/
#pragma mark -
#pragma mark MBSaveExpressionCacheAction implementation
/******************************************************************************/

@implementation MBSaveExpressionCacheAction

/******************************************************************************/
#pragma mark Action implementation
/******************************************************************************/

- (void) executeForEvent:(NSNotification*)event
{
    debugTrace();
    
    [[MBExpressionCache instance] saveCache];
}

@end

