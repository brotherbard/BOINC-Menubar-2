//
//  ClientManager.h
//  BOINCMenubar
//
//  Created by BrotherBard on 4/18/08.
//  Copyright 2009 BrotherBard <nkinsinger at brotherbard dot com>. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification,
//  are permitted provided that the following conditions are met:
//     * Redistributions of source code must retain the above copyright notice, this
//       list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above copyright notice,
//       this list of conditions and the following disclaimer in the documentation 
//       and/or other materials provided with the distribution.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
//  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import <Cocoa/Cocoa.h>

#import "BOINCCommonConstants.h"

#import "BOINCClient.h"
#import "BOINCClientProcess.h"
#import "BOINCCreditMilestone.h"
#import "BOINCClientVersion.h"
#import "BOINCClientState.h"
#import "BOINCClientStatus.h"
#import "BOINCHostInfo.h"
#import "BOINCDailyTimeLimits.h"
#import "BOINCNetProxySettings.h"
#import "BOINCGlobalPreferences.h"
#import "BOINCTimeStatistics.h"
#import "BOINCNetStatistics.h"
#import "BOINCProjectStatistics.h"
#import "BOINCDailyProjectStatistics.h"

#import "BOINCProjectConfig.h"
#import "BOINCAccountOut.h"
#import "BOINCProjectAttach.h"
#import "BOINCRPCStatusReply.h"

#import "BOINCURL.h"
#import "BOINCTask.h"
#import "BOINCProject.h"
#import "BOINCPlatform.h"
#import "BOINCProjectSummary.h"
#import "BOINCAccountManagerSummary.h"
#import "BOINCAllProjectsList.h"
#import "BOINCAccountManager.h"


@class BOINCLoginWindowController;
@class BOINCKeychain;



@interface BOINCClientManager : NSObject
{
    NSMutableArray *clients;
    BOINCKeychain  *keychain;
    
    BOINCClient        *localClient;
    BOINCClientProcess *localBOINCProcess;
    
    BOINCLoginWindowController *loginWindowController;
}
@property (nonatomic, retain) NSMutableArray *clients;
@property (nonatomic, retain) BOINCKeychain  *keychain;

@property (nonatomic, retain) BOINCClient        *localClient;
@property (nonatomic, retain) BOINCClientProcess *localBOINCProcess;

// designated init
// will read from the users Keychain and create an array of clients or create a new default "This Computer" client if there are none
// may have to ask for password if the Keychain is locked
- (id)init;


- (void)runLocalBOINCProcess;
- (void)stopLocalBOINCProcess;
- (NSApplicationTerminateReply)shouldAppTerminate;

// used by BOINCKeychain to add a newly created client when one is added to the Keychain
- (void)addClientForKeychainItem:(BOINCKeychainItem *)item;
- (void)addClient:(BOINCClient *)client;
- (void)removeClient:(BOINCClient *)client;

- (BOINCClient *)clientForUUID:(NSString *)searchUUID;

- (void)connectToClientByUUID:(NSString *)newUUID;
- (void)connectToClient:(BOINCClient *)client withPassword:(NSString *)password;
- (void)loginWindowClosed;


@end
