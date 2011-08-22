//
//  BBLoginItems.m
//
//  Created by BrotherBard on 4/18/09.
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

#import "BBAppSessionLoginState.h"

// Private
@interface BBAppSessionLoginState()
@property (readwrite, assign) BOOL isAppInSessionLoginList;

- (LSSharedFileListItemRef)copyItemRefForApp;
- (void)updateLoginItemState;

@end



@implementation BBAppSessionLoginState



static void SharedFileListChanged(LSSharedFileListRef list, void *context)
{
    static UInt32 previousSeed = 0;
    
    // there are other types of lists, so make sure we are just looking at the Session Login list
    // the context is the _sessionLoginItemsList that I set in the init method
    if (list == (LSSharedFileListRef)context) {
        UInt32 seed = LSSharedFileListGetSeedValue(list);
        if (seed > previousSeed) {
            [[BBAppSessionLoginState sharedController] updateLoginItemState];
            previousSeed = seed;
        }
    }
}




@synthesize isAppInSessionLoginList;

static BBAppSessionLoginState *sharedController = nil;

+ (id)sharedController
{
    if (sharedController == nil)
        sharedController = [[self alloc] init];
    
    return sharedController;
}


- (id)init
{
    self = [super init];
    if(!self) return nil;
    
    _sessionLoginItemsList = LSSharedFileListCreate(kCFAllocatorDefault,                // inAllocator
                                                    kLSSharedFileListSessionLoginItems, // inListType
                                                    NULL);                              // listOptions
    
    if(!_sessionLoginItemsList) {
        [self release];
        self = nil;
        return nil;
    } 
    
    LSSharedFileListAddObserver(_sessionLoginItemsList,                 // inList
                                [[NSRunLoop mainRunLoop] getCFRunLoop], // inRunloop
                                kCFRunLoopDefaultMode,                  // inRunloopMode
                                SharedFileListChanged,                  // callback
                                _sessionLoginItemsList);                // context
    
    _appPath    = [[NSBundle mainBundle] bundlePath];
    _lastUpdate = [[NSDate distantPast] copy];
    
    // perform this selector after init
    [self performSelector:@selector(updateLoginItemState) withObject:nil afterDelay:0.0];
    
    return self;
}


- (void)dealloc
{
    if (_sessionLoginItemsList) {
        LSSharedFileListRemoveObserver(_sessionLoginItemsList,                 // inList
                                       [[NSRunLoop mainRunLoop] getCFRunLoop], // inRunloop
                                       kCFRunLoopDefaultMode,                  // inRunloopMode
                                       SharedFileListChanged,                  // callback
                                       _sessionLoginItemsList);                // context
        
        CFRelease(_sessionLoginItemsList);
        _sessionLoginItemsList = NULL;
    }
    
    [_lastUpdate release];
    
    [super dealloc];
}


- (LSSharedFileListItemRef)copyItemRefForApp
{
    UInt32 seed = 0;
    NSArray *items = (NSArray *)LSSharedFileListCopySnapshot(_sessionLoginItemsList, &seed);
    
    for (id item in items) {
        LSSharedFileListItemRef itemRef = (LSSharedFileListItemRef)item;
        
        OSStatus status = noErr;
        CFURLRef theURL = NULL;
        status = LSSharedFileListItemResolve(itemRef,                            // inItem
                                             kLSSharedFileListNoUserInteraction, // inFlags
                                             &theURL,                            // outURL
                                             NULL);                              // outFSRef
        
        if ((status == noErr) && theURL) {
            if ([_appPath isEqualToString:[(NSURL *)theURL path]]) {
                CFRelease(theURL);
                CFRetain(itemRef);
                [items release];
                return itemRef;
            }
        } else if (status) {
            BBLog(@"There was an error in LSSharedFileListItemResolve = %d", status);
        }
        if (theURL)
            CFRelease(theURL);
    }
    
    if (items) {
        BBLog(@"releasing items");
        [items release];
        BBLog(@"items released");
    }
    
    return NULL;
}


// Calling LSSharedFileListItemResolve (in copyItemRefForApp) can cause a large number of SharedFileListChanged() 
// callbacks (which calls updateLoginItemState). So limit how often we can call copyItemRefForApp from here.
// Other methods still need to be able to call copyItemRefForApp directly.
// This is due to a bug in the LSSharedFileList API. For unknown reasons it does not manifest on all machines. 
// http://www.cocoabuilder.com/archive/message/cocoa/2008/10/27/221099
- (void)updateLoginItemState
{
    if ([[NSDate date] timeIntervalSinceDate:_lastUpdate] < 0.1) 
        return;
    
    LSSharedFileListItemRef itemRef = [self copyItemRefForApp];
    BOOL currentState = NO;
    if (itemRef) {
        currentState = YES;
        CFRelease(itemRef);
    }
    
    if (isAppInSessionLoginList != currentState)
        self.isAppInSessionLoginList = currentState;
    
    [_lastUpdate release];
    _lastUpdate = [[NSDate date] retain];
}


- (void)toggleAppSessionLoginListState
{
    if (isAppInSessionLoginList)
        [self removeAppFromSessionLoginList];
    else
        [self addAppToSessionLoginList];
}


- (void)setAppSessionLoginListState:(BOOL)state
{
    if (state)
        [self addAppToSessionLoginList];
    else
        [self removeAppFromSessionLoginList];
}


- (void)removeAppFromSessionLoginList
{
    LSSharedFileListItemRef itemRef = [self copyItemRefForApp];
    
    if (itemRef) {
        OSStatus error = LSSharedFileListItemRemove(_sessionLoginItemsList, itemRef);
        if (error != noErr)
            BBError(@"Failed to remove App from Session Login Items");
        
        CFRelease(itemRef);
    }
    
    [self updateLoginItemState];
}


- (void)addAppToSessionLoginList
{
    LSSharedFileListItemRef itemRef = [self copyItemRefForApp];
    
    if (itemRef == NULL) {
        // I believe the default is to not Hide the app, but I'm not really sure because the 
        // kLSSharedFileListItemHidden property is not read corretly by LSSharedFileListItemCopyProperty.
        // I'm just setting it here to have a known default value.
        NSDictionary* propertiesToSet = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                                    forKey:(id)kLSSharedFileListItemHidden];
        NSURL *url = [NSURL fileURLWithPath:_appPath];
        BBLog(@"%@", url);
        
        itemRef = LSSharedFileListInsertItemURL(_sessionLoginItemsList,           // inList
                                                kLSSharedFileListItemLast,        // insertAfterThisItem
                                                NULL,                             // inDisplayName - NULL = will use app name
                                                NULL,                             // inIconRef     - NULL = will use app icon
                                                (CFURLRef)url,                    // inURL
                                                (CFDictionaryRef)propertiesToSet, // inPropertiesToSet
                                                NULL);                            // inPropertiesToClear
        
        if (itemRef == NULL)
            BBError(@"Failed to add App to Session Login Items");
    }
    
    if (itemRef)
        CFRelease(itemRef);
    
    [self updateLoginItemState];
}


@end
