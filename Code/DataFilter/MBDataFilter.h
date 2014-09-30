//
//  MBDataFilter.h
//  Mockingbird Event Handling
//
//  Created by Jesse Boyes on 8/15/09.
//  Copyright (c) 2009 Gilt Groupe. All rights reserved.
//

#import <MBDataEnvironment/MBDataModel.h>

/******************************************************************************/
#pragma mark -
#pragma mark MBDataFilter class
/******************************************************************************/

@interface MBDataFilter : MBDataModel

@property(nonatomic, strong) MBMLAttribute NSString* name;

- (void) refreshData;

@end
