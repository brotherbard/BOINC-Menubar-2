//
//  BMBAppController.h
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
#import "FeedbackReporter/FRFeedbackReporter.h"



// for User Defaults
#define kRunBOINCClient         @"RunBOINCClient"
#define kRunBOINCClientAsDaemon @"RunBOINCClientAsDaemon"
#define kShowGrowlNotifications @"ShowGrowlNotifications"




@class BMBStatusMenuController;
@class BMBPreferenceWindowController;
@class BOINCActiveClientManager;
@class BMBGrowlNotifier;



@interface BMBAppController : NSObject <FRFeedbackReporterDelegate>
{
    BOINCActiveClientManager      *_clientManager;
    BMBStatusMenuController       *_boincMenu;
    BMBPreferenceWindowController *_prefController;
    BMBGrowlNotifier              *_growlNotifier;
    
    NSWindow                      *aboutWindow;
    NSTextView                    *creditView;
    
    NSTask                        *boincClientTask;
}
@property (nonatomic, retain) IBOutlet NSWindow   *aboutWindow;
@property (nonatomic, retain) IBOutlet NSTextView *creditView;


// opening the preferences window
- (IBAction)openPreferencesWindow:(id)sender;
- (IBAction)editHosts:(id)sender;
- (IBAction)joinNewProject:(id)sender;

// opens boinc.berkeley.edu in default web browser
- (IBAction)openBoincSite:(id)sender;
// opens http://brotherbard.com/boinc/ in default web browser
- (IBAction)openBoincMenubarSite:(id)sender;

// Feedback
- (IBAction)openFeedbackEMail:(id)sender;

// for the about window
- (IBAction)openAboutWindow:(id)sender;
- (NSString*)versionString;
- (NSString*)copyrightString;


@end
