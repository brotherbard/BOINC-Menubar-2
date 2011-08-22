//
//  BOINCAttachToProjectSheet.m
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

#import "BOINCAttachToProjectSheet.h"
#import "BOINCProjectsPrefController.h"
#import "BMBPreferenceWindowController.h"

#import "BOINCClientManager.h"
#import "BB_XMLNodeXPathCategory.h"
#import <AddressBook/AddressBook.h>



////////////////////////////////////////////////////////////
// TESTING

//#define TESTING_ATTACH_GUI    // uncomment to test the GUI

#ifdef TESTING_ATTACH_GUI
// this is just used to test the GUI without actually messing with real projects
@interface TestClient : BOINCClient
{
}
+ (TestClient *)testClient;
@end
#endif
////////////////////////////////////////////////////////////



#pragma mark -
@interface BOINCAttachToProjectSheet(BMBPrivate)
//- (void)projectConfigurationCallback:(NSDictionary *)replyDict; 
//- (void)projectAttachCallback:(NSDictionary *)replyDict;

- (void)switchSheetToView:(NSView *)newView;
- (void)showExistingAccountInformationView;
- (void)showAccountInformationView;
- (void)showErrorViewWithMainMessage:(NSString *)mainMessage subMessage:(NSString *)subMessage enableBackButton:(BOOL)isBackButtonEnabled;

- (void)startProjectConfigurationRequest;
- (void)startLookupAccountRequest;
- (void)startCreateAccountRequest;
- (void)startProjectAttachRequest;
@end


// for NSUserDefaults keys
NSString * const kBMBLastAttachProjectUserName = @"kBMBLastAttachProjectUserName";
NSString * const kBMBLastAttachProjectEmailAddress = @"kBMBLastAttachProjectEmailAddress";



#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BOINCAttachToProjectSheet

@synthesize progressInformation;
@synthesize amWarningInformation;

@synthesize projectURL;
@synthesize projectName;

@synthesize emailOrUsernameLabel;
@synthesize minPasswordLengthLabel;

@synthesize useExistingAccount;

@synthesize accountEmailAddress;
@synthesize accountEmailOrUsername;
@synthesize accountUsername;
@synthesize accountPassword;
@synthesize confirmPassword;




- (void)dealloc
{
    [accountEmailAddress    release];
    [accountUsername        release];
    [accountEmailOrUsername release];
    [accountPassword        release];
    [confirmPassword        release];
    [projectURL             release];
    [projectName            release];
    [emailOrUsernameLabel   release];
    [minPasswordLengthLabel release];
    [configMessage          release];
    [authenticator          release];
    [progressInformation    release];
    [amWarningInformation   release];
    
    prefsWindow = nil;
    client = nil;
    
    [super dealloc];
}


// set the BOOL (in IB it's bound to the radio buttons), but also change the visiblity and position of some of the labels and text fields based on the setting
- (void)setUseExistingAccount:(BOOL)state
{
    useExistingAccount = state;
    if (useExistingAccount) {
        [accountMinPasswordSizeLabel setFrame:alternateMinPasswordSizeLabelFrame];
        
        [accountConfirmPasswordField setHidden:YES];
        [accountConfirmPasswordLabel setHidden:YES];
        // clear the errors labels
        [accountConfirmPasswordErrorLabel setHidden:YES];
        [accountEmailLabel setHidden:YES];
        [accountUsernameErrorLabel setHidden:YES];
                
        if (usesUsername) {
            [accountEmailField setHidden:YES];
            [accountEmailLabel setHidden:YES];
            
            [accountUsernameField setHidden:NO];
            [accountUsernameLabel setHidden:NO];
        }
        else {
            [accountEmailField setHidden:NO];
            [accountEmailLabel setHidden:NO];
            
            [accountUsernameField setHidden:YES];
            [accountUsernameLabel setHidden:YES];
        }
    } else {
        [accountMinPasswordSizeLabel setFrame:defautMinPasswordSizeLabelFrame];
        
        [accountConfirmPasswordField setHidden:NO];
        [accountConfirmPasswordLabel setHidden:NO];
        // clear the error labels
        [accountConfirmPasswordErrorLabel setHidden:YES];
        [accountEmailLabel setHidden:YES];
        [accountUsernameErrorLabel setHidden:YES];
        
        [accountEmailField setHidden:NO];
        [accountEmailLabel setHidden:NO];
        
        [accountUsernameField setHidden:NO];
        [accountUsernameLabel setHidden:NO];
    }
}


#pragma mark -
#pragma mark opening and closing the sheet

// attaching to a project in the all project's list
- (void)beginAttachProjectSheetInWindow:(NSWindow *)mainWindow forClient:(BOINCClient *)activeClient withProjectSummary:(BOINCProjectSummary *)selectedSummary
{
    prefsWindow = mainWindow; // weak link
    client = activeClient; // weak link
    
#ifdef TESTING_ATTACH_GUI
    BBLog(@"Testing attach GUI, will not contact projects");
    client = [TestClient testClient];
#endif  
    
    self.projectURL = [selectedSummary projectURL];
    self.projectName = [selectedSummary projectName];
    self.useExistingAccount = NO;
    
    [self startProjectConfigurationRequest];
}


// attaching to a project from "Join unlisted project" using just the url
- (void)beginAttachProjectSheetInWindow:(NSWindow *)mainWindow forClient:(BOINCClient *)activeClient withURL:(NSString *)url
{
    prefsWindow = mainWindow; // weak link
    client = activeClient; //weak link
    
#ifdef TESTING_ATTACH_GUI
    BBLog(@"Testing attach GUI, will not contact projects");
    client = [TestClient testClient];
#endif
        
    // is there a good way to test if we recieved a reasonable http url???
    if ([url isEqualToString:@""] || [url isEqualToString:@"http://"]) {
        BBLog(@"invalid URL");
        return;
    }
    
    if (![url hasPrefix:@"http"])
        url = [@"http://" stringByAppendingString:url];
    if (![url hasSuffix:@"/"])
        url = [url stringByAppendingString:@"/"];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    self.projectURL = url;
    self.projectName = [NSString stringWithFormat:@"BOINC project at: %@", self.projectURL];
    self.useExistingAccount = NO;
    
    [self startProjectConfigurationRequest];
}


// closes the sheet
- (void)didEndSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{   
    [sheet orderOut:self];
}



#pragma mark setting up custom views

- (void)switchSheetToView:(NSView *)newView
{
    while ([[contentSubview subviews] count] > 0)
        [[[contentSubview subviews] objectAtIndex:0] removeFromSuperviewWithoutNeedingDisplay];
    
    [contentSubview addSubview:newView];
}


- (void)showExistingAccountInformationView
{
    // reset ui
    [existingAccountErrorLabel setHidden:YES];
    [existingAccountMinPasswordSizeLabel setTextColor:[NSColor blackColor]];
    self.useExistingAccount = YES;
    [[self window] makeFirstResponder:existingAccountField];
    
    // setup instructions
    if (accountCreationDisabled) {
        [existingAccountMainInstruction setStringValue:@"This project is not currently accepting new accounts."];
        [existingAccountSubInstruction setStringValue:@"If you already have an account, enter your existing account information below.\nVisit the website to find out if or when new accounts will be allowed."];
    }
    else {
        // clientAccountCreationDisabled
        [existingAccountMainInstruction setStringValue:@"This project requires that new accounts be created on their website."];
        [existingAccountSubInstruction setStringValue:@"If you already have an account, enter your existing account information below.\nTo create an account, visit the project's website."];
    }
    
    [self switchSheetToView:existingAccountInformationView];
}


- (void)showAccountInformationView
{
    // used to move the label for "minimun password length" based on wether or not the confirm password field is visible
    if (!framesHaveBeenCalculated) {
        framesHaveBeenCalculated = YES;
        // default position used for "Create new account"
        defautMinPasswordSizeLabelFrame = [accountMinPasswordSizeLabel frame];
        // alternate position used for "Use existing account"
        alternateMinPasswordSizeLabelFrame = [accountConfirmPasswordField frame];
    }
    
    // reset ui
    [accountUsernameField setTextColor:[NSColor blackColor]];
    [accountUsernameLabel setTextColor:[NSColor blackColor]];
    [accountUsernameErrorLabel setHidden:YES];
    
    [accountEmailField setTextColor:[NSColor blackColor]];
    [accountEmailLabel setTextColor:[NSColor blackColor]];
    [accountEmailErrorLabel setHidden:YES];
    
    [accountPasswordField setTextColor:[NSColor blackColor]];
    [accountPasswordLabel setTextColor:[NSColor blackColor]];
    [accountMinPasswordSizeLabel setTextColor:[NSColor blackColor]];
    
    [accountConfirmPasswordField setTextColor:[NSColor blackColor]];
    [accountConfirmPasswordLabel setTextColor:[NSColor blackColor]];
    [accountConfirmPasswordErrorLabel setHidden:YES];
    
    [self switchSheetToView:accountInformationView];
    
    [[self window] makeFirstResponder:accountUsernameField];
}


// note that the back button goes back to the account info sheet via |backToAccountInfo:|
- (void)showErrorViewWithMainMessage:(NSString *)mainMessage subMessage:(NSString *)subMessage enableBackButton:(BOOL)isBackButtonEnabled
{
    [mainErrorMessageField setStringValue:mainMessage];
    [subErrorMessageField setStringValue:subMessage];
    
    // show/hide the Back button and change the default button between Back and Cancel
    if (isBackButtonEnabled) {
        [errorBackButton setEnabled:YES];
        [errorCancelButton setKeyEquivalent:@""];
        [errorBackButton setKeyEquivalent:@"\r"]; // makes the back button the default button
    } else {
        [errorBackButton setEnabled:NO];
        [errorBackButton setKeyEquivalent:@""];
        [errorCancelButton setKeyEquivalent:@"\r"]; // makes the cancel button the default button
    }
    
    // reset passwords
    self.accountPassword = nil;
    self.confirmPassword = nil;
    
    [self switchSheetToView:errorView];
}



#pragma mark IB Actions

- (IBAction)cancelAttachToProjectSheet:(id)sender
{
    [client cancelExistingPollingRPC];
    [NSApp endSheet:[self window]];
}


- (IBAction)openProjectWebsite:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:projectURL]];
}


/*
 sendAccountInformation:
 
 verify that all required info has been entered
 test in reverse order based on the location of the text fields so that the top-most field with an error will be the firstResponder (the field the curser is in)
 */
- (IBAction)sendAccountInformation:(id)sender
{   
    if (usesUsername) 
        self.accountEmailOrUsername = accountUsername;
    else
        self.accountEmailOrUsername = accountEmailAddress;
    
    BOOL foundError = NO;
    
    [[self window] makeFirstResponder:accountUsernameField];
    
    if (!useExistingAccount && ![accountPassword isEqualToString:confirmPassword]) {
        foundError = YES;
        [accountConfirmPasswordErrorLabel setHidden:NO];
        [accountConfirmPasswordLabel setTextColor:[NSColor redColor]];
        [[self window] makeFirstResponder:accountConfirmPasswordField];
    } else {
        [accountConfirmPasswordErrorLabel setHidden:YES];
        [accountConfirmPasswordLabel setTextColor:[NSColor blackColor]];
    }
    
    if ([accountPassword length] < (NSUInteger)minPasswordLength) {
        foundError = YES;
        [accountMinPasswordSizeLabel setTextColor:[NSColor redColor]];
        [accountPasswordLabel setTextColor:[NSColor redColor]];
        [[self window] makeFirstResponder:accountPasswordField];
    } else {
        [accountMinPasswordSizeLabel setTextColor:[NSColor blackColor]];
        [accountPasswordLabel setTextColor:[NSColor blackColor]];
    }
    
    if ((!useExistingAccount || !usesUsername) && ![accountEmailAddress length]) {
        foundError = YES;
        [accountEmailErrorLabel setHidden:NO];
        [[self window] makeFirstResponder:accountEmailField];
    } else {
        [accountEmailErrorLabel setHidden:YES];
    }
    
    if ((!useExistingAccount || usesUsername) && ![accountUsername length]) {
        foundError = YES;
        [accountUsernameErrorLabel setHidden:NO];
        [[self window] makeFirstResponder:accountUsernameField];
    } else {
        [accountUsernameErrorLabel setHidden:YES];
    }
    
    if (foundError == NO) { 
        if (useExistingAccount)
            [self startLookupAccountRequest];
        else
            [self startCreateAccountRequest];
    }
}


/*
 sendExistingAccountInformation:
 
 verify that all required info has been entered
 test in reverse order based on the location of the text fields so that the top-most field with an error will be the firstResponder (the field the curser is in)
 */
- (IBAction)sendExistingAccountInformation:(id)sender
{   
    BOOL foundError = NO;
    
    [[self window] makeFirstResponder:existingAccountField];
    
    if ([accountPassword length] < (uint)minPasswordLength) {
        foundError = YES;
        [existingAccountPasswordLabel setTextColor:[NSColor redColor]];
        [existingAccountMinPasswordSizeLabel setTextColor:[NSColor redColor]];
        [[self window] makeFirstResponder:existingAccountPasswordField];
    } else {
        [existingAccountPasswordLabel setTextColor:[NSColor blackColor]];
        [existingAccountMinPasswordSizeLabel setTextColor:[NSColor blackColor]];
    }
    
    if (![accountEmailOrUsername length]) {
        foundError = YES;
        [existingAccountErrorLabel setStringValue:usesUsername ? @"You need to enter a username." : @"You need to enter an email address."];
        [existingAccountErrorLabel setHidden:NO];
        [existingAccountLabel setTextColor:[NSColor redColor]];
        [[self window] makeFirstResponder:existingAccountField];
    } else {
        [existingAccountErrorLabel setHidden:YES];
        [existingAccountLabel setTextColor:[NSColor blackColor]];
    }
    
    if (foundError == NO)
        [self startLookupAccountRequest];
}


- (IBAction)finishAttachProject:(id)sender
{
    [self cancelAttachToProjectSheet:nil];
    
    if (!useExistingAccount) { 
        // when creating a new account
        NSString *urlString = [NSString stringWithFormat:@"%@account_finish.php?auth=%@", projectURL, authenticator ];
#ifdef TESTING_ATTACH_GUI
        BBLog(@"Attach To Project: Success\n%@", urlString);
#else
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:urlString]];
#endif
    }
    
    BMBPreferenceWindowController *prefsWindowController = [prefsWindow windowController];
    BOINCProjectsPrefController *projectsViewController = [prefsWindowController currentViewController];
    [projectsViewController reloadSummaryTree];
}


- (IBAction)backToAccountInfo:(id)sender
{
    if (accountCreationDisabled || clientAccountCreationDisabled)
        [self showExistingAccountInformationView];
    else 
        [self showAccountInformationView];
}


- (IBAction)continueAfterWarning:(id)sender
{
    [self switchSheetToView:attachProgressView];
    [progressIndicator startAnimation:nil];
    
    [client performProjectConfigurationRequestForURL:projectURL target:self callbackSelector:@selector(projectConfigurationCallback:)];
}


- (IBAction)openAccountManagerWebsite:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:client.accountManager.url]];
}



#pragma mark checking and handling errors

- (BOOL)handleRPCErrorNumber:(int)errorNumber errorMessage:(NSString *)errorMessage
{
    if (errorMessage && (errorNumber == 0)) {
        errorNumber = -1; // error not found
        
        if ([errorMessage isEqualToString:@"Already attached to project"]) 
            errorNumber = -130;
        else if ([errorMessage isEqualToString:@"Missing URL"])
            errorNumber = -189;
        else if ([errorMessage isEqualToString:@"Missing authenticator"] || [errorMessage isEqualToString:@"unauthorized"])
            errorNumber = -155; 
    }
    
    switch (errorNumber) {
        case 0:
            // 0 = success, RPC did not fail
            return NO;
            break;
        case -183: // ERR_PROJECT_DOWN
        case -138: // ERR_DB_CANT_CONNECT
            BBLog(@"project config = project down");
            [self showErrorViewWithMainMessage:@"The project is temporarily unavailable.\n\nPlease visit the project's website to find more information. When the project is up and running you can try again." 
                                    subMessage:@""
                              enableBackButton:NO];
            break;
        case -224: // ERR_FILE_NOT_FOUND
        case -189: // ERR_INVALID_URL
            BBLog(@"project config = file not found (not a boinc project, project down, error in URL)");
            [self showErrorViewWithMainMessage:@"This website is either not a BOINC project, the project's servers are down or there is an error in the URL.\n\nCheck that the website URL is correct and try again. If the URL is correct, visit the website to make sure the project is up and running." 
                                    subMessage:@""
                              enableBackButton:NO];
            break;
        case  -203: // ERR_NO_NETWORK_CONNECTION
            BBLog(@"project config = no internet connection");
            [self showErrorViewWithMainMessage:@"No Internet connection.\n\nPlease connect to the internet and try again."
                                    subMessage:@""
                              enableBackButton:NO];
            break;
        case -137: // ERR_DB_NOT_UNIQUE
        case -207: // ERR_NONUNIQUE_EMAIL
            BBLog(@"create account = not a unique account (email or user name)");
            [self showErrorViewWithMainMessage:[NSString stringWithFormat:@"An account with %@ %@ already exists and has a different password than the one you entered.\n\nPlease visit the project's web site and follow the instructions there.", [emailOrUsernameLabel lowercaseString], accountEmailOrUsername] 
                                    subMessage:@""
                              enableBackButton:YES];
            break;
        case -205: // ERR_BAD_EMAIL_ADDR
            BBLog(@"create account = bad email address");
            [self showErrorViewWithMainMessage:@"The email address you supplied is not valid.\n\nGo back and check that it is entered correctly, then try again." 
                                    subMessage:@""
                              enableBackButton:YES];
            break;
        case -208: // ERR_ACCT_CREATION_DISABLED
            // should never get this. if a project dosen't report it in the config RPC but then returns this error, disable creating an account
            accountCreationDisabled = YES;
            BBLog(@"create account = account creation disabled");
            [self showErrorViewWithMainMessage:@"Account creation for this project is disabled.\n\nYou can only attach this computer if you already have an account. Please visit the project's web site and follow the instructions there." 
                                    subMessage:@""
                              enableBackButton:YES];
            break;
        case -209: // ERR_ATTACH_FAIL_INIT
            // I'm not sure that BMB will get this type of error, but just in case...
            BBLog(@"create account = attach init failed");
            [self showErrorViewWithMainMessage:@"Creating a new account failed.\n\nPlease visit the project's web site and follow the instructions for creating new accounts." 
                                    subMessage:@""
                              enableBackButton:NO];
            break;
        case -136: // ERR_DB_NOT_FOUND
        case -161: // ERR_NOT_FOUND
            BBLog(@"lookup account = can't find account (email or user name)");
            [self showErrorViewWithMainMessage:[NSString stringWithFormat:@"Login Failed.\n\nCheck the %@ and password, then try again", usesUsername ? @"username" : @"email address"] 
                                    subMessage:@""
                              enableBackButton:YES];
            break;
        case  -206: // ERR_BAD_PASSWD
            BBLog(@"lookup account = wrong password");
            [self showErrorViewWithMainMessage:[NSString stringWithFormat:@"The password you entered is not valid for %@ %@.\n\nGo back and reenter the password, then try again.\n\nIf you've forgotten your password, go to the project's website and follow the instructions for lost passwords.", [emailOrUsernameLabel lowercaseString], accountEmailOrUsername]
                                    subMessage:@""
                              enableBackButton:YES];
            break;
        case  -130: // ERR_ALREADY_ATTACHED
            BBLog(@"project attach = already attached");
            [self showErrorViewWithMainMessage:[NSString stringWithFormat:@"You are already attached to this project."]
                                    subMessage:@""
                              enableBackButton:NO];
            break;
        case  -204: // Polling in progress
            // should not get this
            BBLog(@"Error: Polling in progress recieved by Attach to Project Sheet");
            break;
        default:
            BBLog(@"unknown RPC error = %d  message = %@", errorNumber, errorMessage);
            NSString *subMessage = nil;
            if (errorNumber == -1)
                subMessage = [NSString stringWithFormat:@"Error Message: %@", errorMessage];
            else
                subMessage = [NSString stringWithFormat:@"Error Number: %d", errorNumber];
            
            [self showErrorViewWithMainMessage:@"There was an unknown error while commuicating with the project." 
                                    subMessage:subMessage
                              enableBackButton:NO];
            break;
    }
    
    return YES;
}

        


#pragma mark Project Configuration

- (void)startProjectConfigurationRequest
{
    self.progressInformation = [NSString stringWithFormat:@"Connecting to: %@", projectURL];
    [self window]; // just to make sure the window is loaded
    [self switchSheetToView:attachProgressView];
    [progressIndicator startAnimation:nil];

    // reset passwords
    self.accountPassword = nil;
    self.confirmPassword = nil;
    
    if (!self.accountUsername) {
        self.accountUsername = [[NSUserDefaults standardUserDefaults] objectForKey:kBMBLastAttachProjectUserName];
        if (!self.accountUsername) 
            self.accountUsername = NSFullUserName();
    }
    
    if (!self.accountEmailAddress) {
        self.accountEmailAddress = [[NSUserDefaults standardUserDefaults] objectForKey:kBMBLastAttachProjectEmailAddress];
        if (!self.accountEmailAddress) {
            ABPerson *participant = [[ABAddressBook sharedAddressBook] me];
            ABMultiValue *emailList = [participant valueForProperty:kABEmailProperty];
            self.accountEmailAddress = [emailList valueForIdentifier:[emailList primaryIdentifier]];
        }
    }
    
    [NSApp beginSheet:[self window]
       modalForWindow:prefsWindow 
        modalDelegate:self 
       didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) 
          contextInfo:nil];
    
    if (client.accountManager) {
        self.amWarningInformation = [NSString stringWithFormat:@"You are attached to the %@ account manager.\n\nProjects added here will not be listed on or managed by %@.\n\nIf possible, attach to projects at %@'s website.\n\nIf you still wish to attach to the project then click Continue.", client.accountManager.name, client.accountManager.name, client.accountManager.name];
        [self switchSheetToView:amWarningView];
    } else
    	[client performProjectConfigurationRequestForURL:projectURL target:self callbackSelector:@selector(projectConfigurationCallback:)];
}


- (void)projectConfigurationCallback:(BOINCProjectConfig *)projectConfiguration
{
    if (!projectConfiguration) {
        BBLog(@"Attach To Project: failed to parse project configuration");
        [self showErrorViewWithMainMessage:@"There was an error while commuicating with the project." 
                                subMessage:@"Failed to recieve a valid project configuration."
                          enableBackButton:NO];
        return;
    }
    
    if (projectConfiguration.errorNumber) {
        // do some kind of failure thing here
        [self handleRPCErrorNumber:projectConfiguration.errorNumber errorMessage:projectConfiguration.errorMessage];
        BBLog(@"RPC error = %d  message = %@", projectConfiguration.errorNumber, projectConfiguration.errorMessage);
        return;
    }
    
    self.projectName = projectConfiguration.projectName;
    if (projectConfiguration.rpcPrefix)
        self.projectURL = projectConfiguration.rpcPrefix;
    
    minPasswordLength = projectConfiguration.minPasswordLength;
    if (minPasswordLength == 0)
        minPasswordLength = 6;
    self.minPasswordLengthLabel = [NSString stringWithFormat:@"Minimum password length is %d characters.", minPasswordLength];
    
    usesUsername = projectConfiguration.usesUsername;
    self.emailOrUsernameLabel = usesUsername ? @"User name:" : @"Email address:";
    if (usesUsername)
        self.accountEmailOrUsername = self.accountUsername;
    else
        self.accountEmailOrUsername = self.accountEmailAddress;
    
    accountCreationDisabled = projectConfiguration.accountCreationDisabled;
    clientAccountCreationDisabled = projectConfiguration.clientAccountCreationDisabled;
    
    // these two are unused at the moment
    // accountManager = projectConfiguration.accountManager;
    // configMessage = [projectConfiguration.message lastObject];
    
    if (accountCreationDisabled || clientAccountCreationDisabled)
        [self showExistingAccountInformationView];
    else 
        [self showAccountInformationView];
}


#pragma mark Lookup Account 
- (void)startLookupAccountRequest
{
    self.progressInformation = [NSString stringWithFormat:@"Looking up account for: %@", accountEmailOrUsername];
    [self switchSheetToView:attachProgressView];
    
    [client performLookupAccountRequestForAccount:accountEmailOrUsername 
                                     withPassword:accountPassword 
                                            atURL:projectURL 
                                           target:self 
                                 callbackSelector:@selector(accountCallback:)];
}


#pragma mark Create Account
- (void)startCreateAccountRequest
{
    if (usesUsername)
        accountEmailOrUsername = accountUsername;
    else
        accountEmailOrUsername = accountEmailAddress;
    self.progressInformation = [NSString stringWithFormat:@"Creating account for: %@", accountEmailOrUsername];
    [self switchSheetToView:attachProgressView];
    
    [client performCreateAccountRequestForAccount:accountEmailAddress
                                     withUserName:accountUsername
                                      andPassword:accountPassword 
                                            atURL:projectURL 
                                           target:self 
                                 callbackSelector:@selector(accountCallback:)];
}


// used for both Lookup Account and Create Account RPCs
- (void)accountCallback:(BOINCAccountOut *)accountInfo
{
    if (!accountInfo) {
        BBLog(@"Attach To Project: lookup/create account failed to parse account out xml");
        
        [self showErrorViewWithMainMessage:@"There was an error while looking up or creating the account." 
                                subMessage:@"Account authentication failed."
                          enableBackButton:NO];
        return;
    }
    
    if (accountInfo.errorNumber) {
        // do some kind of failure thing here
        [self handleRPCErrorNumber:accountInfo.errorNumber errorMessage:nil];
        BBLog(@"RPC error = %d", accountInfo.errorNumber);
        return;
    }
    
    [authenticator release];
    authenticator = [accountInfo.authenticator retain];
    
    if (!authenticator) {
        BBLog(@"Attach To Project: lookup/create account failed to return an authenticator or an error");
        
        [self showErrorViewWithMainMessage:@"There was an error while looking up or creating the account." 
                                subMessage:@"Account authentication failed."
                          enableBackButton:NO];
        return;
    }
    
    [self startProjectAttachRequest];
}


#pragma mark Project Attach
- (void)startProjectAttachRequest
{
    // don't need these anymore, just make sure they are cleared
    self.accountPassword = nil;
    self.confirmPassword = nil;
    
    self.progressInformation = [NSString stringWithFormat:@"Attaching to project: %@", projectName];
    [self switchSheetToView:attachProgressView];
    
    [client performProjectAttachRequestForProject:projectName 
                                            atURL:projectURL 
                                withAuthenticator:authenticator 
                                           target:self 
                                 callbackSelector:@selector(projectAttachCallback:)];
}


- (void)projectAttachCallback:(BOINCAttachReply *)projectAttachInfo
{
    if (!projectAttachInfo) {
        BBLog(@"Attach To Project: project attach failed to parse xml");
        
        [self showErrorViewWithMainMessage:@"There was an error while looking up the account." 
                                subMessage:@"Account authentication failed."
                          enableBackButton:NO];
        return;
    }
    
    if (projectAttachInfo.errorNumber) {
        // do some kind of failure thing here
        [self handleRPCErrorNumber:projectAttachInfo.errorNumber errorMessage:nil];
        BBLog(@"RPC error = %d", projectAttachInfo.errorNumber);
        return;
    }
    
    if (useExistingAccount) {
        [successfulAttachMessageField setStringValue:[NSString stringWithFormat:@"You have successfully attached to this project using an existing account.\n\n\t%@ %@\n\t\n\tHost computer: %@", emailOrUsernameLabel, accountEmailOrUsername, client.fullName]];
        [successfulAttachButton setTitle:@"Done"];
        if (usesUsername)
            [[NSUserDefaults standardUserDefaults] setObject:accountEmailOrUsername forKey:kBMBLastAttachProjectUserName];
        else
            [[NSUserDefaults standardUserDefaults] setObject:accountEmailOrUsername forKey:kBMBLastAttachProjectEmailAddress];
    }
    else {
        [successfulAttachMessageField setStringValue:[NSString stringWithFormat:@"You have created a new account and are now successfully attached to this project.\n\n\tUser name: %@\n\tEmail address: %@\n\tHost computer: %@\n\nWhen you click Finish, your web browser will go to a page where you can set your account preferences.", accountUsername, accountEmailAddress, client.fullName]];
        [successfulAttachButton setTitle:@"Finish"];
        [[NSUserDefaults standardUserDefaults] setObject:accountUsername forKey:kBMBLastAttachProjectUserName];
        [[NSUserDefaults standardUserDefaults] setObject:accountEmailAddress forKey:kBMBLastAttachProjectEmailAddress];
    }
        
    [self switchSheetToView:successfulAttachView];
}



@end



//**************************************************************************************************************
//**************************************************************************************************************
//**************************************************************************************************************
//**************************************************************************************************************
//**************************************************************************************************************
//**************************************************************************************************************

#ifdef TESTING_ATTACH_GUI
#pragma mark -
// TestClinet is a subclass of BOINCClient that is used in testing the GUI for attaching projects
// it overrides the perform... methods to return canned responses mimicking a project's responses

// determines how long the attachProgressView is shown before moving to the next step (to simulate the time communicating with the project)
#define TESTDELAY 1.0


@implementation TestClient

+ (TestClient *)testClient
{
    static TestClient *_testClient = nil;
    if (!_testClient) 
        _testClient = [[TestClient alloc] init];
    
    return _testClient;
}


- (NSString *)clientName
{
    return @"Test host";
}


- (NSString *)hostAddress
{
    return @"192.68.10.10";
}


- (void)performProjectConfigurationRequestForURL:(NSString *)projectURL 
                                          target:(id)target 
                                callbackSelector:(SEL)callbackSelector
{
    BOINCProjectConfig *config = [[BOINCProjectConfig alloc] init];
    config.projectName = [NSString stringWithFormat:@"%@ (testing)", [target projectName]];
    config.masterURL = projectURL;
    //config.rpcPrefix = @"http://redirected.project.url.example.com/";
    config.clientAccountCreationDisabled = YES;
    //config.accountCreationDisabled = YES;
    //config.webStopped = YES;
    //config.schedulerStopped = YES;
    //config.usesUsername = YES;
    //config.accountManager = YES;
    config.termsOfUse = @"Terms of Use";
    //config.errorNumber = -183; // project config = project down
    //config.errorNumber = -224; // project config = file not found (not a boinc project, project down, error in URL)
    //config.errorNumber = -451; // an unknown error
    
    [target performSelector:callbackSelector 
                 withObject:config
                 afterDelay:TESTDELAY
                    inModes:[NSArray arrayWithObjects:NSDefaultRunLoopMode, NSModalPanelRunLoopMode, NSEventTrackingRunLoopMode, nil]];
    
    return;
}


- (void)performLookupAccountRequestForAccount:(NSString *)emailOrUsername 
                                 withPassword:(NSString *)password 
                                        atURL:(NSString *)projectURL 
                                       target:(id)target 
                             callbackSelector:(SEL)callbackSelector
{
    BOINCAccountOut *account = [[BOINCAccountOut alloc] init];
    account.authenticator = @"This is a test authenticator";
    //account.errorNumber = -136;// lookup account = can't find account (email or user name)
    //account.errorNumber = -206;// lookup account = wrong password
    //config.errorNumber = -451; // an unknown error
    
    [target performSelector:callbackSelector
                 withObject:account
                 afterDelay:TESTDELAY
                    inModes:[NSArray arrayWithObjects:NSDefaultRunLoopMode, NSModalPanelRunLoopMode, NSEventTrackingRunLoopMode, nil]];
    
    return;
}


- (void)performCreateAccountRequestForAccount:(NSString *)emailAddress 
                                 withUserName:(NSString *)userName 
                                  andPassword:(NSString *)password 
                                        atURL:(NSString *)projectURL 
                                       target:(id)target 
                             callbackSelector:(SEL)callbackSelector
{
    BOINCAccountOut *account = [[BOINCAccountOut alloc] init];
    account.authenticator = @"This is a test authenticator";
    //account.errorNumber = -137;// create account = not a unique account (email or user name)
    //account.errorNumber = -207;// create account = not a unique account (email or user name)
    //account.errorNumber = -205;// create account = bad email address
    //account.errorNumber = -208;// create account = account creation disabled
    //account.errorNumber = -209;// create account = attach failed
    //config.errorNumber = -451; // an unknown error
    
    [target performSelector:callbackSelector
                 withObject:account
                 afterDelay:TESTDELAY
                    inModes:[NSArray arrayWithObjects:NSDefaultRunLoopMode, NSModalPanelRunLoopMode, NSEventTrackingRunLoopMode, nil]];
    
    return;
}


- (void)performProjectAttachRequestForProject:(NSString *)projectName 
                                        atURL:(NSString *)projectURL 
                            withAuthenticator:(NSString *)authenticator 
                                       target:(id)target 
                             callbackSelector:(SEL)callbackSelector
{
    BOINCProjectAttach *attach = [[BOINCProjectAttach alloc] init];
    //attach.errorNumber = -130; // project attach = already attached to project
    //config.errorNumber = -451; // an unknown error
    
    [target performSelector:callbackSelector 
                 withObject:attach
                 afterDelay:TESTDELAY
                    inModes:[NSArray arrayWithObjects:NSDefaultRunLoopMode, NSModalPanelRunLoopMode, NSEventTrackingRunLoopMode, nil]];
    
    return;
}

@end
#endif

