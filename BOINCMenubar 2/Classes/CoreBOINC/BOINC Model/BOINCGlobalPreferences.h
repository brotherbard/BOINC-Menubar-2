//
//  BOINCGlobalPreferences.h
//  BOINCMenubar
//
//  Created by BrotherBard on 5/18/08.
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
#import "BBXMLParsingDescription.h"

@class BOINCDailyTimeLimits;

extern NSString * const kMondayKey;
extern NSString * const kTuesdayKey;
extern NSString * const kWednesdayKey;
extern NSString * const kThursdayKey;
extern NSString * const kFridayKey;
extern NSString * const kSaturdayKey;
extern NSString * const kSundayKey;


@interface BOINCGlobalPreferences : NSObject <BBXMLModelObject, NSCopying>
{
    NSString *sourceProjectURL;
    double    modTime;
    
    BOOL      shouldRunIfUserActive;
    double    idleTimeBeforeRunningMinutes;
    double    suspendIfNoRecentInputMinutes;
    BOOL      shouldRunOnBatteries;
    
    double    cpuSchedulingPeriodMinutes;
    double    maxNumCPUsPercent;
    double    cpuTimeUsageLimitPercent;
    
    double    maxBytesPerSecondDownloadRate;
    double    maxBytesPerSecondUploadRate;
    double    workBufferMinimumDays;
    double    workBufferAdditionalDays;
    BOOL      shouldSkipVerifingImages;
    
    BOOL      shouldConfirmBeforeConnecting;
    BOOL      shouldHangupIfDialed;
    
    double    diskMaxUsedGB;
    double    diskMinimumFreeGB;
    double    diskMaxUsedPercent;
    double    writeToDiskIntervalSeconds;
    double    vmMaxUsedFraction;
    
    double    ramMaxUsedWhileBusyPercent;
    double    ramMaxUsedWhileIdlePercent;
    BOOL      shouldLeaveAppsInMemory;
    
    NSMutableDictionary  *weekdayTimeLimits;
    BOINCDailyTimeLimits *dailyTimeLimits;
    
    NSArray              *weekdayKeys;
    NSDateFormatter      *formatter;
}
// properties from the xml
@property (nonatomic, copy)   NSString *sourceProjectURL;
@property (nonatomic, assign) double    modTime;
    // Computing Allowed
@property (nonatomic, assign) BOOL      shouldRunIfUserActive;
@property (nonatomic, assign) double    idleTimeBeforeRunningMinutes;
@property (nonatomic, assign) double    suspendIfNoRecentInputMinutes; // a web only pref 
@property (nonatomic, assign) BOOL      shouldRunOnBatteries;
    // Processor Options
@property (nonatomic, assign) double    cpuSchedulingPeriodMinutes;
@property (nonatomic, assign) double    maxNumCPUsPercent;
@property (nonatomic, assign) double    cpuTimeUsageLimitPercent;
    // General Network Options
@property (nonatomic, assign) double    maxBytesPerSecondDownloadRate;
@property (nonatomic, assign) double    maxBytesPerSecondUploadRate;
@property (nonatomic, assign) double    workBufferMinimumDays;
@property (nonatomic, assign) double    workBufferAdditionalDays;
@property (nonatomic, assign) BOOL      shouldSkipVerifingImages;
    // Connection Options
@property (nonatomic, assign) BOOL      shouldConfirmBeforeConnecting;
@property (nonatomic, assign) BOOL      shouldHangupIfDialed;
    // Disk Usage
@property (nonatomic, assign) double    diskMaxUsedGB;
@property (nonatomic, assign) double    diskMinimumFreeGB;
@property (nonatomic, assign) double    diskMaxUsedPercent;
@property (nonatomic, assign) double    writeToDiskIntervalSeconds;
@property (nonatomic, assign) double    vmMaxUsedFraction;
    // Memory Usage
@property (nonatomic, assign) double    ramMaxUsedWhileBusyPercent;
@property (nonatomic, assign) double    ramMaxUsedWhileIdlePercent;
@property (nonatomic, assign) BOOL      shouldLeaveAppsInMemory;
    // daily and weekday time restrictions
@property (nonatomic, retain) NSMutableDictionary  *weekdayTimeLimits;
@property (nonatomic, retain) BOINCDailyTimeLimits *dailyTimeLimits;

- (void)addWeekdayTimeLimit:(BOINCDailyTimeLimits *)dayPref;

- (NSString *)xmlRepresentation;


- (NSString *)debugDescriptionWithIndent:(NSInteger)indent;
- (NSString *)debugDescription;

@end
