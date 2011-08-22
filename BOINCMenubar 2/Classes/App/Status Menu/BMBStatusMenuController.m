//
//  BMBStatusMenuController.m
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

#import "BMBStatusMenuController.h"
#import "BMBAppController.h"
#import "BOINCActiveClientManager.h"
#import "BOINCClientManager.h"

#import "BMBHostMenuController.h"



// Private
@interface BMBStatusMenuController ()
- (void)removeObservers;
- (BOOL)shouldHostMenuMove;
- (void)updateStatusMenu;
- (void)updateStatusIcon;
@end




#pragma mark -

// TODO: show connection status when waiting for connection

#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BMBStatusMenuController


@synthesize statusMenu;
@synthesize aboutMenuItem;
@synthesize helpMenuItem;
@synthesize preferencesMenuItem;
@synthesize joinNewProjectMenuItem;
@synthesize quitMenuItem;
@synthesize hostSeperatorMenuItem;



// Set up factory defaults for the menu preferences.
+ (void)initialize
{
    if (self != [BMBStatusMenuController class])
        return;
	
    NSNumber *networkActivityIndicator = [NSNumber numberWithBool:NO];
    
    NSNumber *hostMenuAtTop       = [NSNumber numberWithBool:YES];
    
    NSDictionary *defaults = [NSDictionary dictionaryWithObjectsAndKeys:
                              networkActivityIndicator, kNetworkActivityIndicator,
                              hostMenuAtTop,       kHostMenuAtTop,
                              nil];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}


- (id)initWithClientManager:(id)manager
{
    self = [super init];
    if (!self) return nil;
    
    clientManager = manager; // weak ref
    
    // load the images used for the status menu icons
    statusMenuActiveImage          = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BOINCIconActive" 
                                                                                                             ofType:@"tif"]];
    statusMenuInactiveImage        = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BOINCIconOff" 
                                                                                                             ofType:@"tif"]];
    statusMenuNetworkActivityImage = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BOINCIconWithNetwork" 
                                                                                                             ofType:@"tif"]];
    
    // create the status menu
    statusMenuItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:30.0f] retain];
    if (![NSBundle loadNibNamed:@"BMBStatusMenu" owner:self]) {
        BBLog(@"[StatusMenuController init] Failed to load BMBStatusMenu.xib");
        return nil;
    }
    // One quirk of NIB/XIB's is that when you load them all the "top level objects" are retained an extra time
    // so I need to release them an extra time, might as well do it right away
    [statusMenu release];
    
    [statusMenuItem setImage:statusMenuInactiveImage];
    [statusMenuItem setHighlightMode:YES];
    [statusMenuItem setMenu:statusMenu];
    [statusMenuItem setToolTip:@"BOINCMenubar 2"];
    
    hostMenuController = [[BMBHostMenuController alloc] initWithClientManager:clientManager forMenu:statusMenu];
    isHostMenuAtTop    = -1;
    
    return self;
}


- (void)dealloc
{
    [self removeObservers];
    clientManager = nil;
    
    [statusMenuItem                 release];
    [statusMenuActiveImage          release];
    [statusMenuInactiveImage        release];
    [statusMenuNetworkActivityImage release];
    
    [statusMenu                     release];
    [aboutMenuItem                  release];
    [helpMenuItem                   release];
    [preferencesMenuItem            release];
    [joinNewProjectMenuItem         release];
    [quitMenuItem                   release];
    [hostSeperatorMenuItem          release];
    
    [hostMenuController             release];
    
    [super dealloc];
}


- (void)awakeFromNib
{
    [self observeActiveClient];
    
    // this will run all the time
/*    [[NSRunLoop currentRunLoop] addTimer:[NSTimer timerWithTimeInterval:1.0f 
                                                                 target:self 
                                                               selector:@selector(updateActiveClientStatus:) 
                                                               userInfo:nil 
                                                                repeats:YES] 
                                 forMode:NSRunLoopCommonModes];
*/
    // this will run only when the menu is open (because of the run loop mode)
    [[NSRunLoop currentRunLoop] addTimer:[NSTimer timerWithTimeInterval:1.1f 
                                                                 target:self 
                                                               selector:@selector(updateProjectsAndTasks:)
                                                               userInfo:nil 
                                                                repeats:YES] 
                                 forMode:NSEventTrackingRunLoopMode];
}


// run by the timer
// updates the core client status to keep network/snooze/suspension and other status info up to date
- (void)updateActiveClientStatus:(NSTimer *)timer
{
    if (clientManager.activeClient.isConnected)
        [clientManager.activeClient requestCCStatusUpdate];
}


- (void)updateProjectsAndTasks:(NSTimer *)timer
{
    if (clientManager.activeClient.isConnected)
        [clientManager.activeClient requestProjectsAndTasksUpdate];
}



/*
 only needed if using an NSView as the status image (which I should change it to)
 - (void)handleMouseDown
 {
 [_statusMenuItem popUpStatusItemMenu:statusMenu];
 }
 */



#pragma mark KVO methods

static const void *activeClientKVOContext;
static const void *ccStatusKVOContext;

- (void)observeActiveClient
{   
    [clientManager addObserver:self forKeyPath:@"activeClient.isConnected" options:NSKeyValueObservingOptionInitial context:&activeClientKVOContext];
    [clientManager addObserver:self forKeyPath:@"activeClient.connectionStatus" options:0 context:&activeClientKVOContext];
    [clientManager addObserver:self forKeyPath:@"activeClient.lastProjectsAndTasksUpdate" options:0 context:&activeClientKVOContext];
    [clientManager addObserver:self forKeyPath:@"activeClient.ccStatus" options:NSKeyValueObservingOptionInitial context:&ccStatusKVOContext];
}


- (void)removeObservers
{   
    [clientManager removeObserver:self forKeyPath:@"activeClient.isConnected"];
    [clientManager removeObserver:self forKeyPath:@"activeClient.connectionStatus"];
    [clientManager removeObserver:self forKeyPath:@"activeClient.lastProjectsAndTasksUpdate"];
    [clientManager removeObserver:self forKeyPath:@"activeClient.ccStatus"];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == &activeClientKVOContext) {
        // the active client changed, or changed it's connection status, or updated it's project info
        [self updateStatusMenu];
        return;
    }
    
    if (context == &ccStatusKVOContext) {
        // the active client's status has changed so update the menu icon
        [self updateStatusIcon];
        return;
    }
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}




#pragma mark NSMenu delegate methods

- (void)menuNeedsUpdate:(NSMenu *)menu
{
    isMenuOpen = YES;
    hasMenuJustOpened = YES;
    if (clientManager.activeClient.isConnected)
        [clientManager.activeClient requestProjectsAndTasksUpdate];
    else
        [self updateStatusMenu];
}


- (void)menuDidClose:(NSMenu *)menu
{
    isMenuOpen = NO;
    [hostMenuController mainMenuDidClose];
}



#pragma mark -
#pragma mark Private methods

- (BOOL)shouldHostMenuMove
{
    BOOL currentDefault = [[NSUserDefaults standardUserDefaults] boolForKey:kHostMenuAtTop];
    
    if (isHostMenuAtTop != currentDefault) {
        isHostMenuAtTop = currentDefault;
        return YES;
    }
    
    return NO;
}


// it's easier to move the application's menuitems than the host's menuitem's (mainly because there are a fixed number of them)
- (void)moveMenus
{
    [statusMenu removeItem:aboutMenuItem];
    [statusMenu removeItem:helpMenuItem];
    [statusMenu removeItem:preferencesMenuItem];
    [statusMenu removeItem:joinNewProjectMenuItem];
    [statusMenu removeItem:quitMenuItem];
    [statusMenu removeItem:hostSeperatorMenuItem];
    
    NSInteger menuIndex = 0;
    if (isHostMenuAtTop) {
        menuIndex = [statusMenu numberOfItems];
        [statusMenu insertItem:hostSeperatorMenuItem atIndex:menuIndex++];
        [hostSeperatorMenuItem setHidden:NO];
    }
    
    [statusMenu insertItem:aboutMenuItem          atIndex:menuIndex++];
    [statusMenu insertItem:helpMenuItem           atIndex:menuIndex++];
    [statusMenu insertItem:preferencesMenuItem    atIndex:menuIndex++];
    [statusMenu insertItem:joinNewProjectMenuItem atIndex:menuIndex++];
    [statusMenu insertItem:quitMenuItem           atIndex:menuIndex++];
    
    if (!isHostMenuAtTop) {
        [statusMenu insertItem:hostSeperatorMenuItem atIndex:menuIndex];
        [hostSeperatorMenuItem setHidden:NO];
    }
}


- (void)updateStatusMenu
{
    if (!isMenuOpen && hasHostMenuBeenCreated)
        return;
    
    if ([self shouldHostMenuMove])
        [self moveMenus];
    
    [hostMenuController updateForHost:clientManager.activeClient
                    hasMenuJustOpened:hasMenuJustOpened
                          isMenuAtTop:isHostMenuAtTop];
    
    hasMenuJustOpened = NO;
    hasHostMenuBeenCreated = YES;
}


- (void)updateStatusIcon
{
    if (clientManager.activeClient == nil) {
        [statusMenuItem setImage:statusMenuInactiveImage];
        [statusMenuItem setToolTip:NSLocalizedString(@"BOINCMenubar: No host connected", @"No host connected")];
        return;
    }
    
    NSString *hostLabel = [NSString stringWithFormat:@"BOINCMenubar: %@", clientManager.activeClient.fullName];
    
    if (clientManager.activeClient.isConnected == NO) {
        [statusMenuItem setImage:statusMenuInactiveImage];
        [statusMenuItem setToolTip:[NSString stringWithFormat:@"%@\n%@", hostLabel, NSLocalizedString(@"Host not connected", @"The host is not connected")]];
        return;
    }
    
    int taskSuspendReason = clientManager.activeClient.ccStatus.taskSuspendReason;
    if (taskSuspendReason
        && (taskSuspendReason != kBOINCSuspendReasonCPUUsageLimit)
        && (taskSuspendReason != kBOINCSuspendReasonInitialDelay)) {
        [statusMenuItem setImage:statusMenuInactiveImage];
        [statusMenuItem setToolTip:[NSString stringWithFormat:@"%@\n%@ %@", hostLabel, NSLocalizedString(@"Suspended:", @"Suspended label"), clientManager.activeClient.ccStatus.taskSuspendedReasonDescription]];
        return;
    }
    
    [statusMenuItem setToolTip:hostLabel];
    
    if ((clientManager.activeClient.ccStatus.networkStatus == kNetworkStatusOnline) && [[NSUserDefaults standardUserDefaults] boolForKey:kNetworkActivityIndicator])
        [statusMenuItem setImage:statusMenuNetworkActivityImage];
    else 
        [statusMenuItem setImage:statusMenuActiveImage];
}



@end
