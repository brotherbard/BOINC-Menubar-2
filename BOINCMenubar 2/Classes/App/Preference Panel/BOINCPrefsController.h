//
//  BOINCPrefsController.h
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

#import <Cocoa/Cocoa.h>


@class BOINCActiveClientManager;
@class BOINCGlobalPreferences;
@class BOINCDailyTimeLimits;
@class BOINCHostSelectionController;



@interface BOINCPrefsController : NSViewController
{
    NSTabView                    *mainPreferencesTabView;
    NSTabView                    *editPreferencesTabView;
    NSView                       *mainPreferencesSubview;
    NSView                       *noHostConnectedSubview;
    NSWindow                     *editBOINCPreferenceSheet;
    NSView                       *mainContentView;
    NSView                       *hostSelectionView;
    BOINCHostSelectionController *hostSelectionController;
    
    BOINCActiveClientManager     *clientManager;
    BOINCGlobalPreferences       *activePreferences;
    BOINCGlobalPreferences       *editedPreferences;
    NSInteger                     prefStateIndex;
    
    NSNumberFormatter            *prefNumberFormatter;
    
    NSTextField                  *runIfUserActiveField;
    NSTextField                  *suspendIfNoRecentInputField;
    NSTextField                  *runOnBatteriesField;
    
    NSTextField                  *cpuSchedulingPeriodField;
    NSTextField                  *maxCPUsField;
    NSTextField                  *cpuTimeUsageLimitField;
    
    NSTextField                  *maxBytesPerSecondDownloadField;
    NSTextField                  *maxBytesPerSecondUploadField;
    NSTextField                  *workBufferMinimumField;
    NSTextField                  *workBufferAdditionalField;
    NSTextField                  *skipVerifingImagesField;
    
    NSTextField                  *confirmBeforeConnectingField;
    NSTextField                  *hangupIfDialedField;
    
    NSTextField                  *diskMaxUsedField;
    NSTextField                  *diskMinimumFreeField;
    NSTextField                  *diskMaxUsedPercentField;
    NSTextField                  *writeToDiskIntervalField;
    NSTextField                  *vmMaxUsedField;
    
    NSTextField                  *ramMaxUsedWhileBusyField;
    NSTextField                  *ramMaxUsedWhileIdleField;
    NSTextField                  *leaveAppsInMemoryField;
    
    NSTextField                  *dailyCPULimitField;
    NSTextField                  *mondayCPULimitField;
    NSTextField                  *tuesdayCPULimitField;
    NSTextField                  *wednesdayCPULimitField;
    NSTextField                  *thursdayCPULimitField;
    NSTextField                  *fridayCPULimitField;
    NSTextField                  *saturdayCPULimitField;
    NSTextField                  *sundayCPULimitField;
    
    NSTextField                  *dailyNETLimitField;
    NSTextField                  *mondayNETLimitField;
    NSTextField                  *tuesdayNETLimitField;
    NSTextField                  *wednesdayNETLimitField;
    NSTextField                  *thursdayNETLimitField;
    NSTextField                  *fridayNETLimitField;
    NSTextField                  *saturdayNETLimitField;
    NSTextField                  *sundayNETLimitField;
	
    BOOL                          isLocalOverride;
    NSButton                     *overrideButton;
    NSButton                     *editButton;
    NSAttributedString           *sourceProjectString;
    NSString                     *preferenceForHost;
}
@property (nonatomic, retain) IBOutlet NSTabView           *mainPreferencesTabView;
@property (nonatomic, retain) IBOutlet NSTabView           *editPreferencesTabView;
@property (nonatomic, retain) IBOutlet NSView              *mainPreferencesSubview;
@property (nonatomic, retain) IBOutlet NSView              *noHostConnectedSubview;
@property (nonatomic, retain) IBOutlet NSWindow            *editBOINCPreferenceSheet;
@property (nonatomic, retain) IBOutlet NSView              *mainContentView;
@property (nonatomic, retain) IBOutlet NSView              *hostSelectionView;
@property (nonatomic, retain) BOINCHostSelectionController *hostSelectionController;

@property (nonatomic, assign) BOINCActiveClientManager     *clientManager; // weak reference
@property (nonatomic, retain) BOINCGlobalPreferences       *activePreferences;
@property (nonatomic, retain) BOINCGlobalPreferences       *editedPreferences;
@property (nonatomic, assign)          NSInteger            prefStateIndex;
@property (nonatomic, copy)            NSAttributedString  *sourceProjectString;
@property (nonatomic, copy)            NSString            *preferenceForHost;

@property (nonatomic, retain) IBOutlet NSTextField         *runIfUserActiveField;
@property (nonatomic, retain) IBOutlet NSTextField         *suspendIfNoRecentInputField;
@property (nonatomic, retain) IBOutlet NSTextField         *runOnBatteriesField;

@property (nonatomic, retain) IBOutlet NSTextField         *cpuSchedulingPeriodField;
@property (nonatomic, retain) IBOutlet NSTextField         *maxCPUsField;
@property (nonatomic, retain) IBOutlet NSTextField         *cpuTimeUsageLimitField;

@property (nonatomic, retain) IBOutlet NSTextField         *maxBytesPerSecondDownloadField;
@property (nonatomic, retain) IBOutlet NSTextField         *maxBytesPerSecondUploadField;
@property (nonatomic, retain) IBOutlet NSTextField         *workBufferMinimumField;
@property (nonatomic, retain) IBOutlet NSTextField         *workBufferAdditionalField;
@property (nonatomic, retain) IBOutlet NSTextField         *skipVerifingImagesField;

@property (nonatomic, retain) IBOutlet NSTextField         *confirmBeforeConnectingField;
@property (nonatomic, retain) IBOutlet NSTextField         *hangupIfDialedField;

@property (nonatomic, retain) IBOutlet NSTextField         *diskMaxUsedField;
@property (nonatomic, retain) IBOutlet NSTextField         *diskMinimumFreeField;
@property (nonatomic, retain) IBOutlet NSTextField         *diskMaxUsedPercentField;
@property (nonatomic, retain) IBOutlet NSTextField         *writeToDiskIntervalField;
@property (nonatomic, retain) IBOutlet NSTextField         *vmMaxUsedField;

@property (nonatomic, retain) IBOutlet NSTextField         *ramMaxUsedWhileBusyField;
@property (nonatomic, retain) IBOutlet NSTextField         *ramMaxUsedWhileIdleField;
@property (nonatomic, retain) IBOutlet NSTextField         *leaveAppsInMemoryField;

@property (nonatomic, retain) IBOutlet NSTextField         *dailyCPULimitField;
@property (nonatomic, retain) IBOutlet NSTextField         *mondayCPULimitField;
@property (nonatomic, retain) IBOutlet NSTextField         *tuesdayCPULimitField;
@property (nonatomic, retain) IBOutlet NSTextField         *wednesdayCPULimitField;
@property (nonatomic, retain) IBOutlet NSTextField         *thursdayCPULimitField;
@property (nonatomic, retain) IBOutlet NSTextField         *fridayCPULimitField;
@property (nonatomic, retain) IBOutlet NSTextField         *saturdayCPULimitField;
@property (nonatomic, retain) IBOutlet NSTextField         *sundayCPULimitField;

@property (nonatomic, retain) IBOutlet NSTextField         *dailyNETLimitField;
@property (nonatomic, retain) IBOutlet NSTextField         *mondayNETLimitField;
@property (nonatomic, retain) IBOutlet NSTextField         *tuesdayNETLimitField;
@property (nonatomic, retain) IBOutlet NSTextField         *wednesdayNETLimitField;
@property (nonatomic, retain) IBOutlet NSTextField         *thursdayNETLimitField;
@property (nonatomic, retain) IBOutlet NSTextField         *fridayNETLimitField;
@property (nonatomic, retain) IBOutlet NSTextField         *saturdayNETLimitField;
@property (nonatomic, retain) IBOutlet NSTextField         *sundayNETLimitField;

@property (nonatomic, assign)          BOOL                 isLocalOverride;
@property (nonatomic, retain) IBOutlet NSButton            *overrideButton;
@property (nonatomic, retain) IBOutlet NSButton            *editButton;


- (id)initWithClientManager:(id)manager;

- (IBAction)toggleWebPreferences:(id)sender;

- (IBAction)editPreferences:(id)sender;
- (IBAction)saveEditedPreferences:(id)sender;
- (IBAction)cancelEditedPreferences:(id)sender;
- (IBAction)clearChangesInEditedPreferences:(id)sender;


@end
