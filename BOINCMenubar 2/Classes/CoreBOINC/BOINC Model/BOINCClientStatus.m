//
//  BOINCClientStatus.m
//  BOINCMenubar
//
//  Created by BrotherBard on 3/29/08.
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

#import "BOINCClientStatus.h"

#import "BOINCCommonConstants.h"


@implementation BOINCClientStatus

@synthesize networkStatus;
@synthesize amsPasswordError;
@synthesize taskSuspendReason;
@synthesize networkSuspendReason;
@synthesize taskMode;
@synthesize networkMode;
@synthesize permanentTaskMode;
@synthesize permanentNetworkMode;
@synthesize taskModeDelay;
@synthesize networkModeDelay;
@synthesize disallowAttach;
@synthesize simpleGUIOnly;

@dynamic    taskSuspendedReasonDescription;


///////////////////////////////////////////////////////////
// ignore taskModeDelay and networkModeDelay because these would cause a change every time with no usefull info 
- (BOOL)didStateChange:(BOINCClientStatus *)compareStatus
{
    if ((networkStatus        == compareStatus.networkStatus) &&
        (amsPasswordError     == compareStatus.amsPasswordError) &&
        (taskSuspendReason    == compareStatus.taskSuspendReason) &&
        (networkSuspendReason == compareStatus.networkSuspendReason) &&
        (taskMode             == compareStatus.taskMode) &&
        (networkMode          == compareStatus.networkMode) &&
        (permanentTaskMode    == compareStatus.permanentTaskMode) &&
        (permanentNetworkMode == compareStatus.permanentNetworkMode) &&
        (disallowAttach       == compareStatus.disallowAttach) &&
        (simpleGUIOnly        == compareStatus.simpleGUIOnly))
        return NO;
    return YES;
}


- (NSString *)taskSuspendedReasonDescription
{
    switch (self.taskSuspendReason) {
        case kBOINCSuspendReasonBatteries:
            return NSLocalizedString(@"Running on batteries",      @"Suspended because host is running on batteries");
        case kBOINCSuspendReasonUserActive:
            return NSLocalizedString(@"User activity",             @"Suspended because user is active");
        case kBOINCSuspendReasonUserRequest:
            return NSLocalizedString(@"Requested by user",         @"Suspended because user requested boinc to stop/suspend");
        case kBOINCSuspendReasonTimeOfDay:
            return NSLocalizedString(@"Time of day limits",        @"Suspended because user has set time of day limits");
        case kBOINCSuspendReasonBenchmarks: 
            return NSLocalizedString(@"Benchmarks running",        @"Suspended because benchmarks are running");
        case kBOINCSuspendReasonDiskSize:
            return NSLocalizedString(@"Disk usage limit exceeded", @"Suspended because disk usage limit has been exceeded");
        case kBOINCSuspendReasonCPUUsageLimit: 
            return NSLocalizedString(@"CPU usage limit",           @"Suspended because of CPU usage limit");
        case kBOINCSuspendReasonNoRecentInput: 
            return NSLocalizedString(@"No recent input",           @"Suspended because there has been no recent input");
        case kBOINCSuspendReasonInitialDelay: 
            return NSLocalizedString(@"Inital delay",              @"Suspended durning inital delay");
        default:
            break;
    }
    
    return @"";
}



///////////////////////////////////////////////////////////
#pragma mark -
#pragma mark <BBXMLModelObject> protocol methods

+ (BBXMLParsingDescription *)xmlParsingDescription
{
    static BBXMLParsingDescription *parseDescription = nil;
    if (parseDescription) 
        return parseDescription;
    
    parseDescription = [[BBXMLParsingDescription alloc] initWithTarget:self];
     [parseDescription addIntSelector:   @selector(setNetworkStatus:)        forElement:@"network_status"];
     [parseDescription addIntSelector:   @selector(setAmsPasswordError:)     forElement:@"ams_password_error"];
     [parseDescription addIntSelector:   @selector(setTaskSuspendReason:)    forElement:@"task_suspend_reason"];
     [parseDescription addIntSelector:   @selector(setNetworkSuspendReason:) forElement:@"network_suspend_reason"];
     [parseDescription addIntSelector:   @selector(setTaskMode:)             forElement:@"task_mode"];
     [parseDescription addIntSelector:   @selector(setNetworkMode:)          forElement:@"network_mode"];
     [parseDescription addIntSelector:   @selector(setPermanentTaskMode:)    forElement:@"task_mode_perm"];
     [parseDescription addIntSelector:   @selector(setPermanentNetworkMode:) forElement:@"network_mode_perm"];
     [parseDescription addDoubleSelector:@selector(setTaskModeDelay:)        forElement:@"task_mode_delay"];
     [parseDescription addDoubleSelector:@selector(setNetworkModeDelay:)     forElement:@"network_mode_delay"];
     [parseDescription addBoolSelector:  @selector(setDisallowAttach:)       forElement:@"disallow_attach"];
     [parseDescription addBoolSelector:  @selector(setSimpleGUIOnly:)        forElement:@"simple_gui_only"];
    
    return parseDescription;
}



///////////////////////////////////////////////////////////
#pragma mark -
#pragma mark debug

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"\n%@", [self debugDescriptionWithIndent:0]];
}


- (NSString *)debugDescriptionWithIndent:(NSInteger)indent
{
    NSMutableString *theDescription = [NSMutableString string];
    
    NSMutableString *indentString = [NSMutableString string];
    for (NSInteger i = 0; i < indent; i++)
        [indentString appendString:@"    "];
    
    [theDescription appendFormat:@"%@%@ <%p>\n", indentString, [self className], self];
    [theDescription appendFormat:@"%@    networkStatus        = %d\n", indentString, self.networkStatus];
    [theDescription appendFormat:@"%@    amsPasswordError     = %d\n", indentString, self.amsPasswordError];
    [theDescription appendFormat:@"%@    taskSuspendReason    = %d\n", indentString, self.taskSuspendReason];
    [theDescription appendFormat:@"%@    networkSuspendReason = %d\n", indentString, self.networkSuspendReason];
    [theDescription appendFormat:@"%@    taskMode             = %d\n", indentString, self.taskMode];
    [theDescription appendFormat:@"%@    networkMode          = %d\n", indentString, self.networkMode];
    [theDescription appendFormat:@"%@    permanentTaskMode    = %d\n", indentString, self.permanentTaskMode];
    [theDescription appendFormat:@"%@    permanentNetworkMode = %d\n", indentString, self.permanentNetworkMode];
    [theDescription appendFormat:@"%@    taskModeDelay        = %f\n", indentString, self.taskModeDelay];
    [theDescription appendFormat:@"%@    networkModeDelay     = %f\n", indentString, self.networkModeDelay];
    [theDescription appendFormat:@"%@    disallowAttach       = %@\n", indentString, self.disallowAttach ? @"YES" : @"NO"];
    [theDescription appendFormat:@"%@    simpleGUIOnly        = %@\n", indentString, self.simpleGUIOnly  ? @"YES" : @"NO"];  
    
    return theDescription;
}


@end
