//
//  MBEventHandling.h
//  Mockingbird Event Handling
//
//  Created by Evan Coyne Maloney on 3/18/14.
//  Copyright (c) 2014 Gilt Groupe. All rights reserved.
//

#ifndef __OBJC__

#error Mockingbird Event Handling requires Objective-C

#else

#import <Foundation/Foundation.h>

#import <MBToolbox/MBToolbox.h>

#if MB_BUILD_IOS
#import <UIKit/UIKit.h>
#else
#import <AppKit/AppKit.h>
#endif

#import <MBDataEnvironment/MBDataEnvironment.h>

//! Project version number for MBEventHandling.
FOUNDATION_EXPORT double MBEventHandlingVersionNumber;

//! Project version string for MBEventHandling.
FOUNDATION_EXPORT const unsigned char MBEventHandlingVersionString[];

//
// NOTE: This header file is indended for external use. It should *not* be
//       included from within code in the Mockingbird Event Handling module.
//
#import <MBEventHandling/MBDataFilter.h>
#import <MBEventHandling/MBFilterDataAction.h>
#import <MBEventHandling/MBFilterManager.h>
#import <MBEventHandling/MBEventListener.h>
#import <MBEventHandling/MBListenerManager.h>
#import <MBEventHandling/EnvironmentActions.h>
#import <MBEventHandling/EventActions.h>
#import <MBEventHandling/ExpressionCacheActions.h>
#import <MBEventHandling/FileActions.h>
#import <MBEventHandling/FlowControlActions.h>
#import <MBEventHandling/ServiceActions.h>
#import <MBEventHandling/VariableActions.h>
#import <MBEventHandling/MBEventHandlingConstants.h>
#import <MBEventHandling/MBEventHandlingModule.h>

#endif

