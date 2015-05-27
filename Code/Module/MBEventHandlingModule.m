//
//  MBEventHandlingModule.m
//  Mockingbird Event Handling
//
//  Created by Evan Coyne Maloney on 7/30/14.
//  Copyright (c) 2014 Gilt Groupe. All rights reserved.
//

#import "MBEventHandlingModule.h"

#define DEBUG_LOCAL     0

/******************************************************************************/
#pragma mark -
#pragma mark MBEventHandlingModule implementation
/******************************************************************************/

@implementation MBEventHandlingModule

+ (nullable NSArray*) environmentLoaderClasses
{
    return @[[MBListenerManager class], [MBFilterManager class]];
}

@end
