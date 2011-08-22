//
//  BOINCAttachToProjectSheet.h
//  BOINCMenubar
//
//  Created by BrotherBard on 10/18/08.
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


@class BOINCClient;
@class BOINCProjectSummary;

@interface BOINCAttachToProjectSheet : NSWindowController
{
    NSWindow *prefsWindow;
    
    // various bits of configuration info
    BOINCClient *client;
    NSString   *projectURL;
    NSString   *projectName;
    
    // info entered by the user
    BOOL      useExistingAccount;
    NSString *accountEmailAddress;
    NSString *accountUsername;
    NSString *accountEmailOrUsername;
    NSString *accountPassword;
    NSString *confirmPassword;
    
    // info returned by RPCs
    BOOL       usesUsername;
    BOOL       accountCreationDisabled;
    BOOL       clientAccountCreationDisabled;
    BOOL       accountManager;
    NSUInteger minPasswordLength;
    NSString  *configMessage;
    NSString  *authenticator;
    
    // label strings used in the GUI
    NSString *emailOrUsernameLabel;
    NSString *minPasswordLengthLabel;
    
    // the subview of the sheet that holds indiviual views (like those below)
    IBOutlet NSView *contentSubview;
    
    // the in-progress view, while waiting for a reply from the project
    IBOutlet NSView              *attachProgressView;
    IBOutlet NSProgressIndicator *progressIndicator;
    NSString                     *progressInformation;
    
    // a warning about attaching to a project while using an account manager
    IBOutlet NSView              *amWarningView;
    NSString                     *amWarningInformation;
    
    // view for showing error messages
    IBOutlet NSView      *errorView;
    IBOutlet NSTextField *mainErrorMessageField;
    IBOutlet NSTextField *subErrorMessageField;
    IBOutlet NSButton    *errorBackButton;
    IBOutlet NSButton    *errorCancelButton;
    
    // main account info view
    IBOutlet NSView      *accountInformationView;
    IBOutlet NSTextField *accountUsernameField;
    IBOutlet NSTextField *accountUsernameLabel;
    IBOutlet NSTextField *accountUsernameErrorLabel;
    IBOutlet NSTextField *accountEmailField;
    IBOutlet NSTextField *accountEmailLabel;
    IBOutlet NSTextField *accountEmailErrorLabel;
    IBOutlet NSTextField *accountPasswordField;
    IBOutlet NSTextField *accountPasswordLabel;
    IBOutlet NSTextField *accountConfirmPasswordField;
    IBOutlet NSTextField *accountConfirmPasswordLabel;
    IBOutlet NSTextField *accountMinPasswordSizeLabel;
    IBOutlet NSTextField *accountConfirmPasswordErrorLabel;
    // used to move labels and text fields when the user changes the "New account"/"Existing account" radio buttons
    NSRect defautMinPasswordSizeLabelFrame, alternateMinPasswordSizeLabelFrame;
    BOOL framesHaveBeenCalculated;
    
    // account info view when account creation is disabled
    IBOutlet NSView      *existingAccountInformationView;
    IBOutlet NSTextField *existingAccountMainInstruction;
    IBOutlet NSTextField *existingAccountSubInstruction;
    IBOutlet NSTextField *existingAccountLabel;
    IBOutlet NSTextField *existingAccountField;
    IBOutlet NSTextField *existingAccountErrorLabel;
    IBOutlet NSTextField *existingAccountPasswordLabel;
    IBOutlet NSTextField *existingAccountPasswordField;
    IBOutlet NSTextField *existingAccountMinPasswordSizeLabel;
    
    // successfull completion view
    IBOutlet NSView      *successfulAttachView;
    IBOutlet NSTextField *successfulAttachMessageField;
    IBOutlet NSButton    *successfulAttachButton;
}

@property (nonatomic, copy)   NSString *projectURL;
@property (nonatomic, copy)   NSString *projectName;
@property (nonatomic, copy)   NSString *emailOrUsernameLabel;
@property (nonatomic, copy)   NSString *minPasswordLengthLabel;

@property (nonatomic, copy)   NSString *progressInformation;
@property (nonatomic, copy)   NSString *amWarningInformation;

@property (nonatomic, assign) BOOL      useExistingAccount;
@property (nonatomic, copy)   NSString *accountEmailAddress;
@property (nonatomic, copy)   NSString *accountUsername;
@property (nonatomic, copy)   NSString *accountEmailOrUsername;
@property (nonatomic, copy)   NSString *accountPassword;
@property (nonatomic, copy)   NSString *confirmPassword;


- (IBAction)cancelAttachToProjectSheet:(id)sender;
- (IBAction)openProjectWebsite:(id)sender;
- (IBAction)sendAccountInformation:(id)sender;
- (IBAction)sendExistingAccountInformation:(id)sender;
- (IBAction)finishAttachProject:(id)sender;
- (IBAction)backToAccountInfo:(id)sender;
- (IBAction)continueAfterWarning:(id)sender;
- (IBAction)openAccountManagerWebsite:(id)sender;


- (void)beginAttachProjectSheetInWindow:(NSWindow *)mainWindow 
                              forClient:(BOINCClient *)activeClient 
                     withProjectSummary:(BOINCProjectSummary *)selectedSummary;

- (void)beginAttachProjectSheetInWindow:(NSWindow *)mainWindow 
                              forClient:(BOINCClient *)activeClient 
                                withURL:(NSString *)url;


- (void)didEndSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;

@end
