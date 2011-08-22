//
//  BMBStatusMenuController.h
//  BOINCMenubar
//
//  Created by BrotherBard on 3/29/08.
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


// for User Defaults
#define kNetworkActivityIndicator @"NetworkActivityIndicator"
#define kHostMenuAtTop            @"HostMenuAtTop"


@class BOINCActiveClientManager;
@class BMBHostMenuController;
 


@interface BMBStatusMenuController : NSObject
{
    BOINCActiveClientManager *clientManager;
    
    NSStatusItem             *statusMenuItem;
    NSImage                  *statusMenuActiveImage;
    NSImage                  *statusMenuInactiveImage;
    NSImage                  *statusMenuNetworkActivityImage;
    
    // main menu
    NSMenu                   *statusMenu;
    NSMenuItem               *aboutMenuItem;
    NSMenuItem               *helpMenuItem;
    NSMenuItem               *preferencesMenuItem;
    NSMenuItem               *joinNewProjectMenuItem;
    NSMenuItem               *quitMenuItem;
    NSMenuItem               *hostSeperatorMenuItem;
    
    BMBHostMenuController    *hostMenuController;
    
    BOOL                      isHostMenuAtTop;
    BOOL                      isMenuOpen;
    BOOL                      hasMenuJustOpened;
    BOOL                      hasHostMenuBeenCreated;
}
@property (nonatomic, retain) IBOutlet NSMenu     *statusMenu;
@property (nonatomic, retain) IBOutlet NSMenuItem *aboutMenuItem;
@property (nonatomic, retain) IBOutlet NSMenuItem *helpMenuItem;
@property (nonatomic, retain) IBOutlet NSMenuItem *preferencesMenuItem;
@property (nonatomic, retain) IBOutlet NSMenuItem *joinNewProjectMenuItem;
@property (nonatomic, retain) IBOutlet NSMenuItem *quitMenuItem;
@property (nonatomic, retain) IBOutlet NSMenuItem *hostSeperatorMenuItem;

// Public methods
- (id)initWithClientManager:(id)manager;
- (void)observeActiveClient;
//- (void)handleMouseDown; // not needed???


@end
