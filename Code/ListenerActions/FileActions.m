//
//  FileActions.m
//  Mockingbird Event Handling
//
//  Created by Evan Coyne Maloney on 7/1/13.
//  Copyright (c) 2013 Gilt Groupe. All rights reserved.
//

#import <MBDataEnvironment/MBDataEnvironment.h>

#import "FileActions.h"

#define DEBUG_LOCAL         0

/******************************************************************************/
#pragma mark -
#pragma mark MBLoadFileAction implementation
/******************************************************************************/

@implementation MBLoadFileAction

/******************************************************************************/
#pragma mark Data model enforcement
/******************************************************************************/

+ (nullable NSSet*) requiredAttributes
{
    return [NSSet setWithObjects:kMBMLAttributeFile, kMBMLAttributeVar, nil];
}

+ (nullable NSSet*) supportedAttributes
{
    return [NSSet setWithObject:kMBMLAttributeType];
}

/******************************************************************************/
#pragma mark Action implementation
/******************************************************************************/

- (void) executeForEvent:(nullable NSNotification*)event
{
    debugTrace();
    
    NSString* filePath = [self evaluateAsString:kMBMLAttributeFile];
    NSString* var = [self evaluateAsString:kMBMLAttributeVar];
    NSString* type = [self evaluateAsString:kMBMLAttributeType defaultValue:@"text"];
    
    if (filePath && var) {
        NSError* err = nil;
        NSData* fileData = [NSData dataWithContentsOfFile:filePath
                                                  options:0
                                                    error:&err];
        if (fileData) {
            id varValue = fileData;
            if (type && [type isEqualToString:@"text"]) {
                varValue = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
            }
            
            [MBVariableSpace instance][var] = varValue;
        }
        else {
            errorLog(@"%@ failed to load %@; error: %@", [self class], filePath, err);
        }
    }
}

@end

/******************************************************************************/
#pragma mark -
#pragma mark MBSaveFileAction implementation
/******************************************************************************/

@implementation MBSaveFileAction

/******************************************************************************/
#pragma mark Data model enforcement
/******************************************************************************/

+ (nullable NSSet*) requiredAttributes
{
    return [NSSet setWithObjects:kMBMLAttributeFile, kMBMLAttributeVar, nil];
}

/******************************************************************************/
#pragma mark Action implementation
/******************************************************************************/

- (void) executeForEvent:(nullable NSNotification*)event
{
    debugTrace();
    
    NSString* filePath = [self evaluateAsString:kMBMLAttributeFile];
    NSString* var = [self evaluateAsString:kMBMLAttributeVar];
    
    if (filePath && var) {
        NSError* err = nil;
        
        id value = [MBVariableSpace instance][var];
        if (!value) {
            errorLog(@"Was asked to write the MBML variable %@ to file %@, but the variable is currently nil", var, filePath);
        }
        else if ([value isKindOfClass:[NSData class]]) {
            NSData* data = (NSData*) value;
            if (![data writeToFile:filePath
                           options:NSDataWritingAtomic
                             error:&err])
            {
                errorLog(@"%@ error saving %@ to file: %@", [self class], [data class], err);
            }
        }
        else if ([var isKindOfClass:[NSString class]]) {
            NSString* str = (NSString*) value;
            if (![str writeToFile:filePath
                       atomically:YES
                         encoding:NSUTF8StringEncoding
                            error:&err])
            {
                errorLog(@"%@ error saving %@ to file: %@", [self class], [str class], err);
            }
        }
        else {
            errorLog(@"%@ doesn't know how to save a %@ to a file yet in %@", [self class], [value class], self.simulatedXML);
        }
    }
}

@end

/******************************************************************************/
#pragma mark -
#pragma mark MBDeleteFileAction implementation
/******************************************************************************/

@implementation MBDeleteFileAction

/******************************************************************************/
#pragma mark Data model enforcement
/******************************************************************************/

+ (nullable NSSet*) requiredAttributes
{
    return [NSSet setWithObject:kMBMLAttributeFile];
}

/******************************************************************************/
#pragma mark Action implementation
/******************************************************************************/

- (void) executeForEvent:(nullable NSNotification*)event
{
    debugTrace();
    
    NSString* filePath = [self evaluateAsString:kMBMLAttributeFile];
    
    NSFileManager* fileMgr = [NSFileManager defaultManager];
    
    NSError* err = nil;
    if (![fileMgr removeItemAtPath:filePath error:&err]) {
        errorLog(@"%@ error attempting to delete file: %@", [self class], err);
    }
}

@end

/******************************************************************************/
#pragma mark -
#pragma mark MBCreateSymlinkAction class
/******************************************************************************/

@implementation MBCreateSymlinkAction

/******************************************************************************/
#pragma mark Data model enforcement
/******************************************************************************/

+ (nullable NSSet*) requiredAttributes
{
    return [NSSet setWithObjects:kMBMLAttributeFile,
            kMBMLAttributeTarget,
            nil];
}

/******************************************************************************/
#pragma mark Action implementation
/******************************************************************************/

- (void) executeForEvent:(nullable NSNotification*)event
{
    debugTrace();

    NSString* srcPath = [self evaluateAsString:kMBMLAttributeFile];
    NSString* targetPath = [self evaluateAsString:kMBMLAttributeTarget];

    NSFileManager* fileMgr = [NSFileManager defaultManager];

    NSError* err = nil;
    if (![fileMgr createSymbolicLinkAtPath:srcPath withDestinationPath:targetPath error:&err]) {
        errorLog(@"The <%@> action encountered an error trying to create symbolic link from <%@> to <%@>: %@", self.xmlTagName, srcPath, targetPath, err);
    }
}

@end
