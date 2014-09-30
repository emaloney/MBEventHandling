//
//  MBEventHandling.m
//  Mockingbird Event Handling
//
//  Created by Evan Coyne Maloney on 7/30/14.
//  Copyright (c) 2014 Gilt Groupe. All rights reserved.
//

#import "MBEventHandling.h"

#define DEBUG_LOCAL     0

/******************************************************************************/
#pragma mark -
#pragma mark MBEventHandling implementation
/******************************************************************************/

@implementation MBEventHandling

+ (NSArray*) environmentLoaderClasses
{
    return @[[MBListenerManager class], [MBFilterManager class]];
}

@end
