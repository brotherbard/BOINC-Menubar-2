//
//  BOINCGlobalPreferences.m
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


// NOTE: see BOINC prefs.C GLOBAL_PREFS::write_subset (line 687)

#import "BOINCGlobalPreferences.h"
#import "BOINCDailyTimeLimits.h"



NSString * const kMondayKey    = @"monday";
NSString * const kTuesdayKey   = @"tuesday";
NSString * const kWednesdayKey = @"wednesday";
NSString * const kThursdayKey  = @"thursday";
NSString * const kFridayKey    = @"friday";
NSString * const kSaturdayKey  = @"saturday";
NSString * const kSundayKey    = @"sunday";



@implementation BOINCGlobalPreferences

@synthesize sourceProjectURL;
@synthesize modTime;
@synthesize shouldRunOnBatteries;
@synthesize shouldRunIfUserActive;
@synthesize idleTimeBeforeRunningMinutes;
@synthesize suspendIfNoRecentInputMinutes;
@synthesize shouldLeaveAppsInMemory;
@synthesize shouldConfirmBeforeConnecting;
@synthesize shouldHangupIfDialed;
@synthesize shouldSkipVerifingImages;
@synthesize workBufferMinimumDays;
@synthesize workBufferAdditionalDays;
@synthesize maxNumCPUsPercent;
@synthesize cpuSchedulingPeriodMinutes;
@synthesize writeToDiskIntervalSeconds;
@synthesize diskMaxUsedGB;
@synthesize diskMaxUsedPercent;
@synthesize diskMinimumFreeGB;
@synthesize vmMaxUsedFraction;
@synthesize ramMaxUsedWhileBusyPercent;
@synthesize ramMaxUsedWhileIdlePercent;
@synthesize maxBytesPerSecondUploadRate;
@synthesize maxBytesPerSecondDownloadRate;
@synthesize cpuTimeUsageLimitPercent;
@synthesize weekdayTimeLimits;
@synthesize dailyTimeLimits;



- (id)init
{
    self = [super init];
    if (!self) return nil;
    
    dailyTimeLimits = [[BOINCDailyTimeLimits alloc] init];
    dailyTimeLimits.weekdayIndex = -1;
    
    weekdayKeys = [NSArray arrayWithObjects:kSundayKey, kMondayKey, kTuesdayKey, kWednesdayKey, kThursdayKey, kFridayKey, kSaturdayKey, nil];
    NSArray *blankTimeLimits = [NSArray arrayWithObjects:[BOINCDailyTimeLimits blankDayTimeLimit], [BOINCDailyTimeLimits blankDayTimeLimit], [BOINCDailyTimeLimits blankDayTimeLimit], [BOINCDailyTimeLimits blankDayTimeLimit], [BOINCDailyTimeLimits blankDayTimeLimit], [BOINCDailyTimeLimits blankDayTimeLimit], [BOINCDailyTimeLimits blankDayTimeLimit], nil];
    
    weekdayTimeLimits = [[NSMutableDictionary alloc] initWithObjects:blankTimeLimits forKeys:weekdayKeys];
    
    formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:@"H.m"];
    
    return self;
}


- (void)dealloc
{
    [sourceProjectURL  release];
    [weekdayTimeLimits release];
    [dailyTimeLimits   release];
    
    [super dealloc];
}



#pragma mark <NSCopying>
- (id)copyWithZone:(NSZone *)zone
{
    BOINCGlobalPreferences *copiedPrefs = [[BOINCGlobalPreferences allocWithZone:zone] init];
    
    copiedPrefs.sourceProjectURL                = self.sourceProjectURL;
    copiedPrefs.modTime                         = self.modTime;
    copiedPrefs.shouldRunOnBatteries            = self.shouldRunOnBatteries;
    copiedPrefs.shouldRunIfUserActive           = self.shouldRunIfUserActive;
    copiedPrefs.idleTimeBeforeRunningMinutes    = self.idleTimeBeforeRunningMinutes;
    copiedPrefs.suspendIfNoRecentInputMinutes   = self.suspendIfNoRecentInputMinutes;
    copiedPrefs.shouldLeaveAppsInMemory         = self.shouldLeaveAppsInMemory;
    copiedPrefs.shouldConfirmBeforeConnecting   = self.shouldConfirmBeforeConnecting;
    copiedPrefs.shouldHangupIfDialed            = self.shouldHangupIfDialed;
    copiedPrefs.shouldSkipVerifingImages        = self.shouldSkipVerifingImages;
    copiedPrefs.workBufferMinimumDays           = self.workBufferMinimumDays;
    copiedPrefs.workBufferAdditionalDays        = self.workBufferAdditionalDays;
    copiedPrefs.maxNumCPUsPercent               = self.maxNumCPUsPercent;
    copiedPrefs.cpuSchedulingPeriodMinutes      = self.cpuSchedulingPeriodMinutes;
    copiedPrefs.writeToDiskIntervalSeconds      = self.writeToDiskIntervalSeconds;
    copiedPrefs.diskMaxUsedGB                   = self.diskMaxUsedGB;
    copiedPrefs.diskMaxUsedPercent              = self.diskMaxUsedPercent;
    copiedPrefs.diskMinimumFreeGB               = self.diskMinimumFreeGB;
    copiedPrefs.vmMaxUsedFraction               = self.vmMaxUsedFraction;
    copiedPrefs.ramMaxUsedWhileBusyPercent      = self.ramMaxUsedWhileBusyPercent;
    copiedPrefs.ramMaxUsedWhileIdlePercent      = self.ramMaxUsedWhileIdlePercent;
    copiedPrefs.maxBytesPerSecondUploadRate     = self.maxBytesPerSecondUploadRate;
    copiedPrefs.maxBytesPerSecondDownloadRate   = self.maxBytesPerSecondDownloadRate;
    copiedPrefs.cpuTimeUsageLimitPercent        = self.cpuTimeUsageLimitPercent;
    copiedPrefs.dailyTimeLimits                 = [self.dailyTimeLimits copyWithZone:zone];
    copiedPrefs.weekdayTimeLimits               = [[NSMutableDictionary allocWithZone:zone] initWithDictionary:self.weekdayTimeLimits copyItems:YES];
    
    return copiedPrefs;
}



#pragma mark XML-specific setters
- (void)setCpuStartHourFromXMLString:(NSString *)timeString
{
    self.dailyTimeLimits.cpuStartHour = [formatter dateFromString:timeString];
    self.dailyTimeLimits.hasCPULimits = YES;
}


- (void)setCpuEndHourFromXMLString:(NSString *)timeString
{
    self.dailyTimeLimits.cpuEndHour = [formatter dateFromString:timeString];
    self.dailyTimeLimits.hasCPULimits = YES;
}



- (void)setNetStartHourFromXMLString:(NSString *)timeString
{
    self.dailyTimeLimits.netStartHour = [formatter dateFromString:timeString];
    self.dailyTimeLimits.hasNetLimits = YES;
}



- (void)setNetEndHourFromXMLString:(NSString *)timeString
{
    self.dailyTimeLimits.netEndHour = [formatter dateFromString:timeString];
    self.dailyTimeLimits.hasNetLimits = YES;
}


- (void)addWeekdayTimeLimit:(BOINCDailyTimeLimits *)dayPref
{
    if (!dayPref)
        return;
    
    NSString *daykey = [weekdayKeys objectAtIndex:dayPref.weekdayIndex];
    [weekdayTimeLimits setObject:dayPref forKey:daykey];
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
    
    [parseDescription addStringSelector:@selector(setSourceProjectURL:)              forElement:@"source_project"];
    [parseDescription addDoubleSelector:@selector(setModTime:)                       forElement:@"mod_time"];
    [parseDescription addBoolSelector:  @selector(setShouldRunOnBatteries:)          forElement:@"run_on_batteries"];
    [parseDescription addBoolSelector:  @selector(setShouldRunIfUserActive:)         forElement:@"run_if_user_active"];
    [parseDescription addDoubleSelector:@selector(setIdleTimeBeforeRunningMinutes:)  forElement:@"idle_time_to_run"];
    [parseDescription addDoubleSelector:@selector(setSuspendIfNoRecentInputMinutes:) forElement:@"suspend_if_no_recent_input"];
    [parseDescription addBoolSelector:  @selector(setShouldLeaveAppsInMemory:)       forElement:@"leave_apps_in_memory"];
    [parseDescription addBoolSelector:  @selector(setShouldConfirmBeforeConnecting:) forElement:@"confirm_before_connecting"];
    [parseDescription addBoolSelector:  @selector(setShouldHangupIfDialed:)          forElement:@"hangup_if_dialed"];
    [parseDescription addBoolSelector:  @selector(setShouldSkipVerifingImages:)      forElement:@"dont_verify_images"];
    [parseDescription addDoubleSelector:@selector(setWorkBufferMinimumDays:)         forElement:@"work_buf_min_days"];
    [parseDescription addDoubleSelector:@selector(setWorkBufferAdditionalDays:)      forElement:@"work_buf_additional_days"];
    [parseDescription addDoubleSelector:@selector(setMaxNumCPUsPercent:)             forElement:@"max_ncpus_pct"];
    [parseDescription addDoubleSelector:@selector(setCpuSchedulingPeriodMinutes:)    forElement:@"cpu_scheduling_period_minutes"];
    [parseDescription addDoubleSelector:@selector(setWriteToDiskIntervalSeconds:)    forElement:@"disk_interval"];
    [parseDescription addDoubleSelector:@selector(setDiskMaxUsedGB:)                 forElement:@"disk_max_used_gb"];
    [parseDescription addDoubleSelector:@selector(setDiskMaxUsedPercent:)            forElement:@"disk_max_used_pct"];
    [parseDescription addDoubleSelector:@selector(setDiskMinimumFreeGB:)             forElement:@"disk_min_free_gb"];
    [parseDescription addDoubleSelector:@selector(setVmMaxUsedFraction:)             forElement:@"vm_max_used_pct"];
    [parseDescription addDoubleSelector:@selector(setRamMaxUsedWhileBusyPercent:)    forElement:@"ram_max_used_busy_pct"];
    [parseDescription addDoubleSelector:@selector(setRamMaxUsedWhileIdlePercent:)    forElement:@"ram_max_used_idle_pct"];
    [parseDescription addDoubleSelector:@selector(setMaxBytesPerSecondUploadRate:)   forElement:@"max_bytes_sec_up"];
    [parseDescription addDoubleSelector:@selector(setMaxBytesPerSecondDownloadRate:) forElement:@"max_bytes_sec_down"];
    
    [parseDescription addDoubleSelector:@selector(setCpuTimeUsageLimitPercent:)      forElement:@"cpu_usage_limit"];
    [parseDescription addStringSelector:@selector(setCpuStartHourFromXMLString:)     forElement:@"start_hour"];
    [parseDescription addStringSelector:@selector(setCpuEndHourFromXMLString:)       forElement:@"end_hour"];
    [parseDescription addStringSelector:@selector(setNetStartHourFromXMLString:)     forElement:@"net_start_hour"];
    [parseDescription addStringSelector:@selector(setNetEndHourFromXMLString:)       forElement:@"net_end_hour"];
    
    [parseDescription addObjectSelector:@selector(addWeekdayTimeLimit:) ofClass:[BOINCDailyTimeLimits class] forElement:@"day_prefs"];
    
    return parseDescription;
}



///////////////////////////////////////////////////////////
#pragma mark -
#pragma mark XML Representation

- (NSString *)xmlRepresentation
{
    NSMutableString *xmlString = [NSMutableString string];
    
    [xmlString appendString:@"<global_preferences>\n"];
    [xmlString appendFormat:@"   <run_on_batteries>%d</run_on_batteries>\n", self.shouldRunOnBatteries ? 1 : 0];
    [xmlString appendFormat:@"   <run_if_user_active>%d</run_if_user_active>\n", self.shouldRunIfUserActive ? 1 : 0];
    if (!self.shouldRunIfUserActive)
        [xmlString appendFormat:@"   <idle_time_to_run>%f</idle_time_to_run>\n", self.idleTimeBeforeRunningMinutes];
    [xmlString appendString:[dailyTimeLimits xmlRepresentation]];
    [xmlString appendFormat:@"   <leave_apps_in_memory>%d</leave_apps_in_memory>\n", self.shouldLeaveAppsInMemory ? 1 : 0];
    [xmlString appendFormat:@"   <confirm_before_connecting>%d</confirm_before_connecting>\n", self.shouldConfirmBeforeConnecting ? 1 : 0];
    [xmlString appendFormat:@"   <hangup_if_dialed>%d</hangup_if_dialed>\n", self.shouldHangupIfDialed ? 1 : 0];
    [xmlString appendFormat:@"   <dont_verify_images>%d</dont_verify_images>\n", self.shouldSkipVerifingImages ? 1 : 0];
    [xmlString appendFormat:@"   <work_buf_min_days>%f</work_buf_min_days>\n", self.workBufferMinimumDays];
    [xmlString appendFormat:@"   <work_buf_additional_days>%f</work_buf_additional_days>\n", self.workBufferAdditionalDays];
    [xmlString appendFormat:@"   <max_ncpus_pct>%f</max_ncpus_pct>\n", self.maxNumCPUsPercent];
    [xmlString appendFormat:@"   <cpu_scheduling_period_minutes>%f</cpu_scheduling_period_minutes>\n", self.cpuSchedulingPeriodMinutes];
    [xmlString appendFormat:@"   <disk_interval>%f</disk_interval>\n", self.writeToDiskIntervalSeconds];
    [xmlString appendFormat:@"   <disk_max_used_gb>%f</disk_max_used_gb>\n", self.diskMaxUsedGB];
    [xmlString appendFormat:@"   <disk_max_used_pct>%f</disk_max_used_pct>\n", self.diskMaxUsedPercent];
    [xmlString appendFormat:@"   <disk_min_free_gb>%f</disk_min_free_gb>\n", self.diskMinimumFreeGB];
    [xmlString appendFormat:@"   <vm_max_used_pct>%f</vm_max_used_pct>\n", self.vmMaxUsedFraction];
    [xmlString appendFormat:@"   <ram_max_used_busy_pct>%f</ram_max_used_busy_pct>\n", self.ramMaxUsedWhileBusyPercent];
    [xmlString appendFormat:@"   <ram_max_used_idle_pct>%f</ram_max_used_idle_pct>\n", self.ramMaxUsedWhileIdlePercent];
    [xmlString appendFormat:@"   <max_bytes_sec_up>%f</max_bytes_sec_up>\n", self.maxBytesPerSecondUploadRate];
    [xmlString appendFormat:@"   <max_bytes_sec_down>%f</max_bytes_sec_down>\n", self.maxBytesPerSecondDownloadRate];
    [xmlString appendFormat:@"   <cpu_usage_limit>%f</cpu_usage_limit>\n", self.cpuTimeUsageLimitPercent];
    for (BOINCDailyTimeLimits *dayPref in [self.weekdayTimeLimits allValues])
        [xmlString appendString:[dayPref xmlRepresentation]];
    [xmlString appendString:@"</global_preferences>\n"];
    
    return xmlString;
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
    
    if (self.sourceProjectURL)
        [theDescription appendFormat:@"%@    sourceProjectURL              = %@\n", indentString, self.sourceProjectURL];
    if (self.modTime > 0)
        [theDescription appendFormat:@"%@    modTime                       = %f\n", indentString, self.modTime];
    [theDescription appendFormat:@"%@    shouldRunOnBatteries          = %@\n", indentString, self.shouldRunOnBatteries ? @"YES" : @"NO"];
    [theDescription appendFormat:@"%@    shouldRunIfUserActive         = %@\n", indentString, self.shouldRunIfUserActive ? @"YES" : @"NO"];
    [theDescription appendFormat:@"%@    cpuStartHour                  = %@\n", indentString, [formatter stringFromDate:self.dailyTimeLimits.cpuStartHour]];
    [theDescription appendFormat:@"%@    cpuEndHour                    = %@\n", indentString, [formatter stringFromDate:self.dailyTimeLimits.cpuEndHour]];
    [theDescription appendFormat:@"%@    netStartHour                  = %@\n", indentString, [formatter stringFromDate:self.dailyTimeLimits.netStartHour]];
    [theDescription appendFormat:@"%@    netEndHour                    = %@\n", indentString, [formatter stringFromDate:self.dailyTimeLimits.netEndHour]];
    [theDescription appendFormat:@"%@    idleTimeBeforeRunningMinutes  = %f\n", indentString, indentString, self.idleTimeBeforeRunningMinutes];
    [theDescription appendFormat:@"%@    suspendIfNoRecentInputMinutes = %f\n", indentString, self.suspendIfNoRecentInputMinutes];
    [theDescription appendFormat:@"%@    shouldLeaveAppsInMemory       = %@\n", indentString, self.shouldLeaveAppsInMemory ? @"YES" : @"NO"];
    [theDescription appendFormat:@"%@    shouldConfirmBeforeConnecting = %@\n", indentString, self.shouldConfirmBeforeConnecting ? @"YES" : @"NO"];
    [theDescription appendFormat:@"%@    shouldHangupIfDialed          = %@\n", indentString, self.shouldHangupIfDialed ? @"YES" : @"NO"];
    [theDescription appendFormat:@"%@    shouldSkipVerifingImages      = %@\n", indentString, self.shouldSkipVerifingImages ? @"YES" : @"NO"];
    [theDescription appendFormat:@"%@    workBufferMinimumDays         = %f\n", indentString, self.workBufferMinimumDays];
    [theDescription appendFormat:@"%@    workBufferAdditionalDays      = %f\n", indentString, self.workBufferAdditionalDays];
    [theDescription appendFormat:@"%@    maxNumCPUsPercent             = %f\n", indentString, self.maxNumCPUsPercent];
    [theDescription appendFormat:@"%@    cpuSchedulingPeriodMinutes    = %f\n", indentString, self.cpuSchedulingPeriodMinutes];
    [theDescription appendFormat:@"%@    writeToDiskIntervalSeconds    = %f\n", indentString, self.writeToDiskIntervalSeconds];
    [theDescription appendFormat:@"%@    diskMaxUsedGB                 = %f\n", indentString, self.diskMaxUsedGB];
    [theDescription appendFormat:@"%@    diskMaxUsedPercent            = %f\n", indentString, self.diskMaxUsedPercent];
    [theDescription appendFormat:@"%@    diskMinimumFreeGB             = %f\n", indentString, self.diskMinimumFreeGB];
    [theDescription appendFormat:@"%@    vmMaxUsedFraction             = %f\n", indentString, self.vmMaxUsedFraction];
    [theDescription appendFormat:@"%@    ramMaxUsedWhileBusyPercent    = %f\n", indentString, self.ramMaxUsedWhileBusyPercent];
    [theDescription appendFormat:@"%@    ramMaxUsedWhileIdlePercent    = %f\n", indentString, self.ramMaxUsedWhileIdlePercent];
    [theDescription appendFormat:@"%@    maxBytesPerSecondUploadRate   = %f\n", indentString, self.maxBytesPerSecondUploadRate];
    [theDescription appendFormat:@"%@    maxBytesPerSecondDownloadRate = %f\n", indentString, self.maxBytesPerSecondDownloadRate];
    [theDescription appendFormat:@"%@    cpuTimeUsageLimitPercent      = %f\n", indentString, self.cpuTimeUsageLimitPercent];
    
    for (BOINCDailyTimeLimits *dayPref in [self.weekdayTimeLimits allValues])
        [theDescription appendString:[dayPref debugDescriptionWithIndent:indent + 1]];
    
    return theDescription;
}

@end
