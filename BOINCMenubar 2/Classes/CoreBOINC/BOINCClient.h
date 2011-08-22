//
//  BOINCClient.h
//  BOINCMenubar
//
//  Created by BrotherBard on 3/30/08.
//  Copyright 2008-2009 BrotherBard <nkinsinger at brotherbard dot com>. All rights reserved.
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


@class BOINCClientStatus;
@class BOINCHostConnection;
@class BOINCClientVersion;
@class BOINCClientState;
@class BOINCNetStatistics;
@class BOINCTimeStatistics;
@class BOINCHostInfo;
@class BOINCAllProjectsList;
@class BOINCAccountManager;
@class BOINCGlobalPreferences;
@class BOINCNetProxySettings;
@class BOINCProject;
@class BOINCTask;
@class BOINCURL;
@class BOINCKeychainItem;
@class BOINCCreditMilestone;



@interface BOINCClient : NSObject 
{   
    BOINCClientStatus      *ccStatus;
    BOINCHostConnection    *ccConnection;
    
    NSMutableArray         *projects;
    BOINCAllProjectsList   *allProjectsList;
    
    BOINCKeychainItem      *hostKeychainItem;
    BOINCClientVersion     *version;
    
    BOOL                    isLocalHost;
    BOOL                    isAuthorized;
    BOOL                    isConnected;
    BOOL                    isAlwaysConnected;
    int                     connectionStatus;
    NSString               *connectingData;
    BOOL                    clientShouldQuit;
    
    BOINCClientState       *clientState;
    BOINCHostInfo          *hostInfo;
    BOINCNetStatistics     *netStats;
    BOINCTimeStatistics    *timeStats;
    BOINCCreditMilestone   *hostTotalCreditMilestone;
    
    BOINCAccountManager    *accountManager;
    BOINCGlobalPreferences *workingPreferences;
    NSInteger               prefStateIndex;
    BOINCNetProxySettings  *proxySettings;
    
    NSDate *lastProjectsAndTasksUpdate;
    NSDate *lastClientStateUpdate;
    NSDate *lastAllProjectsListUpdate;
    NSDate *lastAccountManagerInfoUpdate;
    NSDate *lastGlobalPreferencesUpdate;
    NSDate *lastProxySettingsUpdate;
    
    // polling RPC info
    NSTimer                *_pollingRPCTimer;
    NSString               *pollingRPCMessage;
    id                      pollingTarget;
    SEL                     pollingCallbackSelector;
    SEL                     pollingRPCReplySelector;
    BOOL                    pollingRPCInProgress;
}
@property (nonatomic, retain)   BOINCClientStatus      *ccStatus;
@property (nonatomic, retain)   BOINCHostConnection    *ccConnection;

@property (readonly)            NSString               *uuid;
@property (nonatomic, copy)     NSString               *hostAddress;
@property (nonatomic, copy)     NSString               *clientName;
@property (readonly)            NSString               *fullName;
@property (nonatomic, assign)   NSString               *password;
@property (readonly)            BOOL                    isPasswordInKeychain;
@property (readonly)            BOOL                    isLocalHost;
@property (nonatomic, retain)   BOINCKeychainItem      *hostKeychainItem;
@property (readonly)            NSDate                 *modifiedDate;
@property (readonly)            double                  totalCredit;
@property (readonly)            double                  totalRAC;

@property (nonatomic, readonly) BOOL                    isAuthorized;
@property (nonatomic, readonly) BOOL                    isConnected;
@property (nonatomic, assign)   BOOL                    isAlwaysConnected;
@property (nonatomic, assign)   int                     connectionStatus;
@property (readonly)            NSString               *connectionStatusDescription;

@property (nonatomic, retain)   BOINCClientVersion     *version;
@property (nonatomic, retain)   NSMutableArray         *projects;
@property (nonatomic, retain)   BOINCAllProjectsList   *allProjectsList;
@property (nonatomic, retain)   BOINCClientState       *clientState;
@property (nonatomic, retain)   BOINCNetStatistics     *netStats;
@property (nonatomic, retain)   BOINCTimeStatistics    *timeStats;
@property (nonatomic, retain)   BOINCCreditMilestone   *hostTotalCreditMilestone;
@property (nonatomic, retain)   BOINCHostInfo          *hostInfo;
@property (nonatomic, retain)   BOINCAccountManager    *accountManager;
@property (nonatomic, retain)   BOINCGlobalPreferences *workingPreferences;
@property (nonatomic, assign)   NSInteger               prefStateIndex;
@property (nonatomic, retain)   BOINCNetProxySettings  *proxySettings;

@property (nonatomic, copy) NSDate *lastProjectsAndTasksUpdate;
@property (nonatomic, copy) NSDate *lastClientStateUpdate;
@property (nonatomic, copy) NSDate *lastAllProjectsListUpdate;
@property (nonatomic, copy) NSDate *lastAccountManagerInfoUpdate;
@property (nonatomic, copy) NSDate *lastGlobalPreferencesUpdate;
@property (nonatomic, copy) NSDate *lastProxySettingsUpdate;


- (id)initWithBOINCKeychainItem:(BOINCKeychainItem *)item;
- (void)willDeleteClient;

- (NSString *)readLocalPassword;

- (BOOL)connectWithPassword:(NSString *)aPassword;
- (void)clientConnectionDidConnect;
- (void)closeConnection;


// ack!!!
- (BOINCProject *)addOrUpdateProject:(BOINCProject *)newProject;



// RPCs
//    all RPCs are async
//    use KVO to observe the coresponding property to be notified when the RPC updates the BOINCClient info
//    setter RPCs will automatically request an update of the appropriate info

//      KVO property: ccStatus (will only notify if there is a change in one of the BOINCClientStatus properties)
- (void)requestCCStatusUpdate;

//      no KVO
- (void)requestQuit;

//      KVO property: lastProjectsAndTasksUpdate
- (void)requestProjectsAndTasksUpdate;

//      KVO property: lastClientStateUpdate
- (void)requestClientStateUpdate;

//      KVO property: lastAllProjectsListUpdate
- (void)requestAllProjectsListUpdate;

//      KVO property: lastAccountManagerInfoUpdate
- (void)requestAccountManagerInfoUpdate;

//      KVO property: 
- (void)requestProjectStatisticsUpdate;

- (void)setClientRunMode:(NSString *)mode         withDuration:(double)duration;
- (void)setClientNetworkMode:(NSString *)mode     withDuration:(double)duration;
- (void)performRPCOperation:(NSString *)operation onProject:(BOINCProject *)project;

//      KVO property: lastGlobalPreferencesUpdate
- (void)requestGlobalPreferencesUpdate;

- (void)clearGlobalPrefsOverrideFile;
// setting the global preferences will automatically re-read the settings when done
- (void)setGlobalPrefsOverride:(NSString *)overridePrefsXMLString;

//      KVO property: lastProxySettingsUpdate
- (void)requestProxySettingsUpdate;
// setting the proxy info will automatically re-read the settings when done
- (void)setProxyInformation:(BOINCNetProxySettings *)settings;



// polling RPCs used for attaching to projects and account managers

- (void)cancelExistingPollingRPC;

// callback signiture for Project Configuration
// - (void)projectConfigurationCallback:(BOINCProjectConfig *)projectConfiguration
- (void)performProjectConfigurationRequestForURL:(NSString *)projectURL 
                                          target:(id)target 
                                callbackSelector:(SEL)callbackSelector;

// callback signiture for both Lookup and Create account
// - (void)accountCallback:(BOINCAccountOut *)accountInfo
- (void)performLookupAccountRequestForAccount:(NSString *)emailOrUsername 
                                 withPassword:(NSString *)password 
                                        atURL:(NSString *)projectURL 
                                       target:(id)target 
                             callbackSelector:(SEL)callbackSelector;

- (void)performCreateAccountRequestForAccount:(NSString *)emailAddress 
                                 withUserName:(NSString *)userName 
                                  andPassword:(NSString *)password 
                                        atURL:(NSString *)projectURL 
                                       target:(id)target 
                             callbackSelector:(SEL)callbackSelector;

// callback signiture for Project Attach
// - (void)projectAttachCallback:(BOINCAttachReply *)projectAttachReply
- (void)performProjectAttachRequestForProject:(NSString *)projectName 
                                        atURL:(NSString *)projectURL 
                            withAuthenticator:(NSString *)authenticator 
                                       target:(id)target 
                             callbackSelector:(SEL)callbackSelector;

// callback signiture for Account Manager Attach
// - (void)accountManagerAttachCallback:(BOINCAttachReply *)managerAttachReply
- (void)performAccountManagerAttachRequestForURL:(NSString *)managerURL
                                    withUserName:(NSString *)userName 
                                     andPassword:(NSString *)password
                                          target:(id)target
                                callbackSelector:(SEL)callbackSelector;

- (void)performAccountManagerDetachRequest;

- (void)performAccountManagerSynchronizeForTarget:(id)target callbackSelector:(SEL)callbackSelector;

@end
