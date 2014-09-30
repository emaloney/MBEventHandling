//
//  ServiceActions.h
//  Mockingbird Event Handling
//
//  Created by Evan Coyne Maloney on 7/1/13.
//  Copyright (c) 2013 Gilt Groupe. All rights reserved.
//

#import <MBToolbox/MBService.h>

#import "MBEventListener.h"

@class MBServiceManager;

/******************************************************************************/
#pragma mark -
#pragma mark MBServiceActionBase class
/******************************************************************************/

/*!
 A base class for listener actions that manipulate runtime services managed
 by the `MBServiceManager`.
 */
@interface MBServiceActionBase : MBExecutableListenerAction
- (void) executeForService:(MBService*)svc named:(NSString*)svcName manager:(MBServiceManager*)mgr;
@end

/******************************************************************************/
#pragma mark -
#pragma mark MBAttachServiceAction class
/******************************************************************************/

/*!
 A listener action that, when executed, attaches to a runtime service.
 
 Attaching a service ensures that the `MBServiceManager` keeps it running 
 as long as you need it. When you no longer need to use the service, you
 should detach the service.
  
 **MBML Example**
 
 If you need to use the `MBGeolocationService`, you would attach as follows:
 
    <AttachService class="MBGeolocationService"/>
 
 See the `MBServiceManager` class for additional information.
 */
@interface MBAttachServiceAction : MBServiceActionBase
@end

/******************************************************************************/
#pragma mark -
#pragma mark MBDetachServiceAction class
/******************************************************************************/

/*!
 A listener action that, when executed, detaches from a runtime service.
 
 Detaching a service signals to the `MBServiceManager` that you no longer need
 to use the service. When the last client using a service detaches, the
 service is stopped.

 **MBML Example**
 
 If you were using the `MBGeolocationService` and no longer need it, you would
 detach as follows:
 
    <DetachService class="MBGeolocationService"/>

 See the `MBServiceManager` class for additional information.
 */
@interface MBDetachServiceAction : MBServiceActionBase
@end
