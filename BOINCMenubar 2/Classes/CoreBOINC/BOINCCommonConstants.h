//
//  BOINCCommonConstants.h
//  BOINCMenubar
//
//  Created by BrotherBard on 4/6/08.
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

//
//  Some of these constants are from "common_defs.h" in the boinc project
//
//


#import <Cocoa/Cocoa.h>

// using 5.10.34 as the reported manager version for now
#define MANAGER_MAJOR_VERSION 5
#define MANAGER_MINOR_VERSION 10
#define MANAGER_RELEASE 34


// xml tags for project operation RPCs
extern NSString * const kTagProjectReset;
extern NSString * const kTagProjectDetach;
extern NSString * const kTagProjectUpdate;
extern NSString * const kTagProjectSuspend;
extern NSString * const kTagProjectResume;
extern NSString * const kTagProjectAllowMoreWork;
extern NSString * const kTagProjectNoMoreWork;
extern NSString * const kTagProjectDetachWhenDone;
extern NSString * const kTagProjectDontDetachWhenDone;


// states for taskMode and networkMode
enum BOINCTaskModeKeys {
    kRunModeAlways = 1,
    kRunModeAuto,
    kRunModeNever,
    kRunModeRestore  // restore permanent mode
};

// xml tags for taskMode and networkMode RPCs
extern NSString * const kTagRunModeAlways;
extern NSString * const kTagRunModeAuto;
extern NSString * const kTagRunModeNever;
extern NSString * const kTagRunModeRestore;

// values of networkStatus
enum BOINCNetworkStatusKeys {
    kNetworkStatusOnline = 0,
    kNetworkStatusNeedsConnection,
    kNetworkStatusCanDisconnect,
    kNetworkStatusLookupPending
};

// bitmap defs for BOINCClientStatus' taskSuspendReason and networkSuspendReason
enum BOINCSuspendReason {
    kBOINCSuspendReasonNotSuspeneded = 0,
    kBOINCSuspendReasonBatteries     = 1,
    kBOINCSuspendReasonUserActive    = 2,
    kBOINCSuspendReasonUserRequest   = 4,
    kBOINCSuspendReasonTimeOfDay     = 8,
    kBOINCSuspendReasonBenchmarks    = 16,
    kBOINCSuspendReasonDiskSize      = 32,
    kBOINCSuspendReasonCPUUsageLimit = 64,
    kBOINCSuspendReasonNoRecentInput = 128,
    kBOINCSuspendReasonInitialDelay  = 256
};

// the location of the working preference set
enum BOINCPreferenceStateIndexes {
    kBOINCPrefsProjectFile = 0,
    kBOINCPrefsLocalOverride
};

// for BOINCClients connectionStatus
enum BOINCHostConnectionStatus {
    kStatusBOINCNotInstalled = -99,
    kStatusBOINCClientQuit,
    kStatusConnectionFailed,
    kStatusPasswordFailed,
    
    kStatusNotConnected = 0,
    
    kStatusTestingConnection,
    kStatusIsConnecting,
    kStatusIsAuthorizing,
    kStatusConnected
};

// for user defaults
extern NSString * const kPreviousHostUUIDKey;

// codes used for the polling RPCs
extern const int kPollingInProgress;
extern const int kPollingFileNotFound;

extern const NSTimeInterval kPollingInterval;

extern NSString * const kPollingRPCMessageKey;
extern NSString * const kPollingTargetKey;
extern NSString * const kPollingCallbackSelectorKey;
extern NSString * const kRPCErrorNumberKey;
extern NSString * const kRPCXMLStringKey;
extern NSString * const kRPCFailureKey;


// for milestones

#define kBOINCUserCreditMilestoneNotification      @"BOINC User Credit Milestone"
#define kBOINCHostCreditMilestoneNotification      @"BOINC Host Credit Milestone"
#define kBOINCHostTotalCreditMilestoneNotification @"BOINC Host Total Credit Milestone"

#define kBOINCProjectKey @"Project"
#define kBOINCHostKey    @"Host"

extern const double CBKilobyte;
extern const double CBMegabyte;
extern const double CBGigabyte;
extern const double CBTerabyte;

extern const double CBMegaOperations;
