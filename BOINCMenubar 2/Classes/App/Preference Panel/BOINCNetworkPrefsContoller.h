//
//  BOINCNetworkPrefsContoller.h
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
@class BOINCNetProxySettings;
@class BOINCHostSelectionController;



@interface BOINCNetworkPrefsContoller : NSViewController
{
    BOINCActiveClientManager     *clientManager;
    
    BOINCNetProxySettings        *activePreferences;
    BOINCNetProxySettings        *editedPreferences;
    NSString                     *preferenceForHost;
    NSView                       *mainContentView;
    NSView                       *hostSelectionView;
    BOINCHostSelectionController *hostSelectionController;
     
    NSView                       *mainPreferencesSubview;
    NSView                       *noHostConnectedSubview;
    NSWindow                     *editNetworkPreferenceSheet;
     
    NSTabView                    *editPreferencesTabView;
    NSTabView                    *proxySettingsTabView;
    NSButton                     *editButton;
     
    NSTextField                  *httpProxyEnabledField;
    NSTextField                  *httpProxyAddressField;
    NSTextField                  *httpProxyPortField;
    NSTextField                  *httpProxyUserNameField;
    NSTextField                  *httpProxyPasswordField;
     
    NSTextField                  *socksProxyEnabledField;
    NSTextField                  *socksProxyAddressField;
    NSTextField                  *socksProxyPortField;
    NSTextField                  *socksProxyUserNameField;
    NSTextField                  *socksProxyPasswordField;
    
    NSColor                      *httpProxyTextColor;
    NSColor                      *socksProxyTextColor;
}
@property (nonatomic, assign) BOINCActiveClientManager     *clientManager; // weak reference
@property (nonatomic, retain) BOINCNetProxySettings        *activePreferences;
@property (nonatomic, retain) BOINCNetProxySettings        *editedPreferences;
@property (nonatomic, copy)            NSString            *preferenceForHost;
@property (nonatomic, retain) IBOutlet NSView              *mainContentView;
@property (nonatomic, retain) IBOutlet NSView              *hostSelectionView;
@property (nonatomic, retain) BOINCHostSelectionController *hostSelectionController;

@property (nonatomic, retain) IBOutlet NSView              *mainPreferencesSubview;
@property (nonatomic, retain) IBOutlet NSView              *noHostConnectedSubview;
@property (nonatomic, retain) IBOutlet NSWindow            *editNetworkPreferenceSheet;

@property (nonatomic, retain) IBOutlet NSTabView           *editPreferencesTabView;
@property (nonatomic, retain) IBOutlet NSTabView           *proxySettingsTabView;
@property (nonatomic, retain) IBOutlet NSButton            *editButton;

@property (nonatomic, retain) IBOutlet NSTextField         *httpProxyEnabledField;
@property (nonatomic, retain) IBOutlet NSTextField         *httpProxyAddressField;
@property (nonatomic, retain) IBOutlet NSTextField         *httpProxyPortField;
@property (nonatomic, retain) IBOutlet NSTextField         *httpProxyUserNameField;
@property (nonatomic, retain) IBOutlet NSTextField         *httpProxyPasswordField;

@property (nonatomic, retain) IBOutlet NSTextField         *socksProxyEnabledField;
@property (nonatomic, retain) IBOutlet NSTextField         *socksProxyAddressField;
@property (nonatomic, retain) IBOutlet NSTextField         *socksProxyPortField;
@property (nonatomic, retain) IBOutlet NSTextField         *socksProxyUserNameField;
@property (nonatomic, retain) IBOutlet NSTextField         *socksProxyPasswordField;

@property (nonatomic, copy)            NSColor             *httpProxyTextColor;
@property (nonatomic, copy)            NSColor             *socksProxyTextColor;


- (id)initWithClientManager:(id)manager;

- (IBAction)editPreferences:(id)sender;
- (IBAction)saveEditedPreferences:(id)sender;
- (IBAction)cancelEditedPreferences:(id)sender;
- (IBAction)clearChangesInEditedPreferences:(id)sender;


@end
