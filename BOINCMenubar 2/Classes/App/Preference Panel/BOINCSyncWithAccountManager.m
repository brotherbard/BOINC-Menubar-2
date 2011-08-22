//
//  BOINCSyncWithAccountManager.m
//  BOINCMenubar
//
//  Created by BrotherBard on 5/2/09.
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

#import "BOINCSyncWithAccountManager.h"
#import "BMBPreferenceWindowController.h"
#import "BOINCProjectsPrefController.h"
#import "BOINCClientManager.h"



@interface BOINCSyncWithAccountManager()

- (void)switchSheetToView:(NSView *)newView;

@end



@implementation BOINCSyncWithAccountManager

@synthesize managerURL;
@synthesize managerName;

@synthesize contentSubview;

@synthesize syncProgressView;
@synthesize progressIndicator;
@synthesize progressInformation;

@synthesize successfulSyncView;
@synthesize successfulSyncMessageField;
@synthesize successfulSyncButton;

@synthesize errorView;
@synthesize mainErrorMessageField;
@synthesize subErrorMessageField;
@synthesize errorBackButton;
@synthesize errorCancelButton;



- (void)dealloc
{
    [managerURL  release];
    [managerName release];
    
    [contentSubview release];
    
    [syncProgressView    release];
    [progressIndicator   release];
    [progressInformation release];
    
    [successfulSyncView         release];
    [successfulSyncMessageField release];
    [successfulSyncButton       release];
    
    [errorView             release];
    [mainErrorMessageField release];
    [subErrorMessageField  release];
    [errorBackButton       release];
    [errorCancelButton     release];
    
    prefsWindow = nil;
    client = nil;
    
    [super dealloc];
}


#pragma mark -
#pragma mark opening and closing the sheet

- (void)beginSyncWithAccountManagerSheetInWindow:(NSWindow *)mainWindow forClient:(BOINCClient *)activeClient 
{
    prefsWindow = mainWindow;   // weak link
    client      = activeClient; // weak link
    
    if (client.accountManager == nil)
        return;
    
    managerURL       = client.accountManager.url;
    self.managerName = client.accountManager.name;
    
    // just to make sure the window is loaded
    [self window];
    
    self.progressInformation = [NSString stringWithFormat:@"Connecting to: %@", managerURL];
    [self switchSheetToView:syncProgressView];
    [progressIndicator startAnimation:nil];
        
    [NSApp beginSheet:[self window]
       modalForWindow:prefsWindow 
        modalDelegate:self 
       didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) 
          contextInfo:nil];
    
    [client performAccountManagerSynchronizeForTarget:self callbackSelector:@selector(accountManagerSynchronizeCallback:)];
}


// close the sheet
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


// note that the back button goes back to the account info sheet via backToAccountInfo:
- (void)showErrorViewWithMainMessage:(NSString *)mainMessage subMessage:(NSString *)subMessage enableBackButton:(BOOL)isBackButtonEnabled
{
    [mainErrorMessageField setStringValue:mainMessage];
    [subErrorMessageField  setStringValue:subMessage];
    
    // show/hide the Back button and change the default button between Back and Cancel
    if (isBackButtonEnabled) {
        [errorBackButton   setEnabled:YES];
        [errorBackButton   setKeyEquivalent:@"\r"]; // makes the back button the default button
        [errorCancelButton setKeyEquivalent:@""];
    } else {
        [errorBackButton   setEnabled:NO];
        [errorBackButton   setKeyEquivalent:@""];
        [errorCancelButton setKeyEquivalent:@"\r"]; // makes the cancel button the default button
    }
    
    [self switchSheetToView:errorView];
}




#pragma mark IB Actions

- (IBAction)cancelAttachToAccountManagerSheet:(id)sender
{
    [client cancelExistingPollingRPC];
    [NSApp endSheet:[self window]];
}


- (IBAction)openAccountManagerWebsite:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:self.managerURL]];
}


- (IBAction)finishSync:(id)sender
{
    [self cancelAttachToAccountManagerSheet:nil];
    
    BMBPreferenceWindowController *prefsWindowController  = [prefsWindow windowController];
    BOINCProjectsPrefController   *projectsViewController = [prefsWindowController currentViewController];
    [projectsViewController reloadSummaryTree];
}



#pragma mark checking and handling errors

- (BOOL)handleRPCErrorNumber:(int)errorNumber errorMessage:(NSString *)errorMessage
{
    if (errorMessage && (errorNumber == 0)) {
        if ([errorMessage isEqualToString:@"Missing URL"])
            errorNumber = -189;
        else if ([errorMessage isEqualToString:@"unauthorized"])
            errorNumber = -155;
        else 
            errorNumber = -1; // error not found
    }
    
    switch (errorNumber) {
        case 0:
            // 0 = success, RPC did not fail
            return NO;
            break;
            
        case -138: // ERR_DB_CANT_CONNECT
        case -183: // ERR_PROJECT_DOWN
            BBLog(@"attach account manager = account manager down");
            [self showErrorViewWithMainMessage:@"The account manager is temporarily unavailable.\n\nPlease visit the account manager's website to find more information. When the account manager is up and running you can try again." 
                                    subMessage:@""
                              enableBackButton:NO];
            break;
            
        case -189: // ERR_INVALID_URL
        case -224: // ERR_FILE_NOT_FOUND
            BBLog(@"attach account manager = file not found (not a boinc account manager, account manager down, error in URL)");
            [self showErrorViewWithMainMessage:@"This website is either not a BOINC account manager, the account manager's servers are down or there is an error in the URL.\n\nCheck that the website URL is correct and try again. If the URL is correct, visit the website to make sure the account manager is up and running." 
                                    subMessage:@""
                              enableBackButton:NO];
            break;
            
        case -203: // ERR_NO_NETWORK_CONNECTION
            BBLog(@"attach account manager = no internet connection");
            [self showErrorViewWithMainMessage:@"No Internet connection.\n\nPlease connect to the internet and try again."
                                    subMessage:@""
                              enableBackButton:NO];
            break;
            
        case -204: // Polling in progress
            // should not get this
            BBLog(@"Error: Polling in progress recieved by Attach to Account Manager Sheet");
            break;
            
        default:
            BBLog(@"manager:%@  unknown RPC error = %d  message = %@", self.managerName, errorNumber, errorMessage);
            NSString *subMessage = nil;
            if (errorNumber == -1)
                subMessage = [NSString stringWithFormat:@"Error Message: %@", errorMessage];
            else
                subMessage = [NSString stringWithFormat:@"Error Number: %d", errorNumber];
            
            [self showErrorViewWithMainMessage:@"There was an unknown error while commuicating with the account manager." 
                                    subMessage:subMessage
                              enableBackButton:NO];
            break;
    }
    
    return YES;
}



#pragma mark Account Info 

- (void)accountManagerSynchronizeCallback:(BOINCAttachReply *)accountManagerSyncInfo
{
    if (!accountManagerSyncInfo) {
        BBLog(@"Sync with Account Manager: failed to parse the xml reply");
        
        [self showErrorViewWithMainMessage:@"There was an error while communicating with the account manager." 
                                subMessage:@""
                          enableBackButton:NO];
        return;
    }
    
    if (accountManagerSyncInfo.errorNumber) {
        [self handleRPCErrorNumber:accountManagerSyncInfo.errorNumber errorMessage:nil];
        BBLog(@"RPC error = %d", accountManagerSyncInfo.errorNumber);
        return;
    }
    
    [successfulSyncMessageField setStringValue:[NSString stringWithFormat:@"Successfully synchronized with %@.", self.managerName]];
    
    [self switchSheetToView:successfulSyncView];
}


@end
