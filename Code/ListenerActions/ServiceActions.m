//
//  ServiceActions.m
//  Mockingbird Event Handling
//
//  Created by Evan Coyne Maloney on 7/1/13.
//  Copyright (c) 2013 Gilt Groupe. All rights reserved.
//

#import <MBToolbox/MBServiceManager.h>

#import "ServiceActions.h"

#define DEBUG_LOCAL         0

/******************************************************************************/
#pragma mark -
#pragma mark MBServiceActionBase implementation
/******************************************************************************/

@implementation MBServiceActionBase

/******************************************************************************/
#pragma mark Data model enforcement
/******************************************************************************/

+ (NSSet*) requiredAttributes
{
    return [NSSet setWithObject:kMBMLAttributeClass];
}

/******************************************************************************/
#pragma mark Action implementation
/******************************************************************************/

- (void) executeForEvent:(NSNotification*)event
{
    debugTrace();
    
    NSString* clsName = [self evaluateAsString:kMBMLAttributeClass];
    if (clsName) {
        MBServiceManager* mgr = [MBServiceManager instance];
        MBService* svc = [mgr serviceForClassName:clsName];
        if (svc) {
            [self executeForService:svc named:clsName manager:mgr];
        }
        else {
            errorLog(@"<%@> could not find a %@ named \"%@\" (from expression: %@) as specified by the \"%@\" attribute: %@", self.xmlTagName, NSStringFromProtocol(@protocol(MBService)), clsName, self[kMBMLAttributeClass], kMBMLAttributeClass, self.simulatedXML);
        }
    }
    else {
        errorLog(@"<%@> requires the \"%@\" attribute to evaluate to the name of a %@; the expression \"%@\" evaluated to nil: %@", self.xmlTagName, kMBMLAttributeClass, NSStringFromProtocol(@protocol(MBService)), self[kMBMLAttributeClass], self.simulatedXML);
    }
}

- (void) executeForService:(MBService*)svc named:(NSString*)svcName manager:(MBServiceManager*)mgr
{
    MBErrorNotImplemented();
}

@end

/******************************************************************************/
#pragma mark -
#pragma mark MBAttachServiceAction implementation
/******************************************************************************/

@implementation MBAttachServiceAction

/******************************************************************************/
#pragma mark Action implementation
/******************************************************************************/

- (void) executeForService:(MBService*)svc named:(NSString*)svcName manager:(MBServiceManager*)mgr
{
    debugTrace();
    
    [mgr attachToServiceClassNamed:svcName];
}

@end

/******************************************************************************/
#pragma mark -
#pragma mark MBDetachServiceAction implementation
/******************************************************************************/

@implementation MBDetachServiceAction

/******************************************************************************/
#pragma mark Action implementation
/******************************************************************************/

- (void) executeForService:(MBService*)svc named:(NSString*)svcName manager:(MBServiceManager*)mgr
{
    debugTrace();
    
    [mgr detachFromServiceClassNamed:svcName];
}

@end

