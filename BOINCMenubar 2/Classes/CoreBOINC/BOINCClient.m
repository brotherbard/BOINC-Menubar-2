//
//  BOINCClient.m
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

#import "BOINCClient.h"
#import "BOINCClientVersion.h"

#import "BOINCCommonConstants.h"
#import "BOINCClientStatus.h"
#import "BOINCHostConnection.h"
#import "BOINCClientProcess.h"
#import "BOINCGlobalPreferences.h"
#import "BOINCDailyTimeLimits.h"
#import "BOINCNetProxySettings.h"
#import "BOINCHostInfo.h"
#import "BOINCClientState.h"
#import "BOINCTimeStatistics.h"
#import "BOINCNetStatistics.h"

#import "BOINCProjectConfig.h"
#import "BOINCAccountOut.h"
#import "BOINCProjectAttach.h"
#import "BOINCRPCStatusReply.h"

#import "BOINCProject.h"
#import "BOINCTask.h"
#import "BOINCURL.h"
#import "BOINCPlatform.h"
#import "BOINCProjectSummary.h"
#import "BOINCAccountManagerSummary.h"
#import "BOINCAllProjectsList.h"
#import "BOINCAccountManager.h"
#import "BOINCCreditMilestone.h"
#import "BOINCProjectStatistics.h"
#import "BOINCDailyProjectStatistics.h"

#import "BBXMLReader.h"
#import "BBXMLParsingDescription.h"
#import "BB_XMLNodeXPathCategory.h"

#import "NSString+BB_CommonCryptoDigest.h"
#import "BOINCKeychain.h"
#import "BOINCKeychainItem.h"
#import "Keychain/KeychainItem.h"




// Private
@interface BOINCClient()

- (void)requestClientVersionUpdate;
- (void)resetUpdateTimes;

@property (nonatomic, readwrite) BOOL isAuthorized;
@property (nonatomic, readwrite) BOOL isConnected;

@end


// in seconds
#define kProjectsAndTasksRPCRefreshLimit  1.0
#define kClientStateRPCRefreshLimit       1.0
#define kAllProjectsListRPCRefreshLimit   600.0
#define kGlobalPreferencesRPCRefreshLimit 1.0
#define kProxySettingsRPCRefreshLimit     1.0




#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BOINCClient


@synthesize ccStatus;
@synthesize ccConnection;
@synthesize projects;
@synthesize allProjectsList;
@synthesize isLocalHost;
@synthesize version;
@synthesize hostKeychainItem;
@synthesize isAuthorized;
@synthesize isConnected;
@synthesize isAlwaysConnected;
@synthesize connectionStatus;
@synthesize prefStateIndex;
@synthesize clientState;
@synthesize netStats;
@synthesize timeStats;
@synthesize hostTotalCreditMilestone;
@synthesize hostInfo;
@synthesize accountManager;
@synthesize workingPreferences;
@synthesize proxySettings;
@synthesize lastProjectsAndTasksUpdate;
@synthesize lastClientStateUpdate;
@synthesize lastAllProjectsListUpdate;
@synthesize lastAccountManagerInfoUpdate;
@synthesize lastGlobalPreferencesUpdate;
@synthesize lastProxySettingsUpdate;

@dynamic    uuid;
@dynamic    clientName;
@dynamic    hostAddress;
@dynamic    password;
@dynamic    modifiedDate;
@dynamic    fullName;
@dynamic    connectionStatusDescription;
@dynamic    totalCredit;
@dynamic    totalRAC;



- (id)initWithBOINCKeychainItem:(BOINCKeychainItem *)item
{
    if (!item) {
        [self release];
        self = nil;
        return nil;
    }
    self = [super init];
    if (!self) return nil;
    
    ccConnection     = [[BOINCHostConnection alloc] initWithClient:self];
    connectionStatus = kStatusNotConnected;
    
    hostKeychainItem         = [item retain];
    ccConnection.hostAddress = [hostKeychainItem address];
    
    lastProjectsAndTasksUpdate   = [[NSDate distantPast] copy];
    lastClientStateUpdate        = [[NSDate distantPast] copy];
    lastAllProjectsListUpdate    = [[NSDate distantPast] copy];
    lastAccountManagerInfoUpdate = [[NSDate distantPast] copy];
    lastGlobalPreferencesUpdate  = [[NSDate distantPast] copy];
    lastProxySettingsUpdate      = [[NSDate distantPast] copy];
    
    return self;
}


- (void)dealloc
{
    [ccStatus                     release];
    [ccConnection                 release];
    [projects                     release];
    [allProjectsList              release];
    [version                      release];
    [hostKeychainItem             release];
    [clientState                  release];
    [netStats                     release];
    [timeStats                    release];
    [hostInfo                     release];
    [workingPreferences           release];
    [proxySettings                release];
    [lastProjectsAndTasksUpdate   release];
    [lastClientStateUpdate        release];
    [lastAllProjectsListUpdate    release];
    [lastAccountManagerInfoUpdate release];
    [lastGlobalPreferencesUpdate  release];
    [lastProxySettingsUpdate      release];
    [_pollingRPCTimer             release];
    [hostTotalCreditMilestone     release];
    
    [super dealloc];
}


- (void)willDeleteClient
{
    [hostKeychainItem deleteKeychainItem];
}



///////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSObject methods

// Equal objects must hash the same, so test the same data that is used to create the hash

- (BOOL)isEqual:(id)object
{
    if (![object isMemberOfClass:[BOINCClient class]])
        return NO;
    
    return [self.uuid isEqualToString:((BOINCClient *)object).uuid];
}

- (NSUInteger)hash
{
    return [self.uuid hash];
}



///////////////////////////////////////////////////////////
#pragma mark -
#pragma mark BOINCClient methods

// if the project already exists then update the existing project and return the updated project
// else add and return the new project
- (BOINCProject *)addOrUpdateProject:(BOINCProject *)newProject
{
    for (BOINCProject *project in projects)
        if ([newProject hasSameURL:project.masterURL]) {
            [project updateWithProject:newProject];
            return project;
        }
    
    [newProject setClient:self];
    [projects addObject:newProject];
    return newProject;
}


- (NSString *)clientName
{
    return [self.hostKeychainItem name];
}


- (void)setClientName:(NSString *)name
{
    [self.hostKeychainItem setName:name];
}


- (NSString *)fullName
{
    return [NSString stringWithFormat:@"%@ (%@)", self.clientName, self.hostAddress];
}


- (NSString *)uuid
{
    return [self.hostKeychainItem uuid];
}


- (NSDate *)modifiedDate
{
    return [self.hostKeychainItem modifiedDate];
}



- (NSString *)hostAddress
{
    return [self.hostKeychainItem address];
}


- (void)setHostAddress:(NSString *)address
{
    [self.hostKeychainItem setAddress:address];
    ccConnection.hostAddress = [self.hostKeychainItem address];
}


- (BOOL)isLocalHost
{
    return [ccConnection isLocalHost];
}

- (void)setPassword:(NSString *)password
{
    [hostKeychainItem setPassword:password];
}


- (NSString *)password
{
    return [hostKeychainItem password];
}


- (BOOL)isPasswordInKeychain
{
    BOOL isValid = [self.hostKeychainItem isPasswordInKeychain];
    if ([self.hostKeychainItem lastError])
        return NO;
    return isValid;
}


- (NSString *)readLocalPassword
{
    NSString *path = @"/Library/Application Support/BOINC Data/gui_rpc_auth.cfg";
    
    return [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
}


- (double)totalCredit
{
    double totalCredit = 0.0;
    
    for (BOINCProject *project in projects)
        totalCredit += project.hostTotalCredit;
    
    return totalCredit;
}


- (double)totalRAC
{
    double totalRAC = 0.0;
    
    for (BOINCProject *project in projects)
        totalRAC += project.hostRAC;
    
    return totalRAC;
}


- (void)updateHostCreditMilestone
{
    if (hostTotalCreditMilestone == nil) {
        hostTotalCreditMilestone = [[BOINCCreditMilestone milestoneForValue:self.totalCredit] retain];
        return;
    }
    
    if ([hostTotalCreditMilestone hasPassedMilestoneWithUpdatedValue:self.totalCredit]) {
        BBLog(@"%@ has surpassed %f credits for all projects!", self.fullName, self.totalCredit);
		[[NSNotificationCenter defaultCenter] postNotificationName:kBOINCHostTotalCreditMilestoneNotification object:self];
    }
}


- (NSString *)connectionStatusDescription
{
    switch (self.connectionStatus) {
        case kStatusConnected:
            return NSLocalizedString(@"Connected",           @"Connected");
        case kStatusIsConnecting:
            return NSLocalizedString(@"Connecting...",       @"Connecting...");
        case kStatusIsAuthorizing:
            return NSLocalizedString(@"Authorizing...",      @"Authorizing...");
        case kStatusNotConnected:
            return NSLocalizedString(@"No Connection",       @"No Connection");
        case kStatusPasswordFailed: 
            return NSLocalizedString(@"Password failed",     @"Password failed");
        case kStatusConnectionFailed:
            return NSLocalizedString(@"Connection failed",   @"Connection failed");
        case kStatusBOINCClientQuit: 
            return NSLocalizedString(@"BOINC Client Quit",   @"BOINC Client Quit");
        case kStatusBOINCNotInstalled: 
            return NSLocalizedString(@"BOINC not installed", @"BOINC not installed");
        default:
            break;
    }
    
    return @"";
}


- (void)resetUpdateTimes
{
    self.lastProjectsAndTasksUpdate   = [NSDate distantPast];
    self.lastClientStateUpdate        = [NSDate distantPast];
    self.lastAllProjectsListUpdate    = [NSDate distantPast];
    self.lastAccountManagerInfoUpdate = [NSDate distantPast];
    self.lastGlobalPreferencesUpdate  = [NSDate distantPast];
    self.lastProxySettingsUpdate      = [NSDate distantPast];
}


// quietly (as in no KVO updates) reset the main timers
- (void)quietlyResetTimers
{
	[lastProjectsAndTasksUpdate release];
	lastProjectsAndTasksUpdate = [[NSDate distantPast] copy];
	
	[lastAllProjectsListUpdate release];
	lastAllProjectsListUpdate = [[NSDate distantPast] copy];
	
	[lastAccountManagerInfoUpdate release];
	lastAccountManagerInfoUpdate = [[NSDate distantPast] copy];
}



#pragma mark -
#pragma mark Opening/Closing the Client Connection
// for clients with the password set to "always ask":
//   aPassword is the password requested from the user in the log-in window 
//   unless the host is the localHost, then the password was read from BOINC's local password file
// for clients with the password set to "Store in Keychain":
//   aPassword is nil and the password is read from the Keychain
// 
- (BOOL)connectWithPassword:(NSString *)aPassword
{
    if (self.isConnected && self.isAuthorized)
        return YES;
    
    self.isConnected = NO;
    self.isAuthorized = NO;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:@"/Library/Application Support/BOINC Data"]) {
        BBError(@"Cannot run BOINC Client because BOINC is not installed on this system");
        self.connectionStatus = kStatusBOINCNotInstalled;
        return NO;
    }
    
    self.connectionStatus = kStatusIsConnecting;
    connectingData = [aPassword retain];
    return [self.ccConnection openConnection];
}


- (void)clientConnectionDidConnect
{
    self.connectionStatus = kStatusIsAuthorizing;
    [self.ccConnection queueRPCMessage:@"<auth1/>" target:self replySelector:@selector(authorizeNonceReply:)];
}


- (void)authorizeNonceReply:(NSString *)nonceReply
{
    // TODO: switch to XMLReader
    NSXMLDocument *nonceReplyXMLDoc = [[NSXMLDocument alloc] initWithXMLString:nonceReply options:NSXMLNodeOptionsNone error:nil];
    NSString *nonce = [nonceReplyXMLDoc bb_StringFromXPath:@".//nonce"];
    [nonceReplyXMLDoc release];
    if (!nonce) {
        self.connectionStatus = kStatusPasswordFailed;
        BBError(@"[%@] no nonce reply", self.fullName);
        return;
    }
    
    NSString *nonceHash = [[NSString stringWithFormat:@"%@%@", nonce, connectingData ? connectingData : self.password] bbMD5Hash];
    [connectingData release], connectingData = nil;
    if (!nonceHash) {
        self.connectionStatus = kStatusPasswordFailed;
        BBError(@"[%@] hashing nonce failed", self.fullName);
        return;
    }
    
    [self.ccConnection queueRPCMessage:[NSString stringWithFormat:@"<auth2><nonce_hash>%@</nonce_hash></auth2>", nonceHash] target:self replySelector:@selector(authorizedReply:)];
}


- (void)authorizedReply:(NSString *)authorizedReply
{
    // have to check "unauthorized" here, otherwise checking for "authorized" would have a false positive (why didn't they just use a boolean or a number???)
    NSRange unauthorizedRange = [authorizedReply rangeOfString:@"unauthorized" options:NSCaseInsensitiveSearch];
    if (unauthorizedRange.location != NSNotFound) {
        self.connectionStatus = kStatusPasswordFailed;
        [self.ccConnection closeConnection];
        BBError(@"Password failed. Access to BOINC client on %@ is unauthorized.", self.fullName);
        return;
    }
    
    // at this point the reply is either "authorized" or an rpc error
    NSRange authorizedRange = [authorizedReply rangeOfString:@"authorized" options:NSCaseInsensitiveSearch];
    if (authorizedRange.location == NSNotFound) {
        self.connectionStatus = kStatusPasswordFailed;
        [self.ccConnection closeConnection];
        BBError(@"BOINC XML-RPC to client %@ failed for <auth2> message. BOINC is not authorized.", self.fullName);
        return;
    }
    
    self.isAuthorized = YES;
    if (clientShouldQuit)
        [self requestQuit];
    else
        [self requestClientVersionUpdate];
}


- (void)closeConnection
{
    self.isConnected        = NO;
    self.isAuthorized       = NO;
    self.connectionStatus   = kStatusNotConnected;
    self.version            = nil;
    self.ccStatus           = nil;
    self.projects           = nil;
    self.clientState        = nil;
    self.allProjectsList    = nil;
    self.workingPreferences = nil;
    self.proxySettings      = nil;
    [self.ccConnection closeConnection];
    [self resetUpdateTimes];
}



// versions prior to 5.6 are not supported
// the <exchange_versions> RPC was added in 5.6.x so if there is an error response then checkClientVersion fails
- (void)requestClientVersionUpdate
{
    if (self.version || clientShouldQuit)
        return;
    
    NSString *request = [NSString stringWithFormat:
                         @"<exchange_versions>\n"
                         @"  <major>%d</major>\n"
                         @"  <minor>%d</minor>\n"
                         @"  <release>%d</release>\n"
                         @"</exchange_versions>", 
                         MANAGER_MAJOR_VERSION, 
                         MANAGER_MINOR_VERSION, 
                         MANAGER_RELEASE ];
    
    [self.ccConnection queueRPCMessage:request target:self replySelector:@selector(handleClientVersionReply:)];
}


// checkClientVersion will fail if the version is older than 5.6.x
- (void)handleClientVersionReply:(NSString *)rpcReply
{
    BOINCClientVersion *replyCCVersion = [BBXMLReader objectOfClass:[BOINCClientVersion class] 
                                                    withElementName:@"server_version" 
                                                      fromXMLString:rpcReply];
    if (!replyCCVersion) {
        BBError(@"Failed to update Client Version or BOINC client versions older than 5.6 (which is not supported by BOINCMenubar 2)");
        [self closeConnection];
        self.connectionStatus = kStatusConnectionFailed;
        return;
    }
    
    self.version = replyCCVersion;
    // not really doing anything with this yet, just log it
    BBError(@"BOINC Client = %@  Version = %@", self.clientName, self.version.versionString);
    
    self.isConnected = YES;
    self.connectionStatus = kStatusConnected;
    [self requestCCStatusUpdate];
    [self requestClientStateUpdate];
    [self requestAccountManagerInfoUpdate];
}


- (void)requestCCStatusUpdate
{
    if (!self.isConnected || clientShouldQuit)
        return;
    
    [self.ccConnection queueRPCMessage:@"<get_cc_status/>" target:self replySelector:@selector(handleCCStatusReply:)];
}


- (void)handleCCStatusReply:(NSString *)rpcReply
{
    BOINCClientStatus *replyCCStatus = [BBXMLReader objectOfClass:[BOINCClientStatus class] 
                                                  withElementName:@"cc_status" 
                                                    fromXMLString:rpcReply];
	
    if (!replyCCStatus) {
        BBError(@"Failed to update the Core Client Status");
        return;
    }
    
    BOOL didChange = [self.ccStatus didStateChange:replyCCStatus];
    if (!ccStatus || didChange) {
        self.ccStatus = replyCCStatus;
    }
}


///////////////////////////////////////////////////////////
#pragma mark -
#pragma mark BOINCClient RPC methods

/////////////////////////////////////////////////////////////////////////////
//
- (void)requestQuit
{
    if (!self.isAuthorized) {
        if ([self.ccConnection isLocalHost] && (connectionStatus >= kStatusIsConnecting)) {
            clientShouldQuit = YES;
            [self connectWithPassword:nil];
        }
        return;
    }
    
    [self.ccConnection queueRPCMessage:@"<quit/>" target:self replySelector:@selector(handleQuitReply:)];
}


// shouldn't need to do anything here
- (void)handleQuitReply:(NSString *)rpcReply
{
    BOINCRPCStatusReply *replyStatus = [BBXMLReader objectOfClass:[BOINCRPCStatusReply class] 
                                                  withElementName:@"set_global_prefs_override_reply" 
                                                    fromXMLString:rpcReply];
    
    if (!replyStatus.success)
        BBError(@"Success error = %d", replyStatus.success);
    
    [self closeConnection];
}


/////////////////////////////////////////////////////////////////////////////
//
- (void)requestProjectsAndTasksUpdate
{
    if (!self.isConnected || clientShouldQuit)
        return;
    
    // make sure this isn't executed too often
    if ([[NSDate date] timeIntervalSinceDate:self.lastProjectsAndTasksUpdate] < kProjectsAndTasksRPCRefreshLimit) {
        self.lastProjectsAndTasksUpdate = lastProjectsAndTasksUpdate; // causes KVO notice
        return;
    }
    
    [self.ccConnection queueRPCMessage:@"<get_simple_gui_info/>" target:self replySelector:@selector(handleProjectsAndTasksReply:)];
}


- (void)handleProjectsAndTasksReply:(NSString *)rpcReply
{
    if (rpcReply == nil) {
        BBLog(@"rpcReply is nil");
        return;
    }
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSDictionary *classDict = [NSDictionary dictionaryWithObjectsAndKeys:
                               [BOINCProject class], @"project", 
                               [BOINCTask class],    @"result", 
                               nil];
    NSArray *replyObjects = [BBXMLReader objectsInClassDictionary:classDict fromXMLString:rpcReply];
    if (replyObjects == nil) {
        BBError(@"Failed to parse Projects and Tasks");
        BBError(@"%@", rpcReply);
        [pool release];
        return;
    }
    if ([replyObjects count] == 0) 
        BBLog(@"No projects");
    
    if (self.projects == nil)
        projects = [[NSMutableArray alloc] init];
    
    // start with a copy of all the existing projects from the previous update so we can check to see if any have been detached
    NSMutableArray *oldProjects = [[projects mutableCopy] autorelease];
    NSMutableDictionary *projectsByURL = [NSMutableDictionary dictionary];
    
    for (id object in replyObjects) {
        if ([object isMemberOfClass:[BOINCProject class]]) {
            BOINCProject *currentProject = [self addOrUpdateProject:(BOINCProject *)object];
            [oldProjects removeObject:currentProject];
            [projectsByURL setObject:currentProject forKey:currentProject.masterURL];
        }
        else if ([object isMemberOfClass:[BOINCTask class]]) {
            // tasks are all at the end of the xml document and outside the project they belong to
            // find the project the task belongs to so the project can count them
            BOINCTask *task = (BOINCTask *)object;
            [[projectsByURL objectForKey:task.projectURL] countTask:task];
        } 
    }
    
    // any projects remaining in oldProjects array represent projects that have been detached since the last update
    for (BOINCProject *project in oldProjects) {
        BBLog(@"removing detached project: %@", project);
        [projects removeObject:project];
    }
    
    [self updateHostCreditMilestone];
    
    [pool release];
    
    self.lastProjectsAndTasksUpdate = [NSDate date];
    
}


/////////////////////////////////////////////////////////////////////////////
//
- (void)requestClientStateUpdate
{
    if (!self.isConnected || clientShouldQuit)
        return;
    if ([[NSDate date] timeIntervalSinceDate:self.lastClientStateUpdate] < kClientStateRPCRefreshLimit) {
        self.lastClientStateUpdate = lastClientStateUpdate; // causes KVO notice
        return;
    }
    [self.ccConnection queueRPCMessage:@"<get_state/>" target:self replySelector:@selector(handleClientStateReply:)];
}


- (void)handleClientStateReply:(NSString *)rpcReply
{
    BOINCClientState *replyClientState = [BBXMLReader objectOfClass:[BOINCClientState class] 
                                                    withElementName:@"client_state" 
                                                      fromXMLString:rpcReply];
    if (!replyClientState) {
        BBError(@"Failed to update the Client State");
        return;
    }
    
    if (replyClientState.hostInfo)
        self.hostInfo = replyClientState.hostInfo;
    
    if (replyClientState.netStats)
        self.netStats = replyClientState.netStats;
    
    if (replyClientState.timeStats)
        self.timeStats = replyClientState.timeStats;
    
    self.clientState = replyClientState;
    self.lastClientStateUpdate = [NSDate date];
}


/////////////////////////////////////////////////////////////////////////////
//
- (void)requestAllProjectsListUpdate
{
    if (!self.isConnected || clientShouldQuit)
        return;
    if (allProjectsList && ([[NSDate date] timeIntervalSinceDate:self.lastAllProjectsListUpdate] < kAllProjectsListRPCRefreshLimit)) {
        self.lastAllProjectsListUpdate = lastAllProjectsListUpdate; // causes KVO notice
        return;
    }
    
    [self requestProjectsAndTasksUpdate];
    [self requestClientStateUpdate];
    [self requestAccountManagerInfoUpdate];
    
    [self.ccConnection queueRPCMessage:@"<get_all_projects_list/>" target:self replySelector:@selector(handleAllProjectsListReply:)];
}


- (void)handleAllProjectsListReply:(NSString *)rpcReply
{
    BOINCAllProjectsList *replyList = [BBXMLReader objectOfClass:[BOINCAllProjectsList class] 
                                                 withElementName:@"projects" 
                                                   fromXMLString:rpcReply];
    if (replyList == nil) {
        BBError(@"Failed to update the All Projects List");
        return;
    }
    
    self.allProjectsList = replyList;
    [self.allProjectsList updateWithClient:self];
    
    self.lastAllProjectsListUpdate = [NSDate date];
}


/////////////////////////////////////////////////////////////////////////////
//
- (void)requestAccountManagerInfoUpdate
{
    if (!self.isConnected || clientShouldQuit)
        return;
    if (accountManager && ([[NSDate date] timeIntervalSinceDate:self.lastAccountManagerInfoUpdate] < kAllProjectsListRPCRefreshLimit)) {
        self.lastAccountManagerInfoUpdate = lastAccountManagerInfoUpdate; // causes KVO notice
        return;
    }
    
    [self.ccConnection queueRPCMessage:@"<acct_mgr_info/>" target:self replySelector:@selector(handleAccountManagerInfoReply:)];
}


- (void)handleAccountManagerInfoReply:(NSString *)rpcReply
{
    BOINCAccountManager *replyManagerInfo = [BBXMLReader objectOfClass:[BOINCAccountManager class] 
                                                       withElementName:@"acct_mgr_info" 
                                                         fromXMLString:rpcReply];
    if (replyManagerInfo == nil) {
        BBError(@"Failed to update Account Manager Info");
        self.accountManager = nil;
        return;
    }
    
    if ([replyManagerInfo.name isEqualToString:@""])
        replyManagerInfo = nil;
    
    self.accountManager = replyManagerInfo;
    
    self.lastAccountManagerInfoUpdate = [NSDate date];
}


/////////////////////////////////////////////////////////////////////////////
//
- (void)requestProjectStatisticsUpdate
{
    if (!self.isConnected || clientShouldQuit)
        return;
    //if (accountManager && ([[NSDate date] timeIntervalSinceDate:self.lastAccountManagerInfoUpdate] < kAllProjectsListRPCRefreshLimit)) {
    //    self.lastAccountManagerInfoUpdate = lastAccountManagerInfoUpdate; // causes KVO notice
    //    return;
    //}
    
    [self.ccConnection queueRPCMessage:@"<get_statistics/>" target:self replySelector:@selector(handleProjectStatisticsReply:)];
}


- (void)handleProjectStatisticsReply:(NSString *)rpcReply
{
    NSDictionary *classDict = [NSDictionary dictionaryWithObjectsAndKeys:
                               [BOINCProjectStatistics class], @"project_statistics", 
                               nil];
    NSArray *replyObjects = [BBXMLReader objectsInClassDictionary:classDict fromXMLString:rpcReply];
    
    if (replyObjects == nil) {
        BBError(@"Failed to update Project Statistics");
        return;
    }
    
    for (id object in replyObjects)
    	BBLog(@"%@", [object debugDescription]);
    
    //self.lastAccountManagerInfoUpdate = [NSDate date];
}



#pragma mark -
#pragma mark RPC Operations
// for all the operations; don't worry about the RPC reply, just update the ccStatus

- (void)setClientRunMode:(NSString *)mode withDuration:(double)duration
{
    if (!self.isConnected || clientShouldQuit)
        return;
    
    [self.ccConnection queueRPCMessage:[NSString stringWithFormat:@"<set_run_mode>%@<duration>%f</duration></set_run_mode>", mode, duration] target:self replySelector:@selector(handleOperationReply:)];
}


- (void)setClientNetworkMode:(NSString *)mode withDuration:(double)duration
{
    if (!self.isConnected || clientShouldQuit)
        return;
    
    [self.ccConnection queueRPCMessage:[NSString stringWithFormat:@"<set_network_mode>%@<duration>%f</duration></set_network_mode>", mode, duration] target:self replySelector:@selector(handleOperationReply:)];
}


- (void)performRPCOperation:(NSString *)operation onProject:(BOINCProject *)project
{
    if (!self.isConnected || clientShouldQuit)
        return;
    if (operation == kTagProjectDetach)
        BBLog(@"Detaching from %@", project.projectName);
    
    [self.ccConnection queueRPCMessage:[NSString stringWithFormat:@"<%@><project_url>%@</project_url></%@>", operation, project.masterURL, operation] target:self replySelector:@selector(handleOperationReply:)];
    
    if (operation == kTagProjectDetach) {
		[self quietlyResetTimers];
        
        [self requestAllProjectsListUpdate];
    }
}


// I don't really care about the reply, I can't do anything about it if it fails
- (void)handleOperationReply:(NSString *)rpcReply
{
    [self requestCCStatusUpdate];
}



#pragma mark -
#pragma mark BOINC preferences

//  Global Preferences
//    there are two places that the global preferences can come from
// 
//    Web Prefs   ==   global_prefs.xml
//      This comes from the settings on the web site of one of the projects the participant is attached to. By using the web it allows
//      a participant to change the settings in one place to control all the computers they have running BOINC.
// 
//    Local Override   ==  global_prefs_override.xml
//      This is a file created if the participant changes the settings at the computer. Once this is set the Project's preferences are
//      not used. These can only affect the computer they are set on. If the Local prefs are not set the client will either return an
//      empty reply (v5.10.x) or an error(v6.X).
// 
//    BMB wants to get the preferences but also needs to know where they came from. BOINC's GUI RPCs were not really designed for that.
//
//    On 6.x whichever set is active the values for it are returned by the RPC <get_global_prefs_working/> but, since it won't tell
//    us whether the prefs are a local override or from the web, I check for the override file first. 
//    On 5.10.x the core client doesn't have any override RPCs and will return "unrecognized op" for them. The current prefs are in
//    the <get_state> RPC. Need to figure out how to change prefs using 5.10.x RPC's.
// 
//    prefStateIndex
//      This indicates which preference set is the source for the working preferences.
// 
//      ATTEMPT 1: determine if the Local Override prefs exist via the <get_global_prefs_override/> RPC
//                 set self.prefStateIndex to kBOINCPrefsLocalOverride
// 
//      ATTEMPT 2: get the current working set (Web Prefs) via the <get_global_prefs_working/> RPC
//                 set self.prefStateIndex to kBOINCPrefsProjectFile
// 
//      ATTEMPT 3: if we get the "unrecognized op" error then the client is 5.10.x and doesn't support the working/override set of RPCs
//                 so we call <get_state> and at the end it is the global prefs element (this is a very expensive operation)
//                 the modTime is only set for Web Prefs
//                   so if the modTime has been set: 
//                     set self.prefStateIndex to kBOINCPrefsProjectFile
//                   if not: 
//                     set self.prefStateIndex to kBOINCPrefsLocalOverride
// 
//    Note: there is also a <get_global_prefs_file/> RPC, basically the contents of the global_prefs.xml stored from the last project
//    to update the preferences (the rpc reply is filtered to only give the venue active for that host). We don't need this RPC because
//    if the override has not been set then the working set RPC will have the same content as this file.
// 
//    Sets self.workingPreferences to the values of the current preferences.
//    Sets self.prefStateIndex to kBOINCPrefsLocalOverride or kBOINCPrefsProjectFile.
//
- (void)requestGlobalPreferencesUpdate
{
    if (!self.isConnected || clientShouldQuit)
        return;
    if (([[NSDate date] timeIntervalSinceDate:self.lastGlobalPreferencesUpdate] < kGlobalPreferencesRPCRefreshLimit)) {
        self.lastGlobalPreferencesUpdate = lastGlobalPreferencesUpdate; // causes KVO notice
        return;
    }
    
    // ATTEMPT 1
    // start with the <get_global_prefs_override/> RPC
    [self.ccConnection queueRPCMessage:@"<get_global_prefs_override/>" target:self replySelector:@selector(handleGlobalPreferencesOverrideReply:)];
}


- (void)handleGlobalPreferencesOverrideReply:(NSString *)rpcReply
{
    BOINCGlobalPreferences *replyPrefs = [BBXMLReader objectOfClass:[BOINCGlobalPreferences class] 
                                                    withElementName:@"global_preferences" 
                                                      fromXMLString:rpcReply];
    if (replyPrefs) {
        // success
        self.workingPreferences = replyPrefs;
        self.prefStateIndex = kBOINCPrefsLocalOverride;
        self.lastGlobalPreferencesUpdate = [NSDate date];
        return;
    }
    
    
    // ATTEMPT 2
    // the previous RPC did not return a valid pref
    // try the <get_global_prefs_working/> RPC
    if (!self.isConnected || clientShouldQuit)
        return;
    [self.ccConnection queueRPCMessage:@"<get_global_prefs_working/>" target:self replySelector:@selector(handleGlobalPreferencesWorkingReply:)];
}


- (void)handleGlobalPreferencesWorkingReply:(NSString *)rpcReply
{
    BOINCGlobalPreferences *replyPrefs = [BBXMLReader objectOfClass:[BOINCGlobalPreferences class] 
                                                    withElementName:@"global_preferences" 
                                                      fromXMLString:rpcReply];
    if (replyPrefs) {
        // success
        self.workingPreferences = replyPrefs;
        self.prefStateIndex = kBOINCPrefsProjectFile;
        self.lastGlobalPreferencesUpdate = [NSDate date];
        return;
    }
    
    
    // ATTEMPT 3
    // the previous two RPCs did not return valid prefs most likely this is a 5.10.x client 
    // do the <get_state/> RPC 
    // this is somewhat wastefull as the client state xml is large and we only need a little bit at the end
    if (!self.isConnected || clientShouldQuit)
        return;
    [self.ccConnection queueRPCMessage:@"<get_state/>" target:self replySelector:@selector(handleGlobalPreferencesFromClientStateReply:)];
}


- (void)handleGlobalPreferencesFromClientStateReply:(NSString *)rpcReply
{
    BOINCGlobalPreferences *replyPrefs = [BBXMLReader objectOfClass:[BOINCGlobalPreferences class] 
                                                    withElementName:@"global_preferences" 
                                                      fromXMLString:rpcReply];
    if (replyPrefs) {
        // success
        self.workingPreferences = replyPrefs;
        if (self.workingPreferences.modTime > 0.0f)
            self.prefStateIndex = kBOINCPrefsProjectFile;
        else
            self.prefStateIndex = kBOINCPrefsLocalOverride;
        self.lastGlobalPreferencesUpdate = [NSDate date];
        return;
    }
    
    
    // all three RPCs failed
    BBError(@"Failed to update BOINC Global Preferences");
}


//  Sending an empty string will cause the core client to delete the global_prefs_override.xml file and revert back to the web preferences.
//  Afterwards make sure our internal representation of the prefs is accurate/up-to-date with updateGlobalPreferences.
//
//  BOINC's xml parser needs the element names to end with a new line, so add a \n to represent an "empty" string.
//    It's parser searchs for and removes "<set_global_prefs_override>\n" and "</set_global_prefs_override>\n" and then compares the remaining string length to zero.
//    So apparently the closing tag for boinc-xml is ">\n" not just ">" as in normal xml (but only in some cases).
//    Also don't add any other chars to the message string (like tabs), but spaces appear to be ok???.
//
- (void)clearGlobalPrefsOverrideFile
{
    if (!self.isConnected || clientShouldQuit)
        return;
    
    [self.ccConnection queueRPCMessage:@"<set_global_prefs_override>\n</set_global_prefs_override>\n" target:self replySelector:@selector(handleClearGlobalPrefsOverrideFileReply:)];
}


- (void)handleClearGlobalPrefsOverrideFileReply:(NSString *)rpcReply
{
    BOINCRPCStatusReply *replyStatus = [BBXMLReader objectOfClass:[BOINCRPCStatusReply class] 
                                                  withElementName:@"set_global_prefs_override_reply" 
                                                    fromXMLString:rpcReply];
    
    if (replyStatus.status != 0)
        BBError(@"Status error = %d", replyStatus.status);
    
    self.lastGlobalPreferencesUpdate = [NSDate distantPast];
    [self requestGlobalPreferencesUpdate];
}


// setting (or changing) the global_prefs_override.xml file involves two steps
//
//    1:  send set_global_prefs_override RPC with the new preferences
//        this will create the override file if it did not exist or rewrite with new data if it did
//        the reply should be:
//          <boinc_gui_rpc_reply>
//          <set_global_prefs_override_reply>
//          <status>0</status>
//          </set_global_prefs_override_reply>
//          </boinc_gui_rpc_reply>
//        status will be zero for success or have an error number
//        (see error_numbers.h and boincerror() in str_util.c for error numbers and descriptions)
//
//    2:  send read_global_prefs_override RPC
//        just setting the override file will not cause the core client to use it 
//        the core client needs to be told to read the file seperatly
//
//  afterwards make sure our internal representation of the prefs is accurate/up-to-date by sending updateGlobalPreferences
//
- (void)setGlobalPrefsOverride:(NSString *)overridePrefsXMLString
{
    if (!self.isConnected || clientShouldQuit)
        return;
    
    [self.ccConnection queueRPCMessage:[NSString stringWithFormat:@"<set_global_prefs_override>\n%@</set_global_prefs_override>\n", overridePrefsXMLString] target:self replySelector:@selector(handleSetGlobalPrefsOverrideReply:)];
}


- (void)handleSetGlobalPrefsOverrideReply:(NSString *)rpcReply
{
    BOINCRPCStatusReply *replyStatus = [BBXMLReader objectOfClass:[BOINCRPCStatusReply class] 
                                                  withElementName:@"set_global_prefs_override_reply" 
                                                    fromXMLString:rpcReply];
    
    if (replyStatus.status != 0) {
        BBError(@"Status error = %d", replyStatus.status);
        return;
    }
    
    if (!self.isConnected || clientShouldQuit)
        return;
    [self.ccConnection queueRPCMessage:@"<read_global_prefs_override/>\n" target:self replySelector:@selector(handleReadGlobalPrefsOverrideReply:)];
}


- (void)handleReadGlobalPrefsOverrideReply:(NSString *)rpcReply
{
    self.lastGlobalPreferencesUpdate = [NSDate distantPast];
    [self requestGlobalPreferencesUpdate];
}


/////////////////////////////////////////////////////////////////////////////
// The settings for network proxy servers
//
- (void)requestProxySettingsUpdate
{
    if (!self.isConnected || clientShouldQuit)
        return;
    if (([[NSDate date] timeIntervalSinceDate:self.lastProxySettingsUpdate] < kProxySettingsRPCRefreshLimit)) {
        self.lastProxySettingsUpdate = lastProxySettingsUpdate; // causes KVO notice
        return;
    }
    
    [self.ccConnection queueRPCMessage:@"<get_proxy_settings/>" target:self replySelector:@selector(handleProxySettingsReply:)];
}


- (void)handleProxySettingsReply:(NSString *)rpcReply
{
    BOINCNetProxySettings *replyProxySettings = [BBXMLReader objectOfClass:[BOINCNetProxySettings class] 
                                                           withElementName:@"proxy_info" 
                                                             fromXMLString:rpcReply];
    if (!replyProxySettings) {
        BBError(@"Failed to update the Network Proxy Settings");
        return;
    }
    
    self.proxySettings = replyProxySettings;
    self.lastProxySettingsUpdate = [NSDate date];
}


// setting the proxy info will automatically re-read the settings when done 
- (void)setProxyInformation:(BOINCNetProxySettings *)settings
{
    if (!self.isConnected || clientShouldQuit)
        return;
    
    [self.ccConnection queueRPCMessage:[NSString stringWithFormat:@"<set_proxy_settings>\n%@</set_proxy_settings>\n", [settings xmlRepresentation]] target:self replySelector:@selector(handleSetProxySettingsReply:)];
}


- (void)handleSetProxySettingsReply:(NSString *)rpcReply
{
    [self requestProxySettingsUpdate];
}



#pragma mark -
#pragma mark Polling RPCs

- (void)cancelExistingPollingRPC
{
    pollingRPCInProgress = NO;
}


- (void)schedulePollingRPCTimer
{
    if (!pollingRPCInProgress || clientShouldQuit)
        return;
    
    [NSTimer scheduledTimerWithTimeInterval:kPollingInterval 
                                     target:self 
                                   selector:@selector(pollRPC:)
                                   userInfo:nil 
                                    repeats:NO];
}


- (void)pollRPC:(NSTimer *)timer
{
    if (!pollingRPCInProgress || clientShouldQuit)
        return;
    
    [self.ccConnection queueRPCMessage:pollingRPCMessage target:self replySelector:pollingRPCReplySelector];
}


// send the response back to the originator of the RPC request
- (void)sendPollingRPCResponse:(id)response
{
    if (!pollingRPCInProgress || clientShouldQuit || (pollingCallbackSelector == NULL))
        return;
    
    pollingRPCInProgress = NO;
    [pollingTarget performSelector:pollingCallbackSelector 
                        withObject:response
                        afterDelay:0.0
                           inModes:[NSArray arrayWithObjects:NSDefaultRunLoopMode, NSModalPanelRunLoopMode, NSEventTrackingRunLoopMode, nil]];
}


// used to reply to the first RPC request that starts off all the polling RPCs
- (void)handlePollingRPCStatusReply:(NSString *)rpcReply
{
    if (!pollingRPCInProgress || clientShouldQuit)
        return;
    
    BOINCRPCStatusReply *replyStatus = [BBXMLReader objectOfClass:[BOINCRPCStatusReply class] 
                                                  withElementName:@"boinc_gui_rpc_reply" 
                                                    fromXMLString:rpcReply];
    
    if (replyStatus.success)
        [self schedulePollingRPCTimer];
    else {
        pollingRPCInProgress = NO;
        BBLog(@"Failed RPC with message: %@", replyStatus.errorMessage);
        // should send an error reply
    }
}


/////////////////////////////////////////////////////////////////////////////
//  Project Configuration
//
- (void)performProjectConfigurationRequestForURL:(NSString *)projectURL target:(id)target callbackSelector:(SEL)callbackSelector
{
    if (pollingRPCInProgress || clientShouldQuit)
        return;
    
    pollingRPCMessage = @"<get_project_config_poll/>";
    pollingTarget = target;
    pollingCallbackSelector = callbackSelector;
    pollingRPCReplySelector = @selector(handleProjectConfigurationRPCReply:);
    pollingRPCInProgress = YES;
    
    NSString *rpcRequest = [NSString stringWithFormat:@"<get_project_config>\n<url>%@</url>\n</get_project_config>", projectURL];
    
    [self.ccConnection queueRPCMessage:rpcRequest target:self replySelector:@selector(handlePollingRPCStatusReply:)];
}


- (void)handleProjectConfigurationRPCReply:(NSString *)rpcReply
{
    if (!pollingRPCInProgress || clientShouldQuit)
        return;
    
    BOINCProjectConfig *projectConfiguration = [BBXMLReader objectOfClass:[BOINCProjectConfig class]
                                                          withElementName:@"project_config" 
                                                            fromXMLString:rpcReply];
    
    BBLog(@"%@", [projectConfiguration debugDescription]);
    if (projectConfiguration.errorNumber == kPollingInProgress) {
        [self schedulePollingRPCTimer];
        return;
    }
    
    [self sendPollingRPCResponse:projectConfiguration];
}


/////////////////////////////////////////////////////////////////////////////
//  Lookup Account and Create Account
//
- (void)performLookupAccountRequestForAccount:(NSString *)emailOrUsername withPassword:(NSString *)password atURL:(NSString *)projectURL target:(id)target callbackSelector:(SEL)callbackSelector
{
    if (pollingRPCInProgress || clientShouldQuit)
        return;
    
    pollingRPCMessage = @"<lookup_account_poll/>";
    pollingTarget = target;
    pollingCallbackSelector = callbackSelector;
    pollingRPCReplySelector = @selector(handleAccountRPCReply:);
    pollingRPCInProgress = YES;
    
    NSString *passwordHash = [[NSString stringWithFormat:@"%@%@", password, [emailOrUsername lowercaseString]] bbMD5Hash];
    
    NSString *rpcRequest = [NSString stringWithFormat:@"<lookup_account>\n"
                            @"<url>%@</url>\n"
                            @"<email_addr>%@</email_addr>\n"
                            @"<passwd_hash>%@</passwd_hash>\n"
                            @"</lookup_account>", 
                            projectURL,
                            emailOrUsername,
                            passwordHash];
    
    [self.ccConnection queueRPCMessage:rpcRequest target:self replySelector:@selector(handlePollingRPCStatusReply:)];
}


- (void)performCreateAccountRequestForAccount:(NSString *)emailAddress withUserName:(NSString *)userName andPassword:(NSString *)password atURL:(NSString *)projectURL target:(id)target callbackSelector:(SEL)callbackSelector
{   
    if (pollingRPCInProgress || clientShouldQuit)
        return;
    
    pollingRPCMessage = @"<create_account_poll/>";
    pollingTarget = target;
    pollingCallbackSelector = callbackSelector;
    pollingRPCReplySelector = @selector(handleAccountRPCReply:);
    pollingRPCInProgress = YES;
    
    NSString *passwordHash = [[NSString stringWithFormat:@"%@%@", password, [emailAddress lowercaseString]] bbMD5Hash];
    
    NSString *rpcRequest = [NSString stringWithFormat:@"<create_account>\n"
                            @"<url>%@</url>\n"
                            @"<email_addr>%@</email_addr>\n"
                            @"<passwd_hash>%@</passwd_hash>\n"
                            @"<user_name>%@</user_name>\n"
                            @"</create_account>", 
                            projectURL,
                            emailAddress,
                            passwordHash,
                            userName ];
    
    [self.ccConnection queueRPCMessage:rpcRequest target:self replySelector:@selector(handlePollingRPCStatusReply:)];
}


- (void)handleAccountRPCReply:(NSString *)rpcReply
{
    if (!pollingRPCInProgress || clientShouldQuit)
        return;
    
    BOINCAccountOut *accountReply = [BBXMLReader objectOfClass:[BOINCAccountOut class]
                                               withElementName:@"account_out" 
                                                 fromXMLString:rpcReply];
    
    BBLog(@"%@", [accountReply debugDescription]);
    if (accountReply.errorNumber == kPollingInProgress) {
        [self schedulePollingRPCTimer];
        return;
    }
    
    // send the response back to the originator
    [self sendPollingRPCResponse:accountReply];
}


/////////////////////////////////////////////////////////////////////////////
//  Project Attach
//
- (void)performProjectAttachRequestForProject:(NSString *)projectName atURL:(NSString *)projectURL withAuthenticator:(NSString *)authenticator target:(id)target callbackSelector:(SEL)callbackSelector
{
    if (pollingRPCInProgress || clientShouldQuit)
        return;
    
    pollingRPCMessage = @"<project_attach_poll/>";
    pollingTarget = target;
    pollingCallbackSelector = callbackSelector;
    pollingRPCReplySelector = @selector(handleProjectAttachRPCReply:);
    pollingRPCInProgress = YES;
    
    NSString *rpcRequest = [NSString stringWithFormat:@"<project_attach>\n"
                            @"<project_url>%@</project_url>\n"
                            @"<authenticator>%@</authenticator>\n"
                            @"<project_name>%@</project_name>\n"
                            @"</project_attach>", 
                            projectURL,
                            authenticator,
                            projectName ];
    
    [self.ccConnection queueRPCMessage:rpcRequest target:self replySelector:@selector(handlePollingRPCStatusReply:)];
}


- (void)handleProjectAttachRPCReply:(NSString *)rpcReply
{
    if (!pollingRPCInProgress || clientShouldQuit)
        return;
    
    BOINCAttachReply *attachProjectReply = [BBXMLReader objectOfClass:[BOINCAttachReply class]
                                                      withElementName:@"project_attach_reply" 
                                                        fromXMLString:rpcReply];
    
    if (attachProjectReply.errorNumber == kPollingInProgress) {
        [self schedulePollingRPCTimer];
        return;
    }
    
    // assume we need to update the all projects list
    [self resetUpdateTimes];
    [self requestAllProjectsListUpdate];
    
    // send the response back to the originator
    [self sendPollingRPCResponse:attachProjectReply];
}


/////////////////////////////////////////////////////////////////////////////
//  Manager Attach/Detach
//
- (void)performAccountManagerAttachRequestForURL:(NSString *)managerURL  withUserName:(NSString *)userName andPassword:(NSString *)password target:(id)target callbackSelector:(SEL)callbackSelector
{
    if (pollingRPCInProgress || clientShouldQuit)
        return;
    
    pollingRPCMessage = @"<acct_mgr_rpc_poll/>";
    pollingTarget = target;
    pollingCallbackSelector = callbackSelector;
    pollingRPCReplySelector = @selector(handleAccountManagerAttachRPCReply:);
    pollingRPCInProgress = YES;
    
    NSString *rpcRequest = [NSString stringWithFormat:@"<acct_mgr_rpc>\n"
                            @"<url>%@</url>\n"
                            @"<name>%@</name>\n"
                            @"<password>%@</password>\n"
                            @"</acct_mgr_rpc>\n", 
                            managerURL,
                            userName,
                            password ];
    
    [self.ccConnection queueRPCMessage:rpcRequest target:self replySelector:@selector(handlePollingRPCStatusReply:)];
    
    [self quietlyResetTimers];
}


- (void)handleAccountManagerAttachRPCReply:(NSString *)rpcReply
{
    if (!pollingRPCInProgress || clientShouldQuit)
        return;
    
    BBLog(@"%@", rpcReply);
    
    BOINCAttachReply *attachReply = [BBXMLReader objectOfClass:[BOINCAttachReply class]
                                               withElementName:@"acct_mgr_rpc_reply" 
                                                 fromXMLString:rpcReply];
    
    if (attachReply.errorNumber == kPollingInProgress) {
        [self schedulePollingRPCTimer];
        return;
    }
    
    // assume we need to update everything
    [self requestAllProjectsListUpdate];
    
    // send the response back to the originator
    [self sendPollingRPCResponse:attachReply];
}


// to detach from the account manager, just send an acct_mgr_rpc RPC with no values
// don't need to return info so no reply selector for this
- (void)performAccountManagerDetachRequest
{
    if (pollingRPCInProgress || clientShouldQuit)
        return;
    
    pollingRPCReplySelector = @selector(handleAccountManagerDetachReply:);
    pollingRPCInProgress = YES;
    
    NSString *rpcRequest = @"<acct_mgr_rpc>\n<url></url>\n<name></name>\n<password></password>\n</acct_mgr_rpc>\n";
    
    [self.ccConnection queueRPCMessage:rpcRequest target:self replySelector:@selector(handleAccountManagerDetachReply:)];
    
    [self quietlyResetTimers];
}


// to allow the client app the time to remove the account manager files before we call -requestAllProjectsListUpdate
- (void)handleAccountManagerDetachReply:(NSString *)rpcReply
{
    if (!pollingRPCInProgress || clientShouldQuit)
        return;
    
    BBLog(@"%@", rpcReply);
    
    BOINCAttachReply *detachReply = [BBXMLReader objectOfClass:[BOINCAttachReply class]
                                               withElementName:@"acct_mgr_rpc_reply" 
                                                 fromXMLString:rpcReply];
    
    if (detachReply.errorNumber == kPollingInProgress) {
        [self schedulePollingRPCTimer];
        return;
    }
    
    [self requestAllProjectsListUpdate];
}



// will cause the client to contact the account manager and update it's projects 
- (void)performAccountManagerSynchronizeForTarget:(id)target callbackSelector:(SEL)callbackSelector
{
    if (pollingRPCInProgress || clientShouldQuit)
        return;
    
    if (self.accountManager == nil)
        return;
    
    pollingRPCMessage = @"<acct_mgr_rpc_poll/>";
    pollingTarget = target;
    pollingCallbackSelector = callbackSelector;
    pollingRPCReplySelector = @selector(handleSynchronizeWithAccountManagerReply:);
    pollingRPCInProgress = YES;
    
    NSString *rpcRequest = @"<acct_mgr_rpc>\n<use_config_file></use_config_file>\n</acct_mgr_rpc>\n";
    
    [self.ccConnection queueRPCMessage:rpcRequest target:self replySelector:@selector(handleSynchronizeWithAccountManagerReply:)];
    
    [self quietlyResetTimers];
}


- (void)handleSynchronizeWithAccountManagerReply:(NSString *)rpcReply
{
    if (!pollingRPCInProgress || clientShouldQuit)
        return;
    
    BBLog(@"%@", rpcReply);
    
    BOINCAttachReply *syncReply = [BBXMLReader objectOfClass:[BOINCAttachReply class]
                                             withElementName:@"boinc_gui_rpc_reply" 
                                               fromXMLString:rpcReply];
    
    if (syncReply.errorNumber == kPollingInProgress) {
        [self schedulePollingRPCTimer];
        return;
    }
    
    // send the response back to the originator
    [self sendPollingRPCResponse:syncReply];
}



@end
