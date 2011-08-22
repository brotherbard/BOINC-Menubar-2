//
//  BOINCKeychainItem.m
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


#import "BOINCKeychainItem.h"
#import "BOINCKeychain.h"



@interface BOINCKeychainItem()

@end



////////////////////////////////////////////////////////////////////////////////////
@implementation BOINCKeychainItem


#pragma mark inits

// Don't use init!!!!
- (id)init
{
    NSAssert(NO, @"BOINCKeychainItem cannot be initialized with init.  Use initWithKeychainItemRef: or initPassword:forAddress:withName:");
    
    [self release];
    return nil;
}


- (id)initWithKeychainItem:(SecKeychainItemRef)keychainItem
{
    self = [super init];
    if (!self) return nil;
    
    if (!keychainItem) {
        [self release];
        return nil;
    }
    
    CFRetain(keychainItem);
    _keychainItem = keychainItem;
    
    return self;
}


- (id)initWithPassword:(NSString *)newPassword address:(NSString *)newAddress name:(NSString *)newName
{
    self = [super init];
    if (!self) return nil;
    
    BOINCKeychain *keychain = [BOINCKeychain defaultKeychain];
    
    _keychainItem = [keychain keychainItemWithPassword:newPassword forAddress:newAddress name:newName];
    if ([keychain lastError]) {
        _error = [keychain lastError];
        _keychainItem = nil; // this should be nil already, but just in case
        
        if (_error == errSecDuplicateItem) 
            _isDuplicate = YES;
    }
    
    return self;
}


- (void)dealloc
{    
    if (_keychainItem)
        CFRelease(_keychainItem);
    
    [_uuid         release], _uuid = nil;
    [_name         release], _name = nil;
    [_address      release], _address = nil;
    [_modifiedDate release], _modifiedDate = nil;
    
    [super dealloc];
}


// can't delete the keychain item in dealloc because there may be valid reasons for an app to release the BOINCKeychainItem
// without wanting to remove the item from the users Keychain
- (void)deleteKeychainItem
{
    _error = SecKeychainItemDelete(_keychainItem);
    
    if (_error != noErr)
        BBLog(@"SecKeychainItemDelete(%p) returned error %d.\n", _keychainItem, _error);
    
    CFRelease(_keychainItem);
    _keychainItem = NULL;
}


- (BOOL)isEqualToKeychainItemRef:(SecKeychainItemRef)itemRef
{
    return _keychainItem == itemRef;
}


- (void)reset
{
    [_uuid         release], _uuid = nil;
    [_name         release], _name = nil;
    [_address      release], _address = nil;
    [_modifiedDate release], _modifiedDate = nil;
    _hasSetIsPasswordInKeychain = NO;
    _error = 0;
}



#pragma mark Keychain Services calls
- (NSString *)stringForAttribute:(SecKeychainAttrType)attribute
{
    UInt32 format = kSecFormatUnknown;
    
    SecKeychainAttributeInfo info;
    info.count  = 1;
    info.tag    = &attribute;
    info.format = &format;
    
    SecKeychainAttributeList *list = NULL;
    _error = SecKeychainItemCopyAttributesAndData(_keychainItem, &info, NULL, &list, NULL, NULL);
    
    if ((_error != noErr) || (list == nil) || (list->count == 0)) {
        BBLog(@"failed to read attribute: %d  error: %d", attribute, _error);
        return nil;
    }
    
    NSString *string = [[NSString alloc] initWithBytes:list->attr->data length:list->attr->length encoding:NSASCIIStringEncoding];
    
    SecKeychainItemFreeAttributesAndData(list, NULL);
    
    return [string autorelease];
}


- (BOOL)setAttritbute:(SecKeychainAttrType)attribute withValue:(NSString *)value
{
    SecKeychainAttribute attr;
    attr.tag    = attribute;
    attr.length = (UInt32)[value lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    attr.data   = (void *)[value cStringUsingEncoding:NSUTF8StringEncoding];
    
    SecKeychainAttributeList list;
    list.count = 1;
    list.attr  = &attr;
    
    _error = SecKeychainItemModifyAttributesAndData(_keychainItem, &list, 0, NULL);
    
    if (_error != noErr) {
        BBLog(@"failed to set attribute: %d  withValue: %@  error: %d", attribute, value, _error);
        return NO;
    }
    
    return YES;
}


- (BOOL)getBOOLValue:(BOOL*)value forAttribute:(SecKeychainAttrType)attribute
{
    UInt32 format = kSecFormatUnknown;
    
    SecKeychainAttributeInfo info;
    info.count  = 1;
    info.tag    = &attribute;
    info.format = &format;
    
    SecKeychainAttributeList *list = NULL;
    _error = SecKeychainItemCopyAttributesAndData(_keychainItem, &info, NULL, &list, NULL, NULL);
    
    if ((_error != noErr) || (list == nil) || (list->count == 0)) {
        BBLog(@"failed to read attribute: %d  error: %d", attribute, _error);
        return NO;
    }
    
    // It's no until we say otherwise.
    // Note that a length of 0 for the returned attribute is perfectly valid, and means NO, so this is a suitable default.
    *value = NO;
    
    for (UInt32 i = 0; i < list->attr->length; ++i) {
        if (0 != ((char*)(list->attr->data))[i]) {
            *value = YES;
            break;
        }
    }
    
    SecKeychainItemFreeAttributesAndData(list, NULL);
    
    return YES;
}


- (BOOL)setBOOLAttritbute:(SecKeychainAttrType)attribute withValue:(BOOL)value
{
    SecKeychainAttribute attr;
    attr.tag    = attribute;
    attr.length = 1;
    attr.data   = &value;
    
    SecKeychainAttributeList list;
    list.count = 1;
    list.attr  = &attr;
    
    _error = SecKeychainItemModifyAttributesAndData(_keychainItem, &list, 0, NULL);
    
    if (_error != noErr) {
        BBLog(@"failed to set attribute: %d  withValue: %@  error: %d", attribute, value ? @"YES" : @"NO", _error);
        return NO;
    }
    
    return YES;
}


- (NSString *)getBOINCPassword
{
    UInt32 length = 0;
    char* buffer;
    
    _error = SecKeychainItemCopyAttributesAndData(_keychainItem, NULL, NULL, NULL, &length, (void**)&buffer);
    
    if (_error != noErr) {
        BBError(@"failed to get password from keychain for %@. error = %d", _name, _error);
        return nil;
    }
    
    if (length == 0)
        return nil;
    NSString *password = [[[NSString alloc] initWithBytesNoCopy:buffer length:length encoding:NSUTF8StringEncoding freeWhenDone:YES] autorelease];
    
    return password;
}


- (BOOL)setBOINCPassword:(NSString *)password
{
    if ([password isEqualToString:@""])
        password = nil;
    
    _error = SecKeychainItemModifyAttributesAndData(_keychainItem, 
                                                    NULL, 
                                                    (UInt32)[password lengthOfBytesUsingEncoding:NSUTF8StringEncoding], 
                                                    [password UTF8String]);
    if (_error != noErr) {
        BBError(@"failed to modify keychain for %@. error = %d", _name, _error);
        return NO;
    }
    
    return YES;
}


#pragma mark Attributes

- (OSStatus)lastError
{
    return _error;
}


- (NSString *)uuid
{
    if (!_uuid)
        _uuid = [[self stringForAttribute:kSecAccountItemAttr] retain];
    
    return _uuid;
}


- (NSString *)name
{
    if (!_name)
        _name = [[self stringForAttribute:kSecLabelItemAttr] retain];;
    
    return _name;
}


- (void)setName:(NSString *)newName
{
    if (![_name isEqualToString:newName] && [self setAttritbute:kSecLabelItemAttr withValue:newName]) {
        [_name release];
        _name = [newName copy];
    }
}


- (NSString *)address
{
    if (!_address)
        _address = [[self stringForAttribute:kSecServiceItemAttr] retain];
    
    return _address;
}


- (void)setAddress:(NSString *)newAddress
{
    if (!newAddress || [newAddress isEqualToString:@""])
        return;
    
    if (![_address isEqualToString:newAddress]) {
        if ([self setAttritbute:kSecServiceItemAttr withValue:newAddress]) {
            [_address release];
            _address = [newAddress copy];
        }
        else if (_error == errSecDuplicateItem)
            _isDuplicate = YES;
    }
}


// always read the password from the keychain
- (NSString *)password
{
    if ([self isPasswordInKeychain])
        return [self getBOINCPassword];
    
    return nil;
}


- (void)setPassword:(NSString *)newPassword
{
    if (newPassword) {
        _isPasswordInKeychain = YES;
        [self setBOINCPassword:newPassword];
    } else {
        _isPasswordInKeychain = NO;
        [self setBOINCPassword:@""];
    }
    
    [self setBOOLAttritbute:kSecNegativeItemAttr withValue:_isPasswordInKeychain];
}


// if the password is not valid then it is not stored in the Keychain, 
// so ask the participant or read from the local password file
- (BOOL)isPasswordInKeychain
{
    if (!_hasSetIsPasswordInKeychain)
        _hasSetIsPasswordInKeychain = [self getBOOLValue:&_isPasswordInKeychain forAttribute:kSecNegativeItemAttr];
    
    return _isPasswordInKeychain;
}


- (NSDate *)modifiedDate
{
    if (!_modifiedDate) {
        NSString *dateString = [self stringForAttribute:kSecModDateItemAttr];
        if (dateString) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            
            NSRange locationOfZ = [dateString rangeOfString:@"Z"];
            if (locationOfZ.location != NSNotFound)
                [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
            
            [formatter setDateFormat:@"yyyyMMddHHmmss"];
            _modifiedDate = [[formatter dateFromString:dateString] retain];
            
            [formatter release];
        }
    }
    
    return _modifiedDate;
}


- (BOOL)isDuplicate
{
    return _isDuplicate;
}



#pragma mark Misc


- (NSString *)description
{
    return [NSString stringWithFormat:@"Name = \"%@\" Address = \"%@\" Modified Date = \"%@\" UUID = \"%@\"", [self name], [self address], [self modifiedDate], [self uuid]];
}



@end
