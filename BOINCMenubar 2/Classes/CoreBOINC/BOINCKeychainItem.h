//
//  BOINCKeychainItem.h
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

// BOINCKeychainItem's are used to interface with the Keychain Services to create and read the keychain data.
// This is intended primarily as internal to the MacBOINC framework, there still needs to be some work done to
// better hide this funtionality.


@class KeychainItem;
@class BOINCClientManager;



@interface BOINCKeychainItem : NSObject
{
@private
    SecKeychainItemRef _keychainItem;
    OSStatus           _error;
    
    // these are caches of the keychain data
    NSString          *_uuid;
    NSString          *_name;
    NSString          *_address;
    NSDate            *_modifiedDate;
    
    BOOL               _isPasswordInKeychain;
    BOOL               _hasSetIsPasswordInKeychain;
    BOOL               _isDuplicate;
}


// Private: should only be used by BOINCKeychain
- (id)initWithKeychainItem:(SecKeychainItemRef)keychainItem;


// desinated init for external classes
// address is required
// password and name are optional:
//    if password is nil or an empty string then that means to ask for the password every time we connect (or to read the local password)
//    if name is nil or an empty string then we copy the address
- (id)initWithPassword:(NSString *)newPassword address:(NSString *)newAddress name:(NSString *)newName;


// used to remove the keychain item from the users Keychain
- (void)deleteKeychainItem;


// resets all the cached info so that it will be re-read from the keychain next time
// Private: should only be used by BOINCKeychain
- (void)reset;


// pointer equality (normally you should use/check -uuid unless all you have is the SecKeychainItemRef)
- (BOOL)isEqualToKeychainItemRef:(SecKeychainItemRef)itemRef;


// the last error returned from the Keychain Services API calls
// if a call fails you can check this error for logic, debugging or to determine a message to show the user
- (OSStatus)lastError;


// every keychain item is identified with an Universally Unique Identifier (UUID), in theory the user never changes this
// all the other attributes of a keychain the user may change, so don't rely on them
// ex: the client manager uses this to store in the user defaults so it can keep track of which client was last selected
//     when the program restarts
// the UUID is created internally by BOINCKeychain and is meant to be readonly after that
// this is stored in the Account attribute (kSecAccountItemAttr) of a SecKeychainItemRef (Account field in Keychain.app)
- (NSString *)uuid;


// this is a user supplied name for the keychain item
// this is stored in the Label attribute (kSecLabelItemAttr) of a SecKeychainItemRef (the Name field in Keychain.app)
- (NSString *)name;
- (void)setName:(NSString *)newName;


// this is a unique user supplied address for the host (currently can be IPv4 or a host name)
// an address is required to create a new BOINCKeychainItem
// Keychain Services will only allow one address for each kind of keychain item (the kind is kBOINCKeychainKind == "BOINC host password")
// -setAddress: will do nothing if the newAddress is nil or an empty string
// this is stored in the Service attribute (kSecServiceItemAttr) of a SecKeychainItemRef (the Where field in Keychain.app)
- (NSString *)address;
- (void)setAddress:(NSString *)newAddress;


// this is a user supplied password or nil if the user wants to be asked for the password each time we connect
// do not store the returned password, re-read it each time you need it
// if -isPasswordInKeychain returns NO then ask the user for the password or read the local password file if the host is local host
- (NSString *)password;
- (void)setPassword:(NSString *)newPassword;
- (BOOL)isPasswordInKeychain;


// this is the date the keychain item was last modified in the users Keychain
// read only
// the ModDate attribute (kSecModDateItemAttr) of a SecKeychainItemRef
- (NSDate *)modifiedDate;


// when a new BOINCKeychainItem is created, this will be set to YES if there was already a keychain item with the
// same address and kind (kBOINCKeychainKind)
// get rid of the duplicate and either find the original in the client manager or ask the user to supply a different address
- (BOOL)isDuplicate;


@end
