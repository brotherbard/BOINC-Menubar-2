//
//  BMBAppController.m
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

#import "BMBAppController.h"
#import "BOINCActiveClientManager.h"

#import "BMBStatusMenuController.h"
#import "BMBPreferenceWindowController.h"
#import "BMBGrowlNotifier.h"

#import "BOINCClientManager.h"

#import "Sparkle/SUUpdater.h"

#import <sys/sysctl.h>
#define kFRUseABEmailAddress @"FRFeedbackReporter.addressbookEmail"



//////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BMBAppController


@synthesize aboutWindow;
@synthesize creditView;


// Set up factory defaults
+ (void)initialize
{
    if (self != [BMBAppController class])
        return;
    
    NSDictionary *defaults = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithBool:NO],  kRunBOINCClient,
                              [NSNumber numberWithBool:YES], kShowGrowlNotifications,
                              [NSNumber numberWithBool:YES], kFRUseABEmailAddress, // for FeedbackReporter
                              nil];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}


- (void)dealloc
{
    [_prefController release];
    [_boincMenu      release];
    [_clientManager  release];
    [_growlNotifier  release];
    
    [aboutWindow     release];
    [creditView      release];
    
    [super dealloc];
}



#pragma mark Application Startup 

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    NSLog(@"BOINCMenubar 2 %@", [self versionString]);
    
    // setup the Sparkle updater
    [[SUUpdater sharedUpdater] setDelegate:self];
    
    // check for a recent crash report
    [[FRFeedbackReporter sharedReporter] setDelegate:self];
    [[FRFeedbackReporter sharedReporter] reportIfCrash];
    //[[FRFeedbackReporter sharedReporter] reportFeedback]; // for testing
    
    // init the clientManager
    _clientManager = [[BOINCActiveClientManager alloc] init];
    
    // is the preference set for us to run the client?
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kRunBOINCClient])
        [_clientManager runLocalBOINCProcess];
    
    // create the status menu
    _boincMenu = [[BMBStatusMenuController alloc] initWithClientManager:_clientManager];
    
    // create the growl notifier
    _growlNotifier = [[BMBGrowlNotifier alloc] initWithClientManager:_clientManager];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification
{   
    // make sure the preference window closes so the preference view controllers get a chance to save state
    [_prefController close];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    BBError(@"");
}


- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    return [_clientManager shouldAppTerminate];
}



#pragma mark Preferences Window

- (void)openPreferencesWindowWithKey:(NSString *)prefKey
{   
    if (!_prefController) 
        _prefController = [[BMBPreferenceWindowController alloc] initWithClientManager:_clientManager];
    [_prefController openPrefWindowWithPrefKey:prefKey];
}

// opens to the Default or last open pref view
- (IBAction)openPreferencesWindow:(id)sender
{   
    [self openPreferencesWindowWithKey:nil];
}


// opens the Hosts pref view
- (IBAction)editHosts:(id)sender
{   
    [self openPreferencesWindowWithKey:kBMBHostsPrefKey];
}


// opens the Projects pref view
- (IBAction)joinNewProject:(id)sender
{
    [self openPreferencesWindowWithKey:kBOINCProjectsPrefKey];
}



#pragma mark BOINC Websites

- (IBAction)openBoincSite:(id)sender
{   
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://boinc.berkeley.edu/"]];
}


- (IBAction)openBoincMenubarSite:(id)sender
{   
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://brotherbard.com/boinc/"]];
}



#pragma mark FeedbackReporter delegate methods

- (NSDictionary *)customParametersForFeedbackReport
{
    return [NSDictionary dictionaryWithObject:@"BOINCMenubar 2" forKey:@"application"];
}


- (NSMutableDictionary *)anonymizePreferencesForFeedbackReport:(NSMutableDictionary *)preferences
{
    [preferences removeObjectForKey:@"kBMBLastAttachProjectUserName"];
    [preferences removeObjectForKey:@"kBMBLastAttachProjectEmailAddress"];
    
    return preferences;
}


- (IBAction)openFeedbackEMail:(id)sender
{   
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"mailto:nkinsinger@brotherbard.com?subject=BOINCMenubar%202%20feedback"]];
}



#pragma mark Sparkle delegate methods

// don't prompt, only use the setting in the preferences
- (BOOL)updaterShouldPromptForPermissionToCheckForUpdates:(SUUpdater *)bundle
{
    return NO;
}


- (NSArray *)feedParametersForUpdater:(SUUpdater *)updater sendingSystemProfile:(BOOL)sendingProfile
{
	NSArray *keys = [NSArray arrayWithObjects:@"key", @"displayKey", @"value", @"displayValue", nil];
	NSMutableArray *feedParameters = [NSMutableArray array];
	
    BBLog(@"sendingProfile: %@", sendingProfile ? @"YES" : @"NO");
    // only send if the profile is being sent this time
    if (sendingProfile) {
        NSString *cpuModel = nil;
        int error = 0;
        char stringValue[255];
        size_t stringLength = sizeof(stringValue);
        error = sysctlbyname("machdep.cpu.brand_string", &stringValue, &stringLength, NULL, 0);
        if ((error == 0) && (stringValue != NULL)) {
            NSString *brandString = [NSString stringWithUTF8String:stringValue];
            NSRange range = [brandString rangeOfString:@"  "];
            if (range.location != NSNotFound)
                brandString = [brandString substringWithRange:NSMakeRange(range.location, [brandString length] - range.location)];
            range = [brandString rangeOfString:@"@"];
            if (range.location != NSNotFound)
                cpuModel = [[brandString substringWithRange:NSMakeRange(0, range.location)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if (cpuModel)
                [feedParameters addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"cpuModel", @"CPU Model", cpuModel, cpuModel, nil] 
                                                                      forKeys:keys]];
        }
    }
    
    return [[feedParameters copy] autorelease];
}



#pragma mark About Window

- (IBAction)openAboutWindow:(id)sender
{   
    if ((aboutWindow == nil) && ![NSBundle loadNibNamed:@"AboutWindow" owner:self]) {
        BBLog(@"Failed to load AboutWindow.xib");
        return;
    }
    
    if (![aboutWindow setFrameUsingName:@"AboutWindow" force:NO])
        [aboutWindow center];
    [NSApp activateIgnoringOtherApps:YES];
    [aboutWindow makeKeyAndOrderFront:self];
    [creditView setEditable:NO];
}


- (NSString*)versionString
{   
    return [NSString stringWithFormat:NSLocalizedString(@"Version %@", @"application version"), [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleGetInfoString"]];
}


- (NSString*)copyrightString
{
    return [[[NSBundle mainBundle] infoDictionary] valueForKey:@"NSHumanReadableCopyright"];    
}


- (NSAttributedString *)creditString
{
    return [[[NSAttributedString alloc] initWithRTF:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"credits" ofType:@"rtf"]] documentAttributes:NULL] autorelease];
}


@end
