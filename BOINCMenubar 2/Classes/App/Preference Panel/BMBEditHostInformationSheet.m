//
//  BMBEditHostInformationSheet.m
//  BOINCMenubar
//
//  Created by BrotherBard on 1/1/09.
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

#import "BMBEditHostInformationSheet.h"
#import "BMBHostsPrefController.h"
#import "BOINCClientManager.h"

#import "BOINCKeychain.h"
#import "BOINCKeychainItem.h"

#import "BOINCClientManager.h"



//////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BMBEditHostInformationSheet

@synthesize nameField;
@synthesize nameRequiredError;

@synthesize hostAddressField;
@synthesize hostAddressRequiredError;

@synthesize storePassword;
@synthesize passwordField;
@synthesize passwordrequiredError;


- (void)dealloc
{
    [nameField release];              
    [nameRequiredError release];      
    [hostAddressField release];       
    [hostAddressRequiredError release];
    [passwordField release];          
    [passwordrequiredError release];  
    
    [super dealloc];
}


- (void)awakeFromNib
{
    NSDictionary *attributesDict = [NSDictionary dictionaryWithObject:[NSColor darkGrayColor] forKey:NSForegroundColorAttributeName];
    
    [[nameField cell] setPlaceholderAttributedString:[[[NSAttributedString alloc] initWithString:@"Enter a name here." attributes:attributesDict] autorelease]];
    
    [[hostAddressField cell] setPlaceholderAttributedString:[[[NSAttributedString alloc] initWithString:@"Enter the host's address here." attributes:attributesDict] autorelease]];
    
    [[passwordField cell] setPlaceholderAttributedString:[[[NSAttributedString alloc] initWithString:@"Enter BOINC's password here." attributes:attributesDict] autorelease]];
}



- (void)resetUI
{
    [nameRequiredError setHidden:YES];
    [hostAddressRequiredError setHidden:YES];
    [passwordrequiredError setHidden:YES];
    
    self.storePassword = NO;
    
    [nameField setStringValue:@""];
    [hostAddressField setStringValue:@""];
    [passwordField setStringValue:@""];
    
    [[self window] makeFirstResponder:nameField];
}



#pragma mark Begin/End Sheet

- (void)beginEditHost:(BOINCClient *)editHost withClientManager:(id)manager forWindow:(NSWindow *)prefWindow target:(id)target
{
    didEndTarget = target;
    host = editHost;
    _isAddingNewHost = NO;
    clientManager = manager;
    
    [self window];
    [self resetUI];
    
    [nameField setStringValue:host.clientName];
    
    [hostAddressField setStringValue:host.hostAddress];
    
    if (host.password) {
        self.storePassword = YES;
        [passwordField setStringValue:host.password];
    }
    
    [NSApp beginSheet:[self window]
       modalForWindow:prefWindow 
        modalDelegate:self 
       didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) 
          contextInfo:nil];
}


- (void)beginAddHostInWindow:(NSWindow *)prefWindow target:(id)target withClientManager:(id)manager
{
    didEndTarget = target;
    _isAddingNewHost = YES;
    host = nil;
    clientManager = manager;
    
    [self window];
    [self resetUI];
    
    [NSApp beginSheet:[self window]
       modalForWindow:prefWindow 
        modalDelegate:self 
       didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) 
          contextInfo:nil];
}



// closes the sheet
- (void)didEndSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{   
    [sheet orderOut:self];
}


- (void)finishEditHostSheet
{   
    [[self window] makeFirstResponder:nil];
    
    if ([host.hostAddress isEqualToString:[hostAddressField stringValue]]) {
        // the address stayed the same
        host.password = storePassword ? [passwordField stringValue] : nil;
        host.clientName = [nameField stringValue];
        
        [NSApp endSheet:[self window]];
        [(BMBHostsPrefController *)didEndTarget didEndEditHost];
        
        BBError(@"Edited client: %@", host);
        return;
    }
    
    // new address so check it first
    BOINCKeychainItem *item = [clientManager.keychain findBOINCKeychainItemForAddress:[hostAddressField stringValue]];
    if (item) {
        // the address is in use
        BBLog(@"BOINCKeychain isDuplicate"); 
        // TODO: need to do something else here
        NSBeep();
        [NSApp endSheet:[self window]];
        
        return;
    }
    
    // all good
    host.password = storePassword ? [passwordField stringValue] : nil;
    host.hostAddress = [hostAddressField stringValue];
    host.clientName = [nameField stringValue];
    
    [NSApp endSheet:[self window]];
    BBError(@"Edited client: %@", host);
    [(BMBHostsPrefController *)didEndTarget didEndEditHost];
}


- (void)finishAddHostSheet
{
    [[self window] makeFirstResponder:nil];
    
    BOINCKeychainItem *item = [[[BOINCKeychainItem alloc] initWithPassword:(storePassword ? [passwordField stringValue] : nil)
                                                                   address:[hostAddressField stringValue] 
                                                                      name:[nameField stringValue]] autorelease];
    
    if ([item isDuplicate]) {
        // the address is in use
        BBLog(@"BOINCKeychain isDuplicate"); 
        // TODO: need to do something else here
        NSBeep();
        [NSApp endSheet:[self window]];
        return;
    }
    
    if ([item lastError]) {
        BBLog(@"BOINCKeychain an error occured while creating the keychain"); 
        // TODO: need to do something else here
        NSBeep();
        [NSApp endSheet:[self window]];
        return;
    }
    
    // all good
    host = [[[BOINCClient alloc] initWithBOINCKeychainItem:item] autorelease];
    
    [NSApp endSheet:[self window]];
    BBError(@"Added client: %@", host);
    [(BMBHostsPrefController *)didEndTarget didEndAddHost:host];
}



#pragma mark Action methods

- (IBAction)cancelEditHost:(id)sender
{
    [NSApp endSheet:[self window]];
}


- (IBAction)confirmEditHost:(id)sender
{
    BOOL foundError = NO;
    
    if (self.storePassword && [[passwordField stringValue] isEqualToString:@""]) {
        foundError = YES;
        [passwordrequiredError setHidden:NO];
        [[self window] makeFirstResponder:passwordField];
    } else 
        [passwordrequiredError setHidden:YES];
    
    if ([[hostAddressField stringValue] isEqualToString:@""]) {
        foundError = YES;
        [hostAddressRequiredError setHidden:NO];
        [[self window] makeFirstResponder:hostAddressField];
    } else 
        [hostAddressRequiredError setHidden:YES];
    
    if ([[nameField stringValue] isEqualToString:@""]) {
        foundError = YES;
        [nameRequiredError setHidden:NO];
        [[self window] makeFirstResponder:nameField];
    } else 
        [nameRequiredError setHidden:YES];
    
    
    if (!foundError) {
        if (_isAddingNewHost) 
            [self finishAddHostSheet];
        else
            [self finishEditHostSheet];
    }
}


- (IBAction)viewFindPasswordHelp:(id)sender
{
    BBLog(@"Say something informative");
}


- (IBAction)viewEditHostInformationHelp:(id)sender
{
    BBLog(@"Say something very informative");
}


@end
