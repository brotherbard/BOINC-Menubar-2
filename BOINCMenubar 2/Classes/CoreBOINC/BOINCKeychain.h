//
//  BOINCKeychain.h
//  BOINCMenubar
//
//  Created by BrotherBard on 12/31/08.
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

//
//  Code is very inspired by Wade Tregaskis' Keychain.Framework. Thanks Wade!
//  http://sourceforge.net/projects/keychain/
//


#import <Cocoa/Cocoa.h>


// BOINCKeychain is a singleton class (note: the singleton nature is not enforced, so watch out). Init the singleton with
// +keychainWithClientManager: with a BOINCClientManager (or a subclass)(should be done right at the begining of the app).
// Then, subsequent calls should be made to +defaultKeychain to get the BOINCKeychain reference.

// BOINCKeychain is used to get a reference to the users Keychain, search the Keychain for "BOINC host password" items, add
// new BOINC keychain items, and to monitor changes that the user or other processes make to BOINC keychain items (to keep 
// the internal representation correct).

// WARNING: BOINCKeychain sets up a callback to the Keychain and will add and *delete* BOINCClients from the client manager
//          in response to those changes!!!


@class BOINCKeychainItem;
@class BOINCClientManager;


@interface BOINCKeychain : NSObject
{
    SecKeychainRef _keychain;
    OSStatus       _error;
    
    BOINCClientManager *clientManager;  // weak ref
}


// designated init -- will fail and return nil if it can't access the users Keychain
+ (id)keychainWithClientManager:(BOINCClientManager *)manager;

// called to get the current BOINCKeychain reference
// returns nil if the default keychain has not been (successfully) init'd with +keychainWithClientManager: first
+ (BOINCKeychain *)defaultKeychain;

// the last error returned from the Keychain Services API calls
// if a call fails you can check this error for logic, debugging or to determine a message to show the user
- (OSStatus)lastError;

// adds a new keychain item to the users Keychain and returns the reference to it or NULL if there is an error (check -lastError)
// all new keychain items *must* have an address or you will get an exception
// password and name are optional:
//    if password is nil or an empty string then that means to ask for the password every time we connect (or to read the local password)
//    if name is nil or an empty string then we copy the address
- (SecKeychainItemRef)keychainItemWithPassword:(NSString *)password forAddress:(NSString *)address name:(NSString *)name;

// searchs the users Keychain and creates a BOINCKeychainItem for each item found and returns an array of
// BOINCKeychainItem's for all items in the Keychain, or nil if there are no items or if there was an error
// NOTE: intended to be called once at the begining of the app to find all the existing items
- (NSArray *)allBOINCKeychainItems;

// returns the BOINCKeychainItem for the address or NULL if it can't find one
// check -lastError and if is errSecDuplicateItem then there is already a keychain item with that address (there can be only one!)
// so toss the returned BOINCKeychainItem
- (BOINCKeychainItem *)findBOINCKeychainItemForAddress:(NSString *)address;


@end
