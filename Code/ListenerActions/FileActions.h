//
//  FileActions.h
//  Mockingbird Library
//
//  Created by Evan Coyne Maloney on 7/1/13.
//  Copyright (c) 2013 Gilt Groupe. All rights reserved.
//

#import "MBEventListener.h"

/******************************************************************************/
#pragma mark -
#pragma mark MBLoadFileAction class
/******************************************************************************/

@interface MBLoadFileAction : MBExecutableListenerAction
@end

/******************************************************************************/
#pragma mark -
#pragma mark MBSaveFileAction class
/******************************************************************************/

@interface MBSaveFileAction : MBExecutableListenerAction
@end

/******************************************************************************/
#pragma mark -
#pragma mark MBDeleteFileAction class
/******************************************************************************/

@interface MBDeleteFileAction : MBExecutableListenerAction
@end

/******************************************************************************/
#pragma mark -
#pragma mark MBCreateSymlinkAction class
/******************************************************************************/

@interface MBCreateSymlinkAction : MBExecutableListenerAction
@end
