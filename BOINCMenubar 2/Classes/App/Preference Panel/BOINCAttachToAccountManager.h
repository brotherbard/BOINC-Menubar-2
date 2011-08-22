//
//  BOINCAttachToAccountManager.h
//  BOINCMenubar
//
//  Created by BrotherBard on 4/26/09.
//  Copyright 2009 BrotherBard <nkinsinger at brotherbard dot com>. All rights reserved.
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


@class BOINCAccountManagerSummary;
@class BOINCClient;


@interface BOINCAttachToAccountManager : NSWindowController 
{
    NSWindow            *prefsWindow;
    
    // various bits of configuration info
    BOINCClient          *client;
    NSString            *managerURL;
    NSString            *managerName;
    
    // info entered by the user
    NSString            *accountUsername;
    NSString            *accountPassword;
    
    // the subview of the sheet that holds indiviual views (like those below)
    NSView              *contentSubview;
    
    // the in-progress view, while waiting for a reply from the account manager
    NSView              *attachProgressView;
    NSProgressIndicator *progressIndicator;
    NSString            *progressInformation;
    
    // main account info view
    NSView              *accountInformationView;
    NSTextField         *accountUsernameField;
    NSTextField         *accountUsernameLabel;
    NSTextField         *accountUsernameErrorLabel;
    
    // successfull completion view
    NSView              *successfulAttachView;
    NSTextField         *successfulAttachMessageField;
    NSButton            *successfulAttachButton;
    
    // view for showing error messages
    NSView              *errorView;
    NSTextField         *mainErrorMessageField;
    NSTextField         *subErrorMessageField;
    NSButton            *errorBackButton;
    NSButton            *errorCancelButton;
}
@property (copy)            NSString            *accountUsername;
@property (copy)            NSString            *accountPassword;

@property (retain) IBOutlet NSView              *contentSubview;

@property (retain) IBOutlet NSView              *attachProgressView;
@property (retain) IBOutlet NSProgressIndicator *progressIndicator;
@property (copy)            NSString            *progressInformation;

@property (retain) IBOutlet NSView              *accountInformationView;
@property (retain) IBOutlet NSTextField         *accountUsernameField;
@property (retain) IBOutlet NSTextField         *accountUsernameLabel;
@property (retain) IBOutlet NSTextField         *accountUsernameErrorLabel;

@property (retain) IBOutlet NSView              *successfulAttachView;
@property (retain) IBOutlet NSTextField         *successfulAttachMessageField;
@property (retain) IBOutlet NSButton            *successfulAttachButton;

@property (retain) IBOutlet NSView              *errorView;
@property (retain) IBOutlet NSTextField         *mainErrorMessageField;
@property (retain) IBOutlet NSTextField         *subErrorMessageField;
@property (retain) IBOutlet NSButton            *errorBackButton;
@property (retain) IBOutlet NSButton            *errorCancelButton;


- (void)beginAttachAccountManagerSheetInWindow:(NSWindow *)mainWindow 
                                     forClient:(BOINCClient *)activeClient 
                     withAccountManagerSummary:(BOINCAccountManagerSummary *)selectedSummary;

- (void)beginAttachAccountManagerSheetInWindow:(NSWindow *)mainWindow 
                                     forClient:(BOINCClient *)activeClient 
                                       withURL:(NSString *)url;


- (void)didEndSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;

- (IBAction)cancelAttachToAccountManagerSheet:(id)sender;
- (IBAction)openAccountManagerWebsite:(id)sender;
- (IBAction)loginToAccountManager:(id)sender;
- (IBAction)finishAttach:(id)sender;
- (IBAction)backToAccountInfo:(id)sender;

@end
