//
//  BOINCNetworkPrefsContoller.m
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

#import "BOINCNetworkPrefsContoller.h"
#import "BOINCActiveClientManager.h"

#import "BOINCClientManager.h"
#import "BOINCHostSelectionController.h"


@interface BOINCNetworkPrefsContoller ()

- (void)updateNetworkPreferenceStrings;
- (void)updateMainContentView;

@end



#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BOINCNetworkPrefsContoller


@synthesize clientManager;
@synthesize activePreferences;
@synthesize editedPreferences;
@synthesize preferenceForHost;
@synthesize mainContentView;
@synthesize hostSelectionView;
@synthesize hostSelectionController;

@synthesize mainPreferencesSubview;
@synthesize noHostConnectedSubview;
@synthesize editNetworkPreferenceSheet;

@synthesize editPreferencesTabView;
@synthesize proxySettingsTabView;
@synthesize editButton;

@synthesize httpProxyEnabledField;
@synthesize httpProxyAddressField;
@synthesize httpProxyPortField;
@synthesize httpProxyUserNameField;
@synthesize httpProxyPasswordField;

@synthesize socksProxyEnabledField;
@synthesize socksProxyAddressField;
@synthesize socksProxyPortField;
@synthesize socksProxyUserNameField;
@synthesize socksProxyPasswordField;

@synthesize httpProxyTextColor;
@synthesize socksProxyTextColor;


#define kProxyTabViewIndexKey @"Proxy Tab View Index"

+ (void)initialize
{
    if (self != [BOINCNetworkPrefsContoller class])
        return;
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObject:@"1" forKey:kProxyTabViewIndexKey]];
}


- (id)initWithClientManager:(id)manager
{
    self = [super initWithNibName:@"BOINCNetworkPreferences" bundle:nil];
    if (!self) return nil;
    
    self.clientManager = manager;
    
    self.httpProxyTextColor = [NSColor controlTextColor];
    self.socksProxyTextColor = [NSColor controlTextColor];
    
    return self;
}


- (void)dealloc
{
    clientManager = nil;
    [activePreferences release];
    [editedPreferences release];
    [preferenceForHost release];
    [mainContentView release];
    
    [mainPreferencesSubview release];
    [noHostConnectedSubview release];
    [editNetworkPreferenceSheet release];
    
    [editPreferencesTabView release];
    [proxySettingsTabView release];
    [editButton release];
    
    [httpProxyEnabledField release];
    [httpProxyAddressField release];
    [httpProxyPortField release];
    [httpProxyUserNameField release];
    [httpProxyPasswordField release];
    
    [socksProxyEnabledField release];
    [socksProxyAddressField release];
    [socksProxyPortField release];
    [socksProxyUserNameField release];
    [socksProxyPasswordField release];
    
    [httpProxyTextColor release];
    [socksProxyTextColor release];
    
    [super dealloc];
}


- (void)awakeFromNib
{
    hostSelectionController = [[BOINCHostSelectionController hostSelectionControllerWithClientManager:clientManager] retain];
    [hostSelectionView addSubview:[hostSelectionController view]];
}



#pragma mark BMB_ViewController_Category methods

static const void *activeClientContext;
static const void *proxyPreferencesContext;

- (void)BMB_contentViewWillLoad
{
    [self.clientManager addObserver:self forKeyPath:@"activeClient.isConnected" options:0 context:&activeClientContext];
    [self.clientManager addObserver:self forKeyPath:@"activeClient.lastProxySettingsUpdate" options:0 context:&proxyPreferencesContext];
    
    [self.clientManager.activeClient requestProxySettingsUpdate];
}


- (void)BMB_contentViewDidUnload
{
    [self.clientManager removeObserver:self forKeyPath:@"activeClient.isConnected"];
    [self.clientManager removeObserver:self forKeyPath:@"activeClient.lastProxySettingsUpdate"];
    [[[self view] window] makeFirstResponder:nil];
}



#pragma mark KVO methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == &activeClientContext) {
        if (self.clientManager.activeClient.isConnected) {
            // the active client changed so update the proxy information
            [self.clientManager.activeClient requestProxySettingsUpdate];
        } else
            [self updateMainContentView];
        return;
    }
    
    if (context == &proxyPreferencesContext) {
        // the proxy information changed so update the view
        self.activePreferences = self.clientManager.activeClient.proxySettings;
        [self updateMainContentView];
        return;
    }
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}



#pragma mark NSTabView delegate methods

// keep the two tab views in sync
- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
    [[NSUserDefaults standardUserDefaults] setObject:[tabViewItem identifier] forKey:kProxyTabViewIndexKey];
    if (tabView == proxySettingsTabView)
        [editPreferencesTabView selectTabViewItemWithIdentifier:[tabViewItem identifier]];
    else
        [proxySettingsTabView selectTabViewItemWithIdentifier:[tabViewItem identifier]];
}



#pragma mark NSControl delegate methods
/*
 for the number based text fields (i.e. fields that have an NSNumberFormatter):
 -  don't allow invalid values (handled by BMBNumbersOnlyFormatter)
 -  make sure the numbers are in range
 -  for non numbers or empty string, reset the string to the current value of the bound model object
 
 change the string to match correct values and return YES
 returning NO will open an ugly 'Format Error' sheet on the window (so don't do it!!!)
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

- (IBAction)editPreferences:(id)sender
{
    self.editedPreferences = [self.activePreferences copy];
    
    [NSApp beginSheet:editNetworkPreferenceSheet
       modalForWindow:[[self view] window]
        modalDelegate:self
       didEndSelector:@selector(didEndSheet:returnCode:contextInfo:)
          contextInfo:nil];
}


- (IBAction)saveEditedPreferences:(id)sender
{
    [[sender window] makeFirstResponder:nil];
    [self.clientManager.activeClient setProxyInformation:self.editedPreferences];
    
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
        self.preferenceForHost = [NSString stringWithFormat:@"Network Preferences for Host: %@", self.clientManager.activeClient.fullName];
        id identifier = [[NSUserDefaults standardUserDefaults] stringForKey:kProxyTabViewIndexKey];
        [editPreferencesTabView selectTabViewItemWithIdentifier:identifier];
        [proxySettingsTabView selectTabViewItemWithIdentifier:identifier];
        if (self.activePreferences)
            [self updateNetworkPreferenceStrings];
        [self switchContentToView:mainPreferencesSubview];
        [editButton setEnabled:YES];
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
        [editButton setEnabled:NO];
    }
}


- (void)updateNetworkPreferenceStrings
{
    if (self.activePreferences.useHTTPProxy) {
        [httpProxyEnabledField setStringValue:@"HTTP Proxy Server: Enabled"];
        self.httpProxyTextColor = [NSColor controlTextColor];
    }
    else {
        [httpProxyEnabledField setStringValue:@"HTTP Proxy Server: Disabled"];
        self.httpProxyTextColor = [NSColor disabledControlTextColor];
    }
    
    [httpProxyAddressField setStringValue:self.activePreferences.httpServerName];
    [httpProxyPortField setStringValue:[[NSNumber numberWithInteger:self.activePreferences.httpServerPort] stringValue]];
    [httpProxyUserNameField setStringValue:self.activePreferences.httpUserName];
    [httpProxyPasswordField setStringValue:self.activePreferences.httpUserPassword];
    
    if (self.activePreferences.useSocksProxy) {
        [socksProxyEnabledField setStringValue:@"SOCKS Proxy Server: Enabled"];
        self.socksProxyTextColor = [NSColor controlTextColor];
    }
    else {
        [socksProxyEnabledField setStringValue:@"SOCKS Proxy Server: Disabled"];
        self.socksProxyTextColor = [NSColor disabledControlTextColor];
    }
    
    [socksProxyAddressField setStringValue:self.activePreferences.socksServerName];
    [socksProxyPortField setStringValue:[[NSNumber numberWithInteger:self.activePreferences.socksServerPort] stringValue]];
    [socksProxyUserNameField setStringValue:self.activePreferences.socks5UserName];
    [socksProxyPasswordField setStringValue:self.activePreferences.socks5UserPassword];
}



@end
