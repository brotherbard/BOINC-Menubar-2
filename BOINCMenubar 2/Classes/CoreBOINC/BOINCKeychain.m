//
//  BOINCKeychain.m
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


#import "BOINCKeychain.h"
#import "BOINCKeychainItem.h"
#import "BOINCClientManager.h"


NSString *kBOINCKeychainFilenameKey = @"BOINCKeychainFilename";
NSString *kBMBDefaultKeychainFile   = @"BMBDefaultKeychainFile";
NSString *kKeychainExtension        = @"keychain";
NSString *kBOINCKeychainAccount     = @"BOINC";
NSString *kBOINCKeychainKind        = @"BOINC host password";


@interface BOINCKeychain()
- (id)initWithClientManager:(BOINCClientManager *)manager;
// pointer equality
- (BOOL)isEqualToKeychainRef:(SecKeychainRef)keychain;
- (void)newKeychainItem:(SecKeychainItemRef)item;
- (void)modifiedKeychainItem:(SecKeychainItemRef)item;
- (void)deletedKeychainItem:(SecKeychainItemRef)item;
@end


/////////////////////////////////////////////////////////////////////////////////////
@implementation BOINCKeychain


#pragma mark Keychain Event callback
//  When the user (or another process) changes something in the keychain this callback will be called.
//  Check to see if it's any of the BOINC related keychain items and update the items if it is.
//  An example would be if the user changes the Name field of a BOINC host password in Keychain.app.
//  Or there may be another BOINC manager type app that also uses these keychain items and the user 
//  changed the Name field in that app which updated the item in the Keychain.
OSStatus keychainEventCallback(SecKeychainEvent keychainEvent, SecKeychainCallbackInfo *callbackInfo, void *context)
{
    // is this the same keychain used for BOINC?
    if (![[BOINCKeychain defaultKeychain] isEqualToKeychainRef:callbackInfo->keychain])
        return noErr;
    
    //  is the keychain item a BOINC host password item?
    //  if the item is being deleted it is no longer valid, so we can't copy attributes from it
    SecKeychainItemRef item = callbackInfo->item;
    if (item && (keychainEvent != kSecDeleteEvent)) {
        UInt32 attribute = kSecDescriptionItemAttr;
        UInt32 format    = kSecFormatUnknown;
        
        SecKeychainAttributeInfo info;
        info.count  = 1;
        info.tag    = &attribute;
        info.format = &format;
        
        SecKeychainAttributeList *list = NULL;
        int error = SecKeychainItemCopyAttributesAndData(item, &info, NULL, &list, NULL, NULL);
        
        if ((error != noErr) || (list == nil) || (list->count == 0)) {
            BBLog(@"Failed to read attribute: %d  error: %d", attribute, error);
            return noErr;
        }
        
        NSString *string = [[[NSString alloc] initWithBytes:list->attr->data length:list->attr->length encoding:NSASCIIStringEncoding] autorelease];
        
        SecKeychainItemFreeAttributesAndData(list, NULL);
        
        if (![string isEqualToString:kBOINCKeychainKind])
            return noErr;
    }
    
    // dispatch the event
    switch (keychainEvent) {
        case kSecAddEvent: 
            // An item was added
            [[BOINCKeychain defaultKeychain] newKeychainItem:item];
            break;
        case kSecUpdateEvent: 
            // An item was changed 
            [[BOINCKeychain defaultKeychain] modifiedKeychainItem:item];
            break;
        case kSecDeleteEvent: 
            // An item was deleted
            // WARNING: item is not valid, only use it to check pointer equality
            [[BOINCKeychain defaultKeychain] deletedKeychainItem:item];
            break;
        default:
            BBLog(@"Unknown keychain event - id #%u (0x%x).", keychainEvent, keychainEvent);
    }
    
    return noErr;
}



#pragma mark BOINCKeychain

+ (void)initialize 
{
    if (self != [BOINCKeychain class])
        return;
    
    // setup user defaults
    NSDictionary *defaults = [NSDictionary dictionaryWithObjectsAndKeys:kBMBDefaultKeychainFile, kBOINCKeychainFilenameKey, nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}


// singleton instance
static BOINCKeychain *defaultBOINCKeychain;

+ (id)keychainWithClientManager:(BOINCClientManager *)manager
{
    if (!defaultBOINCKeychain) {
        defaultBOINCKeychain = [[BOINCKeychain alloc] initWithClientManager:manager];
        
        if (defaultBOINCKeychain) {
            // setup the keychain callback
            OSStatus err = SecKeychainAddCallback(keychainEventCallback, kSecAddEvent || kSecUpdateEvent || kSecDeleteEvent, NULL);
            if (err != noErr)
                BBLog(@"SecKeychainAddCallback(%p, %x [kSecAddEvent || kSecUpdateEvent || kSecDeleteEvent], NULL) returned error %d.", 
                      keychainEventCallback, kSecAddEvent || kSecUpdateEvent || kSecDeleteEvent, err);
        }
    }
    
    return defaultBOINCKeychain;
}


// until the keychain is init'd return nil
+ (BOINCKeychain *)defaultKeychain
{
    if (defaultBOINCKeychain)
        return defaultBOINCKeychain;
    
    return nil;
}



- (id)init
{
    NSAssert(NO, @"cannot use -init with BOINCKeychain");
    
    [self release], self = nil;
    return nil;
}


// NOTE: currently only supporting per user keychains (~/Library/Keychains/)
//
// There is a user default called "BOINCKeychainFilename" that can be used to set a keychain other than the users login keychain
// but it must still be in ~/Library/Keychains/. 

- (id)initWithClientManager:(BOINCClientManager *)manager
{   
    self = [super init];
    if (!self) return nil;
    
    clientManager = manager;
    
    // check the user default to find the name of the keychain file
    NSString *keychainName = [[NSUserDefaults standardUserDefaults] stringForKey:kBOINCKeychainFilenameKey];
    
    if ([keychainName isEqualToString:kBMBDefaultKeychainFile]) {
        // open the default keychain file
        _error = SecKeychainCopyDefault(&_keychain);
        //if (err == errSecNoDefaultKeychain) {
        // there is no default keychain, so create one
        // possibly because we are running in the iPhone simulator
        //} else 
        if (_error != noErr) {
            BBError(@"Opening the default Keychain failed. error = %d", _error);
            [self release];
            self = nil;
            return nil;
        }
    }
    else {
        // if user supplied filename, make sure the ".keychain" extension is there
        if (![[keychainName pathExtension] isEqualToString:kKeychainExtension])
            keychainName = [keychainName stringByAppendingPathExtension:kKeychainExtension];
        
        NSString *keychainPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Keychains"] stringByAppendingPathComponent:keychainName];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:keychainPath]) {
            // open an existing keychain file at keychainPath
            _error = SecKeychainOpen([keychainPath fileSystemRepresentation], &_keychain);
            if (_error != noErr) {
                BBError(@"Opening the Keychain at %@ failed. error = %d", keychainPath, _error);
                [self release];
                self = nil;
                return nil;
            }
        } else {
            // create a new keychain file at keychainPath
            // security framework will ask the user for a password
            _error = SecKeychainCreate([keychainPath fileSystemRepresentation], 0, NULL, true, NULL, &_keychain);
            if (_error != noErr) {
                BBError(@"Creating a Keychain at %@ failed. error = %d", keychainPath, _error);
                [self release];
                self = nil;
                return nil;
            }
        }
    }
    
    return self;
}    


- (void)dealloc
{
    if (_keychain)
        CFRelease(_keychain);
    clientManager = nil;
    
    [super dealloc];
}


- (OSStatus)lastError
{
    return _error;
}


- (BOOL)isEqualToKeychainRef:(SecKeychainRef)keychain
{
    return _keychain == keychain;
}


// there can only be one keychain instance with the same address in the keychain (should get the error: errSecDuplicateItem)
// --  if password is nil or empty it means "Ask Always" (or if localhost, read the local password file)
// --  the account attribute is used to store a UUID to help identify keychains (the user can change both the address and name)
// --  if name is nil or empty, use the address (note: the GUI does not currently allow a nil/empty name)
// --  returns nil on error
- (SecKeychainItemRef)keychainItemWithPassword:(NSString *)password forAddress:(NSString *)address name:(NSString *)name
{
    NSAssert(((address != nil) || ![address isEqualToString:@""]), @"address can't be nil");
    if ((address == nil) || [address isEqualToString:@""])
        return NULL;
    
    if ([password isEqualToString:@""])
        password = nil;
    
    BOOL hasPassword = (password != nil);
    BBLog(@"%@ = %@", password, hasPassword ? @"YES" : @"NO");
    
    if (!name || [name isEqualToString:@""])
        name = address;
    
    NSString *UUID = [[NSProcessInfo processInfo] globallyUniqueString];
    
    SecKeychainItemRef item;
    _error = SecKeychainAddGenericPassword(_keychain, 
                                           (UInt32)[address  lengthOfBytesUsingEncoding:NSUTF8StringEncoding], [address  UTF8String],
                                           (UInt32)[UUID     lengthOfBytesUsingEncoding:NSUTF8StringEncoding], [UUID     UTF8String],
                                           (UInt32)[password lengthOfBytesUsingEncoding:NSUTF8StringEncoding], [password UTF8String],
                                           &item);
    if (_error == errSecDuplicateItem) {
        // it already exists, don't do anything ???
    } else if (_error != noErr) {
        BBError(@"failed to create keychain for %@. error = %d", name, _error);
        return NULL;
    }
    
    uint attributeCount = 3;
    SecKeychainAttribute attr[attributeCount];
    
    attr[0].tag    = kSecLabelItemAttr;
    attr[0].length = (UInt32)[name lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    attr[0].data   = (void *)[name cStringUsingEncoding:NSUTF8StringEncoding];
    
    attr[1].tag    = kSecDescriptionItemAttr;
    attr[1].length = (UInt32)[kBOINCKeychainKind lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    attr[1].data   = (void *)[kBOINCKeychainKind cStringUsingEncoding:NSUTF8StringEncoding];
    
    attr[2].tag    = kSecNegativeItemAttr;
    attr[2].length = 1;
    attr[2].data   = &hasPassword;
    
    SecKeychainAttributeList list;
    list.count = attributeCount;
    list.attr  = attr;
    
    _error = SecKeychainItemModifyAttributesAndData(item, &list, 0, NULL);
    if (_error != noErr) {
        BBError(@"failed to modify attributes on keychain item. label = %@  type = %@  error = %d", name, kBOINCKeychainKind, _error);
        return NULL;
    }
    
    return item;
}



#pragma mark Search
- (BOINCKeychainItem *)findBOINCKeychainItemForAddress:(NSString *)address
{
    if (!address)
        return nil;
    
    SecKeychainAttribute attr[2];
    attr[0].tag    = kSecDescriptionItemAttr;
    attr[0].length = (UInt32)[kBOINCKeychainKind lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    attr[0].data   = (void *)[kBOINCKeychainKind cStringUsingEncoding:NSUTF8StringEncoding];
    
    attr[1].tag    = kSecServiceItemAttr;
    attr[1].length = (UInt32)[address lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    attr[1].data   = (void *)[address cStringUsingEncoding:NSUTF8StringEncoding];
    
    SecKeychainAttributeList list;
    list.count = 2;
    list.attr  = attr;
    
    SecKeychainSearchRef searchRef = NULL;
    _error = SecKeychainSearchCreateFromAttributes(_keychain, kSecGenericPasswordItemClass, &list, &searchRef);
    if ((_error != noErr) || (searchRef == NULL)) {
        BBLog(@"Failed to create search for BOINC keychain item");
        return nil;
    }
    
    SecKeychainItemRef currentItem = NULL;
    _error = SecKeychainSearchCopyNext(searchRef, &currentItem);
    if ((_error != noErr) || (currentItem == NULL)) {
        BBLog(@"Failed to find BOINC keychain item for: %@", address);
        CFRelease(searchRef);
        return nil;
    }
    
    BOINCKeychainItem *keychainItem = [[BOINCKeychainItem alloc] initWithKeychainItem:currentItem];
    
    CFRelease(currentItem);
    CFRelease(searchRef);
    
    return [keychainItem autorelease];
}


- (NSArray *)allBOINCKeychainItems
{
    SecKeychainAttribute attr;
    attr.tag    = kSecDescriptionItemAttr;
    attr.length = (UInt32)[kBOINCKeychainKind lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    attr.data   = (void *)[kBOINCKeychainKind cStringUsingEncoding:NSUTF8StringEncoding];
    
    SecKeychainAttributeList list;
    list.count = 1;
    list.attr  = &attr;
    
    SecKeychainSearchRef searchRef = NULL;
    _error = SecKeychainSearchCreateFromAttributes(_keychain, kSecGenericPasswordItemClass, &list, &searchRef);
    if ((_error != noErr) || (searchRef == NULL)) {
        BBLog(@"Failed to create search for all BOINC keychain items");
        return nil;
    }
    
    SecKeychainItemRef currentItem = NULL;
    NSMutableArray *keychainItems = [NSMutableArray array];
    while (((_error = SecKeychainSearchCopyNext(searchRef, &currentItem)) == 0) && currentItem) {
        [keychainItems addObject:[[[BOINCKeychainItem alloc] initWithKeychainItem:currentItem] autorelease]];
        CFRelease(currentItem);
    }
    CFRelease(searchRef);
    
    if ([keychainItems count] == 0) {
        BBLog(@"Failed to find any BOINC keychain items");
        return nil;
    }
    
    return keychainItems;
}



#pragma mark Keychain events
// methods to respond to the keychain callback events


- (void)newKeychainItem:(SecKeychainItemRef)item
{
    BOINCClient *client = nil;
    for (client in clientManager.clients)
        if ([client.hostKeychainItem isEqualToKeychainItemRef:item])
            break;
    
    if (!client) {
        BOINCKeychainItem *keychainItem = [[[BOINCKeychainItem alloc] initWithKeychainItem:item] autorelease];
        [clientManager addClientForKeychainItem:keychainItem];
        BBLog(@"Client has been added for host: %@", [keychainItem name]);
    }
}


- (void)modifiedKeychainItem:(SecKeychainItemRef)item
{
    for (BOINCClient *client in clientManager.clients)
        if ([client.hostKeychainItem isEqualToKeychainItemRef:item]) {
            BBLog(@"Client: %@  -- keychain item has been modified", client.fullName);
            [client.hostKeychainItem reset];
            break;
        }
}


// note that item is already dereferenced, so can't look at any of the item's attributes,
// can only compare the pointer address (which is what isEqualToKeychainItemRef: does)
- (void)deletedKeychainItem:(SecKeychainItemRef)item
{
    for (BOINCClient *client in clientManager.clients)
        if ([client.hostKeychainItem isEqualToKeychainItemRef:item]) {
            BBLog(@"Client: %@  -- keychain item has been deleted", client.fullName);
            [clientManager removeClient:client];
            break;
        }
}


@end
