//
//  MBFilterDataAction.m
//  Mockingbird Event Handling
//
//  Created by Evan Coyne Maloney on 7/1/13.
//  Copyright (c) 2013 Gilt Groupe. All rights reserved.
//

@import MBToolbox;
@import MBDataEnvironment;

#import "MBFilterDataAction.h"
#import "MBDataFilter.h"
#import "MBFilterManager.h"

#define DEBUG_LOCAL         0

/******************************************************************************/
#pragma mark -
#pragma mark MBFilterDataAction implementation
/******************************************************************************/

@implementation MBFilterDataAction

/******************************************************************************/
#pragma mark Data model enforcement
/******************************************************************************/

+ (nullable NSSet*) requiredAttributes
{
    return [NSSet setWithObject:kMBMLAttributeName];
}

/******************************************************************************/
#pragma mark Action implementation
/******************************************************************************/

- (void) executeForEvent:(nullable NSNotification*)event
{
    NSString* filterName = [self evaluateAsString:kMBMLAttributeName];
    if (filterName) {
        MBDataFilter* filter = [[MBFilterManager instance] filterWithName:filterName];

        MBLogDebug(@"Executing <%@> for <%@> named: %@", self.xmlTagName, filter.xmlTagName, filterName);

        [filter refreshData];
    }
}

@end
