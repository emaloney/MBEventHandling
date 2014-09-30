//
//  MBFilterManager.h
//  Mockingbird Event Handling
//
//  Created by Evan Coyne Maloney on 7/30/14.
//  Copyright (c) 2014 Gilt Groupe. All rights reserved.
//

#import <MBDataEnvironment/MBEnvironmentLoader.h>
#import <MBToolbox/MBSingleton.h>

@class MBDataFilter;

/******************************************************************************/
#pragma mark -
#pragma mark MBFilterManager class
/******************************************************************************/

@interface MBFilterManager : MBEnvironmentLoader < MBInstanceVendor >

/*----------------------------------------------------------------------------*/
#pragma mark Accessing data filters
/*!    @name Accessing data filters                                           */
/*----------------------------------------------------------------------------*/

/*!
 Returns an array of strings specifying the names of the `MBDataFilter`
 instances known to the receiver.
 
 @return    The names of the filters.
 */
- (NSArray*) filterNames;

/*!
 Returns the `MBDataFilter` associated with the specified name.
 
 @param     name The name of the data filter to return.
 
 @return    The data filter, or `nil` if there is no filter with the
            specified name.
 */
- (MBDataFilter*) filterWithName:(NSString*)name;

@end
