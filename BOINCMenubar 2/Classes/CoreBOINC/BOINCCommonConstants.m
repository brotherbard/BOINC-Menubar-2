//
//  BOINCCommonConstants.m
//  BOINCMenubar
//
//  Created by BrotherBard on 5/6/08.
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


#import "BOINCCommonConstants.h"



// xml tags for taskMode and networkMode RPCs
NSString * const kTagRunModeAlways  = @"<always/>";
NSString * const kTagRunModeAuto    = @"<auto/>";
NSString * const kTagRunModeNever   = @"<never/>";
NSString * const kTagRunModeRestore = @"<restore/>";

// xml tags for project operation RPCs
NSString * const kTagProjectReset              = @"project_reset";
NSString * const kTagProjectDetach             = @"project_detach";
NSString * const kTagProjectUpdate             = @"project_update";
NSString * const kTagProjectSuspend            = @"project_suspend";
NSString * const kTagProjectResume             = @"project_resume";
NSString * const kTagProjectAllowMoreWork      = @"project_allowmorework";
NSString * const kTagProjectNoMoreWork         = @"project_nomorework";
NSString * const kTagProjectDetachWhenDone     = @"project_detach_when_done";
NSString * const kTagProjectDontDetachWhenDone = @"project_dont_detach_when_done";



// for the preference defaults dictionary
NSString * const kPreviousHostUUIDKey = @"Previous Host UUID";


// for polling RPCs (like attaching to projects)
const int kPollingInProgress   = -204;
const int kPollingFileNotFound = -224;

const NSTimeInterval kPollingInterval = 0.5f;

NSString * const kPollingRPCMessageKey       = @"pollingRPCMessgeKey";
NSString * const kPollingTargetKey           = @"pollingTargetKey";
NSString * const kPollingCallbackSelectorKey = @"pollingCallbackSelectorKey";
NSString * const kRPCErrorNumberKey          = @"RPCErrorNumberKey";
NSString * const kRPCXMLStringKey            = @"RPCXMLStringKey";
NSString * const kRPCFailureKey              = @"RPCFailureKey";



const double CBKilobyte = 1024.0;
const double CBMegabyte = 1024.0 * 1024.0;
const double CBGigabyte = 1024.0 * 1024.0 * 1024.0;
const double CBTerabyte = 1024.0 * 1024.0 * 1024.0 * 1024.0;

const double CBMegaOperations = 1000000.0;

