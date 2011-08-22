//
//  BOINCPrefsController.m
//  BOINCMenubar
//
//  Created by BrotherBard on 4/13/08.
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

#import "BOINCPrefsController.h"
#import "BOINCActiveClientManager.h"

#import "BOINCClientManager.h"
#import "BOINCHostSelectionController.h"



@interface BOINCPrefsController (BMBPrivate)

- (void)updateMainContentView;
- (NSAttributedString *)stringForSourceProjectURL;
- (NSString *)numberStringForPref:(double)num;
- (void)updateBOINCPreferenceStrings;

@end



#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BOINCPrefsController

@synthesize clientManager;
@synthesize activePreferences;
@synthesize editedPreferences;
@synthesize prefStateIndex;
@synthesize sourceProjectString;
@synthesize preferenceForHost;

@synthesize mainPreferencesTabView;
@synthesize editPreferencesTabView;
@synthesize mainPreferencesSubview;
@synthesize noHostConnectedSubview;
@synthesize editBOINCPreferenceSheet;
@synthesize mainContentView;
@synthesize hostSelectionView;
@synthesize hostSelectionController;

@synthesize runIfUserActiveField;
@synthesize suspendIfNoRecentInputField;
@synthesize runOnBatteriesField;

@synthesize cpuSchedulingPeriodField;
@synthesize maxCPUsField;
@synthesize cpuTimeUsageLimitField;

@synthesize maxBytesPerSecondDownloadField;
@synthesize maxBytesPerSecondUploadField;
@synthesize workBufferMinimumField;
@synthesize workBufferAdditionalField;
@synthesize skipVerifingImagesField;

@synthesize confirmBeforeConnectingField;
@synthesize hangupIfDialedField;

@synthesize diskMaxUsedField;
@synthesize diskMinimumFreeField;
@synthesize diskMaxUsedPercentField;
@synthesize writeToDiskIntervalField;
@synthesize vmMaxUsedField;

@synthesize ramMaxUsedWhileBusyField;
@synthesize ramMaxUsedWhileIdleField;
@synthesize leaveAppsInMemoryField;

@synthesize dailyCPULimitField;
@synthesize mondayCPULimitField;
@synthesize tuesdayCPULimitField;
@synthesize wednesdayCPULimitField;
@synthesize thursdayCPULimitField;
@synthesize fridayCPULimitField;
@synthesize saturdayCPULimitField;
@synthesize sundayCPULimitField;

@synthesize dailyNETLimitField;
@synthesize mondayNETLimitField;
@synthesize tuesdayNETLimitField;
@synthesize wednesdayNETLimitField;
@synthesize thursdayNETLimitField;
@synthesize fridayNETLimitField;
@synthesize saturdayNETLimitField;
@synthesize sundayNETLimitField;

@synthesize isLocalOverride;
@synthesize overrideButton;
@synthesize editButton;



#define kBOINCTabViewIndexKey @"BOINC Preference TabView Index"

+ (void)initialize
{
    if (self != [BOINCPrefsController class])
        return;
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObject:@"1" forKey:kBOINCTabViewIndexKey]];
}


- (id)initWithClientManager:(id)manager
{
    self = [super initWithNibName:@"BOINCPreferences" bundle:nil];
    if (!self) return nil;
    
    clientManager = manager;
    
    prefNumberFormatter = [[NSNumberFormatter alloc] init];
    [prefNumberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [prefNumberFormatter setMaximumFractionDigits:4];
    [prefNumberFormatter setMinimumFractionDigits:0]; 
    [prefNumberFormatter setRoundingMode:NSNumberFormatterRoundHalfEven];
    
    return self;
}


- (void)dealloc
{
    clientManager = nil;
    
    [prefNumberFormatter            release];
    
    [activePreferences              release];
    [editedPreferences              release];
    [sourceProjectString            release];
    [preferenceForHost              release];
    
    [mainPreferencesTabView         release];
    [editPreferencesTabView         release];
    [mainPreferencesSubview         release];
    [noHostConnectedSubview         release];
    [editBOINCPreferenceSheet       release];
    [mainContentView                release];
    [hostSelectionView              release];
    [hostSelectionController        release];
    
    [runIfUserActiveField           release];
    [suspendIfNoRecentInputField    release];
    [runOnBatteriesField            release];
    
    [cpuSchedulingPeriodField       release];
    [maxCPUsField                   release];
    [cpuTimeUsageLimitField         release];
    
    [maxBytesPerSecondDownloadField release];
    [maxBytesPerSecondUploadField   release];
    [workBufferMinimumField         release];
    [workBufferAdditionalField      release];
    [skipVerifingImagesField        release];
    
    [confirmBeforeConnectingField   release];
    [hangupIfDialedField            release];
    
    [diskMaxUsedField               release];
    [diskMinimumFreeField           release];
    [diskMaxUsedPercentField        release];
    [writeToDiskIntervalField       release];
    [vmMaxUsedField                 release];
    
    [ramMaxUsedWhileBusyField       release];
    [ramMaxUsedWhileIdleField       release];
    [leaveAppsInMemoryField         release];
    
    [dailyCPULimitField             release];
    [mondayCPULimitField            release];
    [tuesdayCPULimitField           release];
    [wednesdayCPULimitField         release];
    [thursdayCPULimitField          release];
    [fridayCPULimitField            release];
    [saturdayCPULimitField          release];
    [sundayCPULimitField            release];
    
    [dailyNETLimitField             release];
    [mondayNETLimitField            release];
    [tuesdayNETLimitField           release];
    [wednesdayNETLimitField         release];
    [thursdayNETLimitField          release];
    [fridayNETLimitField            release];
    [saturdayNETLimitField          release];
    [sundayNETLimitField            release];
    
    [overrideButton                 release];
    [editButton                     release];
    
    [super dealloc];
}


- (void)awakeFromNib
{
    hostSelectionController = [[BOINCHostSelectionController hostSelectionControllerWithClientManager:clientManager] retain];
    [hostSelectionView addSubview:[hostSelectionController view]];
}



#pragma mark BMB_ViewController_Category methods

static const void *activeClientContext;
static const void *preferencesContext;

- (void)BMB_contentViewWillLoad
{
    [self.clientManager addObserver:self forKeyPath:@"activeClient.isConnected" options:0 context:&activeClientContext];
    [self.clientManager addObserver:self forKeyPath:@"activeClient.lastGlobalPreferencesUpdate" options:0 context:&preferencesContext];
    
    [self.clientManager.activeClient requestGlobalPreferencesUpdate];
}


- (void)BMB_contentViewDidUnload
{
    [self.clientManager removeObserver:self forKeyPath:@"activeClient.isConnected"];
    [self.clientManager removeObserver:self forKeyPath:@"activeClient.lastGlobalPreferencesUpdate"];
    [[[self view] window] makeFirstResponder:nil];
}



#pragma mark KVO methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == &activeClientContext) {
        if (self.clientManager.activeClient.isConnected) {
            // the active client changed so update the preference information
            [self.clientManager.activeClient requestGlobalPreferencesUpdate];
        } else {
            [self updateMainContentView];
        }
        return;
    }
    
    if (context == &preferencesContext) {
        // the preference info has updated so update the view
        self.activePreferences = self.clientManager.activeClient.workingPreferences;
        self.prefStateIndex = self.clientManager.activeClient.prefStateIndex;
        [self updateMainContentView];
        return;
    }
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}



#pragma mark NSTabView delegate methods

// keep the two tab views in sync
- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
    [[NSUserDefaults standardUserDefaults] setObject:[tabViewItem identifier] forKey:kBOINCTabViewIndexKey];
    if (tabView == mainPreferencesTabView)
        [editPreferencesTabView selectTabViewItemWithIdentifier:[tabViewItem identifier]];
    else
        [mainPreferencesTabView selectTabViewItemWithIdentifier:[tabViewItem identifier]];
}



#pragma mark NSControl delegate methods
/*
 for the number based text fields:
 don't allow invalid values
 make sure the numbers are in range
 for non numbers or empty string, reset the string to the current value of the bound model object
 
 change the string to match correct values and return YES
 returning NO will open an ugly 'Format Error' sheet on the window (so don't do it!!!)
 
 BMBNumbersOnlyFormatter stops invalid characters
 */
- (BOOL)control:(NSControl *)control didFailToFormatString:(NSString *)string errorDescription:(NSString *)error
{   
    if ([[control formatter] isKindOfClass:[NSNumberFormatter class]]) 
    { 
        NSScanner *numberScanner = [NSScanner scannerWithString:string];
        double value = 0.0;
        
        if ([numberScanner scanDouble:&value]) {
            double minimum = [[[control formatter] minimum] doubleValue];
            if (value < minimum) {
                [control setDoubleValue:minimum];
                NSBeep();
                return YES;
            }
            double maximum = [[[control formatter] maximum] doubleValue];
            if (value > maximum) {
                [control setDoubleValue:maximum];
                NSBeep();
                return YES;
            }
        }
        else {
            NSString *keyPath = [[control infoForBinding:@"value"] objectForKey:NSObservedKeyPathKey];
            [control setDoubleValue:[[self valueForKeyPath:keyPath] doubleValue]];
            NSBeep();
            return YES;
        }
    }
    
    return YES;
}


#pragma mark NSApp didEndSheet: modalDelegate 

- (void)didEndSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    [sheet orderOut:self];
}



#pragma mark IB Action methods

- (IBAction)toggleWebPreferences:(id)sender
{
    if (self.prefStateIndex == kBOINCPrefsProjectFile)
        [self.clientManager.activeClient setGlobalPrefsOverride:[self.activePreferences xmlRepresentation]];
    else
        [self.clientManager.activeClient clearGlobalPrefsOverrideFile];
}


- (IBAction)editPreferences:(id)sender
{
    self.editedPreferences = [self.activePreferences copy];
    
    [NSApp beginSheet:editBOINCPreferenceSheet
       modalForWindow:[[self view] window]
        modalDelegate:self
       didEndSelector:@selector(didEndSheet:returnCode:contextInfo:)
          contextInfo:nil];
}


- (IBAction)saveEditedPreferences:(id)sender
{
    [[sender window] makeFirstResponder:nil];
    [self.clientManager.activeClient setGlobalPrefsOverride:[self.editedPreferences xmlRepresentation]];
    
    [NSApp endSheet:[sender window]];
    self.editedPreferences = nil;
}


- (IBAction)cancelEditedPreferences:(id)sender
{
    [[sender window] makeFirstResponder:nil];
    [NSApp endSheet:[sender window]];
    self.editedPreferences = nil;
}


- (IBAction)clearChangesInEditedPreferences:(id)sender
{
    [[sender window] makeFirstResponder:nil];
    self.editedPreferences = [self.activePreferences copy];
}



#pragma mark -
#pragma mark Private methods

- (void)switchContentToView:(NSView *)newView
{
    
    while ([[mainContentView subviews] count] > 0)
        [[[mainContentView subviews] objectAtIndex:0] removeFromSuperviewWithoutNeedingDisplay];
    
    [mainContentView addSubview:newView];
    [[mainContentView window] recalculateKeyViewLoop];
}


- (void)updateMainContentView
{
    if (self.clientManager.activeClient.isConnected) {
        self.preferenceForHost = [NSString stringWithFormat:@"BOINC Preferences for Host: %@", self.clientManager.activeClient.fullName];
        id identifier = [[NSUserDefaults standardUserDefaults] stringForKey:kBOINCTabViewIndexKey];
        [editPreferencesTabView selectTabViewItemWithIdentifier:identifier];
        [mainPreferencesTabView selectTabViewItemWithIdentifier:identifier];
        if (mainContentView != mainPreferencesSubview)
            [self switchContentToView:mainPreferencesSubview];
        if (self.prefStateIndex == kBOINCPrefsProjectFile) {
            self.isLocalOverride = NO;
            [overrideButton setEnabled:YES];
            [overrideButton setTitle:@"Override Web Preferences"];
            [editButton setEnabled:NO];
        } else {
            self.isLocalOverride = YES;
            [overrideButton setEnabled:YES];
            [overrideButton setTitle:@"Restore Web Preferences"];
            [editButton setEnabled:YES];
        }
        [self updateBOINCPreferenceStrings];
    } else {
        // show a "not connected" or "connecting" view
        if (mainContentView != noHostConnectedSubview)
            [self switchContentToView:noHostConnectedSubview];
        
        if (self.clientManager.activeClient.connectionStatus < kStatusIsConnecting) {
            self.preferenceForHost = @"BOINC Preferences for Host: No Host Connected";
        } else {
            self.preferenceForHost = [NSString stringWithFormat:@"BOINC Preferences for Host: %@", self.clientManager.activeClient.fullName];
        }
        
        // get rid of the other UI stuph
        [overrideButton setEnabled:NO];
        [overrideButton setTitle:@"Override Web Preferences"];
        [editButton setEnabled:NO];
    }
}


- (NSAttributedString *)stringForSourceProjectURL
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSDictionary *attrsDictionary = [[[NSDictionary alloc] initWithObjectsAndKeys:
                                     [NSFont labelFontOfSize:[NSFont labelFontSize]], NSFontAttributeName,
                                     nil] autorelease];
    
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init]  autorelease];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    
    NSMutableAttributedString *outputString = nil;
    
    if (self.prefStateIndex == kBOINCPrefsProjectFile) {
        NSString *labelString = [NSString stringWithFormat:@"%@ %@ %@  ", NSLocalizedString(@"Web Preferences", @"Web Preferences label"), NSLocalizedString(@"Last Updated: ", @"Last Updated label"), [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.activePreferences.modTime]]];
        
        outputString = [[NSMutableAttributedString alloc] initWithString:labelString attributes:attrsDictionary];
        
        if (self.activePreferences.sourceProjectURL) {
            // newer clients (around 6.3.x???) reports the project that sent the latest preferences
            NSMutableAttributedString *htmlString = [[[NSMutableAttributedString alloc] initWithHTML:[[NSString stringWithFormat:@"<a href=\"%@\">%@</a>", self.activePreferences.sourceProjectURL, self.activePreferences.sourceProjectURL] dataUsingEncoding:NSUTF8StringEncoding] documentAttributes:nil] autorelease];
            [htmlString addAttributes:attrsDictionary range:NSMakeRange(0, [htmlString length])];
            
            [outputString appendAttributedString:htmlString];
        }
    } else {
        outputString = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"Local Preferences", @"Local Preferences label") attributes:attrsDictionary];
    }
    
    [pool release];
    return [outputString autorelease];;
}


- (NSString *)numberStringForPref:(double)num 
{
    return [prefNumberFormatter stringFromNumber:[NSNumber numberWithDouble:num]];
}


- (NSString *)timeSpanStringFor:(BOINCDailyTimeLimits *)timeLimits useCPULimits:(BOOL)useCPULimits
{
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateStyle:NSDateFormatterNoStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    NSDate *startTime = useCPULimits ? timeLimits.cpuStartHour : timeLimits.netStartHour;
    NSDate *endTime = useCPULimits ? timeLimits.cpuEndHour : timeLimits.netEndHour;
    
    return [NSString stringWithFormat:@"%@ and %@", [formatter stringFromDate:startTime], [formatter stringFromDate:endTime]];
}


- (NSString *)weekdayTimeLimitStringFor:(BOINCDailyTimeLimits *)timeLimits useCPULimits:(BOOL)useCPULimits
{
    BOOL hasLimit = useCPULimits ? timeLimits.hasCPULimits : timeLimits.hasNetLimits;
    if (!hasLimit)
        return @"No restrictions";
    
    return [NSString stringWithFormat:@"between %@", [self timeSpanStringFor:[self.activePreferences.weekdayTimeLimits valueForKey:@"monday"] useCPULimits:YES ]];
}


/*
 Project preferences can't be changed from a BOINC manager, only on a project's web page.
 To let the user know that the preferences are not currently editable show static strings that describe the state of 
 the current web preferences.
 */
- (void)updateBOINCPreferenceStrings
{
    // Computing allowed
    if (self.activePreferences.shouldRunIfUserActive)
        [runIfUserActiveField setStringValue:@"While computer is in use"];
    else
        [runIfUserActiveField setStringValue:[NSString stringWithFormat:@"Only after computer has been idle for %@ minutes", [self numberStringForPref:self.activePreferences.idleTimeBeforeRunningMinutes]]];
    
    if (self.activePreferences.suspendIfNoRecentInputMinutes > 0.0f)
        [suspendIfNoRecentInputField setStringValue:[NSString stringWithFormat:@"Only if keyboard/mouse activity in last %@ minutes", [self numberStringForPref:self.activePreferences.suspendIfNoRecentInputMinutes]]];
    else
        [suspendIfNoRecentInputField setStringValue:@"Not suspended based on lack of keyboard/mouse activity"];
    
    [runOnBatteriesField setStringValue:[NSString stringWithFormat:@"While computer is on batteries: %@", self.activePreferences.shouldRunOnBatteries ? @"YES" : @"NO"]];
    
    // daily cpu time limits
    if (self.activePreferences.dailyTimeLimits.hasCPULimits && !([self.activePreferences.dailyTimeLimits.cpuStartHour isEqualTo:self.activePreferences.dailyTimeLimits.cpuEndHour]))
        [dailyCPULimitField setStringValue:[NSString stringWithFormat:@"Every day: between %@", [self timeSpanStringFor:self.activePreferences.dailyTimeLimits useCPULimits:YES ]]];
    else
        [dailyCPULimitField setStringValue:@"Every day: No restrictions"];
    
    // Weekdays:
    [mondayCPULimitField setStringValue:[self weekdayTimeLimitStringFor:[self.activePreferences.weekdayTimeLimits objectForKey:kMondayKey] useCPULimits:YES]];
    [tuesdayCPULimitField setStringValue:[self weekdayTimeLimitStringFor:[self.activePreferences.weekdayTimeLimits objectForKey:kTuesdayKey] useCPULimits:YES]];
    [wednesdayCPULimitField setStringValue:[self weekdayTimeLimitStringFor:[self.activePreferences.weekdayTimeLimits objectForKey:kWednesdayKey] useCPULimits:YES]];
    [thursdayCPULimitField setStringValue:[self weekdayTimeLimitStringFor:[self.activePreferences.weekdayTimeLimits objectForKey:kThursdayKey] useCPULimits:YES]];
    [fridayCPULimitField setStringValue:[self weekdayTimeLimitStringFor:[self.activePreferences.weekdayTimeLimits objectForKey:kFridayKey] useCPULimits:YES]];
    [saturdayCPULimitField setStringValue:[self weekdayTimeLimitStringFor:[self.activePreferences.weekdayTimeLimits objectForKey:kSaturdayKey] useCPULimits:YES]];
    [sundayCPULimitField setStringValue:[self weekdayTimeLimitStringFor:[self.activePreferences.weekdayTimeLimits objectForKey:kSundayKey] useCPULimits:YES]];
    
    // Processor options
    [cpuSchedulingPeriodField setStringValue:[NSString stringWithFormat:@"Switch between applications every %@ minutes", [self numberStringForPref:self.activePreferences.cpuSchedulingPeriodMinutes]]];
    [maxCPUsField setStringValue:[NSString stringWithFormat:@"On multiprocessor systems, use at most %@%% of processors", [self numberStringForPref:self.activePreferences.maxNumCPUsPercent]]];
    [cpuTimeUsageLimitField setStringValue:[NSString stringWithFormat:@"Use at most %@%% CPU time",  [self numberStringForPref:self.activePreferences.cpuTimeUsageLimitPercent]]];
    
    // General Network Options
    if (self.activePreferences.maxBytesPerSecondDownloadRate > 0.0f)
        [maxBytesPerSecondDownloadField setStringValue:[NSString stringWithFormat:@"Maximum download rate: %@ Kbytes/sec", [self numberStringForPref:self.activePreferences.maxBytesPerSecondDownloadRate]]];
    else
        [maxBytesPerSecondDownloadField setStringValue:@"Maximum download rate: no limit"];
    
    if (self.activePreferences.maxBytesPerSecondUploadRate > 0.0f)
        [maxBytesPerSecondUploadField setStringValue:[NSString stringWithFormat:@"Maximum upload rate: %@ Kbytes/sec", [self numberStringForPref:self.activePreferences.maxBytesPerSecondUploadRate]]];
    else
        [maxBytesPerSecondUploadField setStringValue:@"Maximum upload rate: no limit"];
    
    if (self.activePreferences.workBufferMinimumDays > 0.0f)
        [workBufferMinimumField setStringValue:[NSString stringWithFormat:@"Connect about every %@ days", [self numberStringForPref:self.activePreferences.workBufferMinimumDays]]];
    else
        [workBufferMinimumField setStringValue:@"Connection is always on."];
    
    [workBufferAdditionalField setStringValue:[NSString stringWithFormat:@"Additional work buffer of %@ days", [self numberStringForPref:self.activePreferences.workBufferAdditionalDays]]];
    
    [skipVerifingImagesField setStringValue:[NSString stringWithFormat:@"Skip image file verification: %@", self.activePreferences.shouldSkipVerifingImages ? @"YES" : @"NO"]];
    
    // Connection options
    [confirmBeforeConnectingField setStringValue:[NSString stringWithFormat:@"Confirm before connecting to internet: %@", self.activePreferences.shouldConfirmBeforeConnecting ? @"YES" : @"NO"]];
    
    [hangupIfDialedField setStringValue:[NSString stringWithFormat:@"Disconnect when done: %@", self.activePreferences.shouldHangupIfDialed ? @"YES" : @"NO"]];
    
    // Network Usage
    if (self.activePreferences.dailyTimeLimits.hasNetLimits && !([self.activePreferences.dailyTimeLimits.netStartHour isEqualTo:self.activePreferences.dailyTimeLimits.netEndHour]))
        [dailyNETLimitField setStringValue:[NSString stringWithFormat:@"Every day: between %@", [self timeSpanStringFor:self.activePreferences.dailyTimeLimits useCPULimits:NO ]]];
    else
        [dailyNETLimitField setStringValue:@"Every day: No restrictions"];
    
    // Weekdays:
    [mondayNETLimitField setStringValue:[self weekdayTimeLimitStringFor:[self.activePreferences.weekdayTimeLimits objectForKey:kMondayKey] useCPULimits:NO]];
    [tuesdayNETLimitField setStringValue:[self weekdayTimeLimitStringFor:[self.activePreferences.weekdayTimeLimits objectForKey:kTuesdayKey] useCPULimits:NO]];
    [wednesdayNETLimitField setStringValue:[self weekdayTimeLimitStringFor:[self.activePreferences.weekdayTimeLimits objectForKey:kWednesdayKey] useCPULimits:NO]];
    [thursdayNETLimitField setStringValue:[self weekdayTimeLimitStringFor:[self.activePreferences.weekdayTimeLimits objectForKey:kThursdayKey] useCPULimits:NO]];
    [fridayNETLimitField setStringValue:[self weekdayTimeLimitStringFor:[self.activePreferences.weekdayTimeLimits objectForKey:kFridayKey] useCPULimits:NO]];
    [saturdayNETLimitField setStringValue:[self weekdayTimeLimitStringFor:[self.activePreferences.weekdayTimeLimits objectForKey:kSaturdayKey] useCPULimits:NO]];
    [sundayNETLimitField setStringValue:[self weekdayTimeLimitStringFor:[self.activePreferences.weekdayTimeLimits objectForKey:kSundayKey] useCPULimits:NO]];
    
    // Disk Usage
    [diskMaxUsedField setStringValue:[NSString stringWithFormat:@"Use at most %@ Gigabytes disk space", [self numberStringForPref:self.activePreferences.diskMaxUsedGB]]];
    [diskMinimumFreeField setStringValue:[NSString stringWithFormat:@"Leave at least %@ Gigabytes disk space free", [self numberStringForPref:self.activePreferences.diskMinimumFreeGB]]];
    [diskMaxUsedPercentField setStringValue:[NSString stringWithFormat:@"Use at most %@%% of total disk space", [self numberStringForPref:self.activePreferences.diskMaxUsedPercent]]];
    [writeToDiskIntervalField setStringValue:[NSString stringWithFormat:@"Write to disk at most every %@ seconds", [self numberStringForPref:self.activePreferences.writeToDiskIntervalSeconds]]];
    [vmMaxUsedField setStringValue:[NSString stringWithFormat:@"Use at most %@%% of page file (swap space)", [self numberStringForPref:self.activePreferences.vmMaxUsedFraction]]];
    
    // Memory Usage
    [ramMaxUsedWhileBusyField setStringValue:[NSString stringWithFormat:@"Use at most %@%% of memory when computer is in use", [self numberStringForPref:self.activePreferences.ramMaxUsedWhileBusyPercent]]];
    [ramMaxUsedWhileIdleField setStringValue:[NSString stringWithFormat:@"Use at most %@%% of memory when computer is idle", [self numberStringForPref:self.activePreferences.ramMaxUsedWhileIdlePercent]]];
    
    [leaveAppsInMemoryField setStringValue:[NSString stringWithFormat:@"Leave applications in memory while suspended: %@", self.activePreferences.shouldLeaveAppsInMemory ? @"YES" : @"NO"]];
    
    // Source Project
    self.sourceProjectString = [self stringForSourceProjectURL];
}


@end
