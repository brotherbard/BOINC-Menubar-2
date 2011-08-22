//
//  BOINCLonginWindowController.m
//  BOINCMenubar
//
//  Created by BrotherBard on 1/10/09.
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

#import "BOINCLogInWindowController.h"
#import "BOINCActiveClientManager.h"
#import "BOINCClientManager.h"



//////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BOINCLoginWindowController


@synthesize passwordField;
@synthesize hostLabel;
@synthesize client;



- (id)initWithClient:(BOINCClient *)newClient clientManager:(id)manager
{
    NSAssert(newClient, @"initWithHost: cannot init with a nil client");
    NSAssert(manager,   @"initWithHost: cannot init with a nil clientManager");
    
    if (newClient == nil) {
        [self release];
        return nil;
    }
    
    self = [super initWithWindowNibName:@"BOINCLoginWindow" owner:self];
    if (!self) return nil;
    
    [self setShouldCascadeWindows:NO];
    
    client        = [newClient retain];
    clientManager = manager;
    
    self.hostLabel = self.client.fullName;
    
    return self;
}


- (void)dealloc
{
    [passwordField release];
    [hostLabel     release];
    [client        release];
    
    [super dealloc];
}


- (void)awakeFromNib
{   
    if ([self isWindowLoaded] == NO) { 
        if (![[self window] setFrameUsingName:@"BOINCLoginWindow" force:YES]) {
            [[self window] center];
            [[self window] setFrameAutosaveName:@"BOINCLoginWindow"];
        }
        [[self window] setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces];
    }
    
    [self showLoginWindow];
}


- (IBAction)sendPassword:(id)sender
{   
    if ([[passwordField stringValue] isEqualToString:@""])
        NSBeep();
    else {
        if (storePassword)
            client.password = [passwordField stringValue];
        [[self window] close];
        [clientManager connectToClient:self.client withPassword:(storePassword ? nil : [passwordField stringValue])];
        [clientManager loginWindowClosed];
    }
}


- (IBAction)cancel:(id)sender
{
    [[self window] close];
    self.client = nil;
    
    [clientManager loginWindowClosed];
}


- (void)showLoginWindow
{
    [NSApp activateIgnoringOtherApps:YES];
    [[self window] makeKeyAndOrderFront:self];
}
    



@end
