//
//  BMBHostMenuController.m
//  BOINCMenubar
//
//  Created by BrotherBard on 3/29/09.
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

#import "BMBHostMenuController.h"

#import "BMBStatusMenuController.h"
#import "BMBProjectMenuController.h"
#import "BMBAttributeInfoView.h"
#import "BMBAttributeInfoStringCell.h"

#import "BOINCActiveClientManager.h"
#import "BOINCClientManager.h"
#import "BMBClientSortDescriptors.h"


// Private
@interface BMBHostMenuController ()
- (NSString *)hostTitle;
- (BMBProjectMenuController *)menuControllerForProject:(BOINCProject *)project;

// Adding items
- (void)addHostMenuItems;
- (void)addProjectMenuItems;
- (void)addHostListMenuItems;

// Removing items
- (void)removeHostMenuItems;
- (void)removeProjectMenuItems;
- (void)removeHostListMenuItems;

// Updating items
- (void)updateHostMenuItems;
- (void)updateHostInfoSubmenu;
- (void)updateNetworkAccessMenuItem;
- (void)updateSnoozeMenuItem;
- (void)updateAccountManagerMenuItem;
- (void)updateClientErrorMessage;
- (void)updateProjectMenus;
- (void)updateHostListSubmenu;

// Host Info Attributes
- (NSArray *)hostAttributeCells;
- (NSArray *)timeStatisticsAttributes;
- (NSArray *)networkStatisticsAttributes;
- (NSArray *)hostInformationAttributes;

// Sort Descriptiors
- (NSArray *)projectSortDescriptors;
- (NSDictionary *)projectSortDictionary;
@end



@implementation BMBHostMenuController


@synthesize host;
@synthesize sortedProjects;




// Set up factory defaults for the menu preferences.
+ (void)initialize
{
    if (self != [BMBHostMenuController class])
        return;
    
    NSNumber *totalHostCredit     = [NSNumber numberWithBool:YES];
    
    NSNumber *clientSortProperty  = [NSNumber numberWithInt:kClientNameTag];
    NSNumber *clientSortReversed  = [NSNumber numberWithBool:NO];
    
    NSNumber *projectSortProperty = [NSNumber numberWithInt:kTotalCreditTag];
    NSNumber *projectSortReversed = [NSNumber numberWithBool:NO];
    
    NSDictionary *defaults = [NSDictionary dictionaryWithObjectsAndKeys:
                              totalHostCredit,     kTotalHostCredit,
                              clientSortProperty,  kClientSortPropertyKey,
                              clientSortReversed,  kClientSortReversedKey,
                              projectSortProperty, kProjectSortPropertyKey,
                              projectSortReversed, kProjectSortReversedKey,
                              nil];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}




- (id)initWithClientManager:(BOINCActiveClientManager *)manager forMenu:(NSMenu *)menu
{
    self = [super init];
    if (!self) return nil;
    
    clientManager = manager; // weak ref
    statusMenu    = menu;    // weak ref
    projectMenuControllers = [[NSMutableArray alloc] init];
    
    
    hostTitleMenuItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"" action:NULL keyEquivalent:@""];
    
    
    hostListMenu = [[NSMenu allocWithZone:[NSMenu menuZone]] initWithTitle:@"HostListSubmenu"];
    [hostListMenu setDelegate:self];
    editHostMenuItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] 
                        initWithTitle:NSLocalizedString(@"Edit Hosts…", @"Edit Hosts… menu label")  
                        action:@selector(editHosts:) 
                        keyEquivalent:@""];
    [editHostMenuItem setTarget:[NSApp delegate]];
    [hostListMenu addItem:editHostMenuItem];
    [hostListMenu addItem:[NSMenuItem separatorItem]];
    [hostTitleMenuItem setSubmenu:hostListMenu];
    
    
    hostTotalCreditItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"" action:NULL keyEquivalent:@""];
    hostTotalCreditView = [[BMBAttributeInfoView alloc] initWithFrame:NSMakeRect(0, 0, 0, 0)];
    [hostTotalCreditItem setView:hostTotalCreditView];
    
    
    hostInfoItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"BOINC" action:NULL keyEquivalent:@""];
    [hostInfoItem setIndentationLevel:1];
    hostInfoSubmenu = [[NSMenu allocWithZone:[NSMenu menuZone]] initWithTitle:@"hostInfoSubmenu"];
    [hostInfoSubmenu setDelegate:self];
    [hostInfoItem setSubmenu:hostInfoSubmenu];
    hostInfoAttributesItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"" action:NULL keyEquivalent:@""];
    hostInfoView = [[BMBAttributeInfoView alloc] initWithFrame:NSMakeRect(0,0,0,0)];
    [hostInfoAttributesItem setView:hostInfoView];
    [hostInfoSubmenu addItem:hostInfoAttributesItem];
    [hostInfoSubmenu addItem:[NSMenuItem separatorItem]];
    NSMenuItem *copyHardwareItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] 
                                    initWithTitle:NSLocalizedString(@"Copy Hardware Support Info to Clipboard", @"Copy Hardware Support Info to Clipboard")
                                    action:@selector(copyHardwareData:) 
                                    keyEquivalent:@""];
    [copyHardwareItem setTarget:self];
    [hostInfoSubmenu addItem:copyHardwareItem];
    [copyHardwareItem release];
    
    
    snoozeMenuItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:NSLocalizedString(@"Snooze", @"Snooze menu label") 
                                                                          action:@selector(snooze:) 
                                                                   keyEquivalent:@""];
    [snoozeMenuItem setTarget:self];
    [snoozeMenuItem setIndentationLevel:1];
    
    
    networkAccessMenuItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] 
                             initWithTitle:NSLocalizedString(@"Suspend Network Access", @"Suspend Network Access menu label") 
                             action:@selector(networkAccess:) 
                             keyEquivalent:@""];
    [networkAccessMenuItem setTarget:self];
    [networkAccessMenuItem setIndentationLevel:1];
    
    
    accountManagerMenuItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"" 
                                                                                  action:@selector(syncAccountManager:) 
                                                                           keyEquivalent:@""];
    [accountManagerMenuItem setTarget:self];
    [accountManagerMenuItem setIndentationLevel:1];
    
    
    activityWindowMenuItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] 
                              initWithTitle:NSLocalizedString(@"Open Activity Window", @"Open Activity Window menu label")
                              action:@selector(openActivityWindow:) 
                              keyEquivalent:@""];
    [activityWindowMenuItem setTarget:self];
    [activityWindowMenuItem setIndentationLevel:1];
    
    
    projectSeperatorMenuItem = [[NSMenuItem separatorItem] retain];
    [projectSeperatorMenuItem setTag:kProjectMenuStartTag];
    
    
    clientErrorMessageMenuItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@""
                                                                                      action:@selector(selectHost:) 
                                                                               keyEquivalent:@""];
    [clientErrorMessageMenuItem setTarget:self];
    
    noProjectsMenuItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] 
                          initWithTitle:NSLocalizedString(@"Get Started by Joining a Project…", @"Get Started by Joining a Project… menu label when there are no projects")
                          action:@selector(joinNewProject:) 
                          keyEquivalent:@""];
    [noProjectsMenuItem setTarget:[NSApp delegate]];
    
    
    return self;
}


- (void)dealloc
{
    clientManager = nil;
    statusMenu    = nil;
    
    [projectMenuControllers     release];
	projectMenuControllers = nil;
    
    [hostTitleMenuItem          release];
    [hostTotalCreditItem        release];
    [snoozeMenuItem             release];
    [networkAccessMenuItem      release];
    [accountManagerMenuItem     release];
    
    [projectSeperatorMenuItem   release];
    
    [clientErrorMessageMenuItem release];
    [noProjectsMenuItem         release];
    
    [editHostMenuItem           release];
    
    [hostTotalCreditView        release];
    
    [super dealloc];
}



#pragma mark Updating the menu


- (void)updateForHost:(BOINCClient *)client hasMenuJustOpened:(BOOL)justOpened isMenuAtTop:(BOOL)menuAtTop
{
    if (justOpened || (host != client) || (!host.isConnected)) {
        BBLog(@"Menu just opened");
        
        [self removeHostMenuItems];
        
        if (![host isEqual:client] || !host.isConnected)
            [projectMenuControllers removeAllObjects];
        self.host = client;
        
        self.sortedProjects = [host.projects sortedArrayUsingDescriptors:[self projectSortDescriptors]];
    }
    
    isHostMenuAtTop = menuAtTop;
    
    if (!areHostsItemsInMenu)
        [self addHostMenuItems];
    
    [self updateHostMenuItems];
}




#pragma mark Host Menu actions 
// for the host menu items

// snooze is 1 hour
// set the menuitem's on/off state here so that it won't flash when the menu is opened next
- (IBAction)snooze:(id)sender
{
    if (host.ccStatus.taskMode == kRunModeNever) {
        [host setClientRunMode:kTagRunModeRestore withDuration:0.0];
        [snoozeMenuItem setState:NSOffState];
    } else {
        [host setClientRunMode:kTagRunModeNever withDuration:3600.0];
        [snoozeMenuItem setState:NSOnState];
    }
}


//  I just want to have the network turned ON or OFF, but BOINC has two ON modes: 
//     1) always on
//     2) auto (on or off based on user activity)
//  So BMB would have to save the current ON state and restore it afterwards (and hopefully it would not have 
//  changed in the mean time).
//  However if it is set to off with a duration then the BOINC core client will toggle it back to whatever ON
//  mode it was before so... set the delay very large (1,000 hours), that way the user gets to turn it off (and
//  it will stay off for a reasonable time) but the state can be restored easily. (Note: it has not been tested
//  that the network will reactivate properly after the 41 days 16 hours :-)
- (IBAction)networkAccess:(id)sender
{
    if (host.ccStatus.networkMode == kRunModeNever)
        [host setClientNetworkMode:kTagRunModeRestore withDuration:0.0];
    else 
        [host setClientNetworkMode:kTagRunModeNever withDuration:3600000.0];
}


- (IBAction)showHost:(id)sender
{
    // show the host info when the user selects the host in the main menu ???
}


//  action when selecting a host in the host submenu
- (void)selectHost:(id)sender
{
    [clientManager connectToClientByUUID:[sender representedObject]];
}


- (void)syncAccountManager:(id)sender
{
    [host performAccountManagerSynchronizeForTarget:self callbackSelector:NULL];
}


- (void)copyHardwareData:(id)sender
{
    NSMutableString *data = [NSMutableString string];
    
    [data appendFormat:@"BOINC Version: %@\n", host.version.versionString];
    
	BOINCHostInfo *hostInfo = host.hostInfo;
    
    [data appendFormat:@"Operating System: %@\n", hostInfo.operatingSystemName];
    [data appendFormat:@"System Version: %@\n",   hostInfo.operatingSystemVersion];
    [data appendFormat:@"CPU Vender: %@\n",       hostInfo.cpuVender];
    [data appendFormat:@"CPU Model: %@\n",        hostInfo.cpuModel];
    [data appendFormat:@"CPU Features: %@\n",     hostInfo.cpuFeatures];
    [data appendFormat:@"CPU Count: %@\n",        hostInfo.cpuCountString];
    [data appendFormat:@"Memory: %@\n",           hostInfo.ramSizeString];
    [data appendFormat:@"Cache: %@\n",            hostInfo.ramCacheSizeString];
    [data appendFormat:@"Disk Size: %@\n",        hostInfo.diskSizeString];
    [data appendFormat:@"Free Space: %@\n",       hostInfo.diskFreeSpaceString];
    
    BBQLog(@"%@", data);
    
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
    [pasteboard setString:data forType:NSStringPboardType];
}


- (IBAction)openActivityWindow:(id)sender
{
    BBMark;
    //[host requestProjectStatisticsUpdate];
    
}



#pragma mark NSMenu delegate methods

- (void)menuNeedsUpdate:(NSMenu *)menu
{
    if (menu == hostInfoSubmenu) {
        hasUpdatedHostInfo = NO;
        isHostInfoMenuOpen = YES;
        [self updateHostInfoSubmenu];
    }
    
    if (menu == hostListMenu) {
        hasUpdatedHostList = NO;
        isHostListMenuOpen = YES;
        [self updateHostListSubmenu];
    }
}


- (void)menuDidClose:(NSMenu *)menu
{
    if (menu == hostInfoSubmenu)
        isHostInfoMenuOpen = NO;
    
    if (menu == hostListMenu)
        isHostListMenuOpen = NO;
}


// not a NSMenuDelegate method, from BMBStatusMenuController
- (void)mainMenuDidClose
{
    for (BMBProjectMenuController *controller in projectMenuControllers)
        [controller mainMenuDidClose];
}



#pragma mark Private methods

- (NSString *)hostTitle
{
    if (host) {
        // Example: "Host: This Computer (localhost)"
        return [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Host:", @"Host menu label"), host.fullName];
    }
    
    return NSLocalizedString(@"No Host Connected", @"No Host Connected menu label");
}


- (BMBProjectMenuController *)menuControllerForProject:(BOINCProject *)project
{
    for (BMBProjectMenuController *controller in projectMenuControllers)
        if ([controller.project hasSameURL:project.masterURL])
            return controller;
    
    return nil;
}



#pragma mark Adding items
- (void)addHostMenuItems
{
    if (areHostsItemsInMenu) {
        BBLog(@"Error: adding host menuitems for %@ when they are already in menu.", host.clientName);
        return;
    }
    
    NSInteger menuIndex = 0;
    if (!isHostMenuAtTop)
        menuIndex = [statusMenu numberOfItems];
    
    [statusMenu insertItem:hostTitleMenuItem        atIndex:menuIndex++];
    [statusMenu insertItem:hostTotalCreditItem      atIndex:menuIndex++];
    [statusMenu insertItem:hostInfoItem             atIndex:menuIndex++];
    [statusMenu insertItem:snoozeMenuItem           atIndex:menuIndex++];
    [statusMenu insertItem:networkAccessMenuItem    atIndex:menuIndex++];
    [statusMenu insertItem:accountManagerMenuItem   atIndex:menuIndex++];
#ifdef BBDebug
    [statusMenu insertItem:activityWindowMenuItem   atIndex:menuIndex++];
#endif
    [statusMenu insertItem:projectSeperatorMenuItem atIndex:menuIndex++];
    
    [statusMenu insertItem:clientErrorMessageMenuItem atIndex:menuIndex];
    [clientErrorMessageMenuItem setHidden:YES];
    
    [self addProjectMenuItems];
    
    areHostsItemsInMenu = YES;
}


- (void)addProjectMenuItems
{
    if (areProjectItemsInMenu) {
        BBLog(@"Error: adding project menuitems for %@ when they are already in menu.", host.clientName);
        return;
    }
    
    NSInteger menuIndex = [statusMenu indexOfItem:clientErrorMessageMenuItem];
    if (menuIndex == -1) {
        BBLog(@"Error: adding project menuitems for %@ and the error message item is not in the menu.", host.clientName);
        return;
    }
    
    [statusMenu insertItem:noProjectsMenuItem atIndex:menuIndex++];
    
    if (host.isConnected) {
        for (BOINCProject *project in self.sortedProjects) {
            BMBProjectMenuController *menuController = [self menuControllerForProject:project];
            if (menuController == nil) {
                // create new controller for project
                menuController = [BMBProjectMenuController menuControllerWithProject:project forClient:host];
                [projectMenuControllers addObject:menuController];
            }
            [menuController addMainProjectMenuItemsToMenu:statusMenu atIndex:menuIndex];
            menuIndex += [menuController numberOfMainProjectMenuItems];
        }
    }
    
    areProjectItemsInMenu = YES;
}


- (void)addHostListMenuItems
{
    // add a host menu item for each client
    NSArray *clients = [clientManager.clients sortedArrayUsingDescriptors:[[BMBClientSortDescriptors sharedClientSortDescriptors] clientSortDescriptors]];
    for (BOINCClient *client in clients) {
        NSMenuItem *hostItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:client.fullName action:@selector(selectHost:) keyEquivalent:@""];
        
        [hostItem setTarget:self];
        [hostItem setRepresentedObject:client.uuid];
        [hostItem setToolTip:[NSString stringWithFormat:NSLocalizedString(@"Change the status menu to show information for \"%@\"", @"The tooltip for the list of hosts the user has"), client.fullName]];
        
        [hostListMenu addItem:hostItem];
        [hostItem release];
    }
}


#pragma mark Removing items
- (void)removeHostMenuItems
{
    if (!areHostsItemsInMenu)
        return;
    
    [statusMenu removeItem:hostTitleMenuItem];
    [statusMenu removeItem:hostTotalCreditItem];
    [statusMenu removeItem:hostInfoItem];
    [statusMenu removeItem:snoozeMenuItem];
    [statusMenu removeItem:networkAccessMenuItem];
    [statusMenu removeItem:accountManagerMenuItem];
#ifdef BBDebug
    [statusMenu removeItem:activityWindowMenuItem];
#endif
    [statusMenu removeItem:projectSeperatorMenuItem];
    
    [statusMenu removeItem:clientErrorMessageMenuItem];
    
    [self removeProjectMenuItems];
    [self removeHostListMenuItems];
    
    areHostsItemsInMenu = NO;
    hasUpdatedHostInfo = NO;
}


- (void)removeProjectMenuItems
{
    if (!areProjectItemsInMenu)
        return;
    
    [statusMenu removeItem:noProjectsMenuItem];
    
    for (BOINCProject *project in self.sortedProjects)
        [[self menuControllerForProject:project] removeMainProjectMenuItems];
    
    areProjectItemsInMenu = NO;
}


- (void)removeHostListMenuItems
{
    while ([hostListMenu numberOfItems] > 2)
        [hostListMenu removeItemAtIndex:2];
}


#pragma mark Updating items

- (void)updateHostMenuItems
{
    [hostTitleMenuItem setTitle:[self hostTitle]];
    [hostTitleMenuItem setHidden:NO];
    
    [hostTotalCreditView setAttributeCells:[self hostAttributeCells]];
    [hostTotalCreditView setIndentLevel:1];
    [hostTotalCreditView calculateCellFrames];
    [statusMenu itemChanged:hostTotalCreditItem];
    
    [self updateClientErrorMessage];
    
    // ex: BOINC 6.6.20  >
    [hostInfoItem setTitle:[NSString stringWithFormat:@"BOINC %@", host.version.versionString]];
    [self updateHostInfoSubmenu];
    
    [self updateSnoozeMenuItem];
    
    [self updateNetworkAccessMenuItem];
    
    [self updateAccountManagerMenuItem];
    
    [self updateProjectMenus];
    
    [self updateHostListSubmenu];
}


- (void)updateHostInfoSubmenu
{
    // if the hostInfo doesn't exist yet don't show the menu
    if ((host.hostInfo == nil) || !host.isConnected) {
        [hostInfoItem setHidden:YES];
        return;
    }
    
    [hostInfoItem setHidden:NO];
    
    // just update once when the menu opens, none of the info changes often
    if (!isHostInfoMenuOpen || hasUpdatedHostInfo)
        return;
    
    // create cells of all the updated host information to display
    NSMutableArray *attributeCells = [NSMutableArray array];
    [attributeCells addObjectsFromArray:[self hostInformationAttributes]];
    [attributeCells addObjectsFromArray:[self networkStatisticsAttributes]];
    [attributeCells addObjectsFromArray:[self timeStatisticsAttributes]];
    
    // update the view with all the above cells
    [hostInfoView setAttributeCells:attributeCells];
    [hostInfoView calculateCellFrames];
    
    hasUpdatedHostInfo = YES;
}


- (void)updateNetworkAccessMenuItem
{   
    [networkAccessMenuItem setEnabled:YES];
    switch (host.ccStatus.networkMode) {
        case kRunModeAlways:
        case kRunModeAuto:
            [networkAccessMenuItem setTitle:NSLocalizedString(@"Suspend Network Access", @"Suspend Network Access menu label")];
            [networkAccessMenuItem setHidden:NO];
            return;
        case kRunModeNever:
            [networkAccessMenuItem setTitle:NSLocalizedString(@"Resume Network Access", @"Resume Network Access menu label")];
            [networkAccessMenuItem setHidden:NO];
            return;
        case 0:
            // means there is no ccStatus (not connected) or no active client
            [networkAccessMenuItem setEnabled:NO];
            [networkAccessMenuItem setHidden:YES];
            return;
        default:
            [networkAccessMenuItem setEnabled:NO];
            [networkAccessMenuItem setHidden:YES];
            BBError(@"[StatusMenuController updateNetworkAccessMenuItem:] unknown ccStatus.networkMode = %d", clientManager.activeClient.ccStatus.networkMode);
            return;
    }  
}


- (void)updateSnoozeMenuItem
{
    [snoozeMenuItem setState:NSOffState];
    
    if (host.isConnected) {
        [snoozeMenuItem setEnabled:YES];
        [snoozeMenuItem setHidden:NO];
        
        if (host.ccStatus.taskMode != kRunModeNever)
            return;
        
        if (host.ccStatus.taskModeDelay > 0.0)
            [snoozeMenuItem setState:NSOnState];
        else 
            [snoozeMenuItem setEnabled:NO];
    } else {
        [snoozeMenuItem setEnabled:NO];
        [snoozeMenuItem setHidden:YES];
    }
}


- (void)updateAccountManagerMenuItem
{
    if (host.isConnected && host.accountManager) {
        [accountManagerMenuItem setTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Synchronize with", @"menu title: Synchronize with <account manager name>"), host.accountManager.name]];
        [accountManagerMenuItem setHidden:NO];
    } else
        [accountManagerMenuItem setHidden:YES];
}


- (void)updateClientErrorMessage
{
    if (host.isConnected) {
        [clientErrorMessageMenuItem setHidden:YES];
        return;
    }
    
    [clientErrorMessageMenuItem setHidden:NO];
    [clientErrorMessageMenuItem setEnabled:NO];
    
    if (clientManager.activeClient == nil)
        [clientErrorMessageMenuItem setTitle:NSLocalizedString(@"No Connection", @"No Connection")];
    else {
        [clientErrorMessageMenuItem setTitle:host.connectionStatusDescription];
        
        if (clientManager.activeClient.connectionStatus == kStatusPasswordFailed) {
            [clientErrorMessageMenuItem setEnabled:YES];
            [clientErrorMessageMenuItem setRepresentedObject:clientManager.activeClient.uuid];
        }
    }
    
    [statusMenu itemChanged:clientErrorMessageMenuItem];
}


- (void)updateProjectMenus
{
    if (!host.isConnected) {
        [self removeProjectMenuItems];
        return;
    }
    
    if ([self.sortedProjects count] == 0) {
        [noProjectsMenuItem setHidden:NO];
        return;
    } else {
        [noProjectsMenuItem setHidden:YES];
    }
    
    NSInteger menuIndex = [statusMenu indexOfItemWithTag:kProjectMenuStartTag] + 1;
    double maxWidth = 0.0f;
    
    for (BOINCProject *project in self.sortedProjects) {
        BMBProjectMenuController *menuController = [self menuControllerForProject:project];
        
        if (menuController == nil) 
            continue;
        
        [menuController updateProjectMenuItems];
        
        // for lining up the credit/RAC attributes
        maxWidth = fmax(maxWidth, menuController.projectInfoView.maxCreditValueWidth);
        
        // if the sorting order has changed then the index may be different
        if ([statusMenu indexOfItem:menuController.projectMenuItem] != menuIndex)
            [menuController moveMainProjectMenuItemsToIndex:menuIndex];
        
        // step past the current project's menu items to get to the next project
        menuIndex += [menuController numberOfMainProjectMenuItems];
    }
    
    // make the columns for the credit/RAC attributes line up
    for (BMBProjectMenuController *menuController in projectMenuControllers) {
        [menuController updateProjectAttributesWithWidth:maxWidth];
    }
}


- (void)updateHostListSubmenu
{
    // just update once when the menu opens, none of the info changes often
    if (!isHostListMenuOpen || hasUpdatedHostList)
        return;
    
    if (([[hostListMenu itemArray] count] - 2) != [clientManager.clients count]) {
        [self removeHostListMenuItems];
        [self addHostListMenuItems];
    }
    
    for (BOINCClient *client in clientManager.clients) {
        if ([client isEqual:clientManager.activeClient] && client.isConnected)
            [[hostListMenu itemWithTitle:client.fullName] setState:NSOnState];
        else
            [[hostListMenu itemWithTitle:client.fullName] setState:NSOffState];
    }
    
    hasUpdatedHostList = YES;
}



#pragma mark Host Info Attributes
// I'm thinking that the attribute view should be moved to it's own view controller

// currently there is only one attribute, the host's total credit & RAC
- (NSArray *)hostAttributeCells
{
    if ((host.isConnected) && [[NSUserDefaults standardUserDefaults] boolForKey:kTotalHostCredit]) {
        NSString *creditLabel = NSLocalizedString(@"Total Credit:", @"Total Credit menu label");
        NSString *racLabel    = NSLocalizedString(@"RAC:", @"RAC menu label");
        
        BMBAttributeInfoCreditCell *creditCell = 
        [BMBAttributeInfoCreditCell cellWithCreditLabel:creditLabel 
                                               RACLabel:racLabel 
                                            creditValue:clientManager.activeClient.totalCredit 
                                               RACValue:clientManager.activeClient.totalRAC];
        
        return [NSArray arrayWithObject:creditCell];
    } 
    
    return nil;
}


- (NSArray *)timeStatisticsAttributes
{
    BOINCTimeStatistics *timeStats = host.timeStats;
    NSMutableArray *timeStatCells = [NSMutableArray array];
    
    // On Fraction: 12.3%
    [timeStatCells addObject:[BMBAttributeInfoStringCell cellWithLabel:NSLocalizedString(@"BOINC On:", @"") 
                                                                 value:timeStats.onFractionString]];
    
    // Active Fraction: 12.3%
    [timeStatCells addObject:[BMBAttributeInfoStringCell cellWithLabel:NSLocalizedString(@"BOINC Active:", @"") 
                                                                 value:timeStats.activeFractionString]];
    
    // Connected Fraction: 12.3%
    [timeStatCells addObject:[BMBAttributeInfoStringCell cellWithLabel:NSLocalizedString(@"BOINC Connected:", @"") 
                                                                 value:timeStats.connectedFractionString]];
    
	return timeStatCells;
}


- (NSArray *)networkStatisticsAttributes
{
	BOINCNetStatistics *netStats = host.netStats;
    NSMutableArray *netStatCells = [NSMutableArray array];
    
    // Upload Rate: 12.34 KB/sec
    [netStatCells addObject:[BMBAttributeInfoStringCell cellWithLabel:NSLocalizedString(@"Upload Rate:", @"") 
                                                                value:netStats.uploadBandwidthRateString]];
    
    // Upload Average: 12 MB/day
    if (netStats.uploadRecentAverageBytes > 0)
        [netStatCells addObject:[BMBAttributeInfoStringCell cellWithLabel:NSLocalizedString(@"Recent Average:", @"") 
                                                                    value:netStats.uploadRecentAverageBytesString]];
    
    // Download Rate: 12.34 KB/sec
    [netStatCells addObject:[BMBAttributeInfoStringCell cellWithLabel:NSLocalizedString(@"Download Rate:", @"") 
                                                                value:netStats.downloadBandwidthRateString]];
	
    // Download Average: 123 MB/day
    if (netStats.downloadRecentAverageBytes > 0)
        [netStatCells addObject:[BMBAttributeInfoStringCell cellWithLabel:NSLocalizedString(@"Recent Average:", @"") 
                                                                    value:netStats.downloadRecentAverageBytesString]];
    
    return netStatCells;
}


- (NSArray *)hostInformationAttributes
{
	BOINCHostInfo *hostInfo = host.hostInfo;
    NSMutableArray *attributeCells = [NSMutableArray array];
    
    // Operating System: Darwin 9.7.0
    // or
    // Operating System: Microsoft Windows Server 2008 
    //                   Enterprise x64 Editon
    //                   Service Pack 1
    //                   (06.00.6001.00)
    NSArray *osLines = hostInfo.operatingSystemDescriptionArray;
    NSString *label = NSLocalizedString(@"Operating System:", @"Operating System:");
    for (NSString *line in osLines) {
        line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([line isEqualToString:@""])
            continue;
        [attributeCells addObject:[BMBAttributeInfoStringCell cellWithLabel:label 
                                                                      value:line]];
        label = @""; // it is only needed the first time
    }
    
    // cpu_model example string == "Intel(R) Xeon(R) CPU 5150 @ 2.66GHz [x86 Family 6 Model 15 Stepping 6]"
    // CPUModel: Intel(R) Xeon(R) CPU 5150 @ 2.66GHz
    //           x86 Family 6 Model 15 Stepping 6
    NSArray *cpuModelLines = hostInfo.cpuModelDescriptionArray;
    if ([cpuModelLines count])
        [attributeCells addObject:[BMBAttributeInfoStringCell cellWithLabel:NSLocalizedString(@"CPU Model:", @"")
                                                                      value:[cpuModelLines objectAtIndex:0]]];
    if ([cpuModelLines count] > 1)
        [attributeCells addObject:[BMBAttributeInfoStringCell cellWithLabel:@"" 
                                                                      value:[cpuModelLines objectAtIndex:1]]];
    
    // CPU Count: 1
    [attributeCells addObject:[BMBAttributeInfoStringCell cellWithLabel:NSLocalizedString(@"CPU Count:", @"")
                                                                  value:hostInfo.cpuCountString]];
    
    // Memory: 1.23 GB
    [attributeCells addObject:[BMBAttributeInfoStringCell cellWithLabel:NSLocalizedString(@"Memory:", @"") 
                                                                  value:hostInfo.ramSizeString]];
    
    // BOINC doesn't read the cache size of many computers and puts 1000000.0 as a default value, which is just confusing 
    // to those of us who know their CPU's cache size, so if it's the default value just don't show it
    if ((0 < hostInfo.ramCacheSize) && (hostInfo.ramCacheSize < 999999.0) && (1000001.0 < hostInfo.ramCacheSize))
        [attributeCells addObject:[BMBAttributeInfoStringCell cellWithLabel:NSLocalizedString(@"Cache:", @"") 
                                                                      value:hostInfo.ramCacheSizeString]];
    
    // Disk Size: 1.23 TB (or GB or MB)
    [attributeCells addObject:[BMBAttributeInfoStringCell cellWithLabel:NSLocalizedString(@"Disk Size:", @"") 
                                                                  value:hostInfo.diskSizeString]];
    
    // Free Space: 1.23 TB (or GB or MB)
    [attributeCells addObject:[BMBAttributeInfoStringCell cellWithLabel:NSLocalizedString(@"Free Space:", @"") 
                                                                  value:hostInfo.diskFreeSpaceString]];
    
    // Integer Benchmark: 12,345.67 MIPS
    [attributeCells addObject:[BMBAttributeInfoStringCell cellWithLabel:NSLocalizedString(@"Integer Benchmark:", @"") 
                                                                  value:hostInfo.cpuIntOperationsString]];
    // Float Benchmark: 1,234.56 MFLOPS
    [attributeCells addObject:[BMBAttributeInfoStringCell cellWithLabel:NSLocalizedString(@"Float Benchmark:", @"") 
                                                                  value:hostInfo.cpuFloatOperationsString]];
    
	return attributeCells;
}



#pragma mark Sort Descriptors

- (NSArray *)projectSortDescriptors
{
    int  projectSortProperty = [[[NSUserDefaults standardUserDefaults] objectForKey:kProjectSortPropertyKey] intValue];
    BOOL projectSortReversed = [[NSUserDefaults standardUserDefaults] boolForKey:kProjectSortReversedKey];
    BOOL ascending;
    
    // by default:
    //   strings & dates should sort small to large (ex: a-z, first joined to recently joined)
    //   numbers from large to small (ex: largest credit to smallest credit)
    if ((projectSortProperty == kProjectNameTag) || (projectSortProperty == kDateJoinedTag))
        ascending = YES;
    else
        ascending = NO;
    // the sort order might be reversed
    ascending = projectSortReversed ? !ascending : ascending;
    
    // find the project's property key
    NSString *sortKey = [[self projectSortDictionary] objectForKey:[NSNumber numberWithInt:projectSortProperty]];
    // if there is an error then default to Total Credit
    if (sortKey == nil) {
        sortKey = @"userTotalCredit";
        projectSortProperty = kTotalCreditTag;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:projectSortProperty] forKey:kProjectSortPropertyKey];
    }
    
    // Strings use a different sort method so do projectName seperatly
    if (projectSortProperty == kProjectNameTag)
        return [NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"projectName" ascending:ascending selector:@selector(localizedCaseInsensitiveCompare:)] autorelease]];
    
    // use the projectName as a secondary sort for the other sort options (there is probably a better way to do this)
    NSSortDescriptor *projectNameSort = [[[NSSortDescriptor alloc] initWithKey:@"projectName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)] autorelease];
    
    // for running tasks: sort on both running tasks and task count
    if (projectSortProperty == kRunningTasksTag)
        return [NSArray arrayWithObjects:
                [[[NSSortDescriptor alloc] initWithKey:@"runningTaskCount" ascending:ascending] autorelease],
                [[[NSSortDescriptor alloc] initWithKey:@"taskCount"        ascending:ascending] autorelease],
                projectNameSort,
                nil];
    
    // for task count: sort on both task count and running tasks
    if (projectSortProperty == kTotalTasksTag)
        return [NSArray arrayWithObjects:
                [[[NSSortDescriptor alloc] initWithKey:@"taskCount"        ascending:ascending] autorelease], 
                [[[NSSortDescriptor alloc] initWithKey:@"runningTaskCount" ascending:ascending] autorelease],
                projectNameSort,
                nil];
    
    // the rest use the default (compare:) selector
    return [NSArray arrayWithObjects:
            [[[NSSortDescriptor alloc] initWithKey:sortKey ascending:ascending] autorelease],
            projectNameSort,
            nil];
}


- (NSDictionary *)projectSortDictionary
{
    if (projectSortDictionary == nil)
        projectSortDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"userTotalCredit",       [NSNumber numberWithInt:kTotalCreditTag],
                                 @"userRAC",               [NSNumber numberWithInt:kTotalRACTag],
                                 @"hostTotalCredit",       [NSNumber numberWithInt:kHostCreditTag],
                                 @"hostRAC",               [NSNumber numberWithInt:kHostRACTag],
                                 @"projectName",           [NSNumber numberWithInt:kProjectNameTag],
                                 @"taskCount",             [NSNumber numberWithInt:kTotalTasksTag],
                                 @"runningTaskCount",      [NSNumber numberWithInt:kRunningTasksTag],
                                 @"remainingTimeEstimate", [NSNumber numberWithInt:kTotalTimeEstimateTag],
                                 @"resourceShare",         [NSNumber numberWithInt:kResourceShareTag],
                                 @"userCreateTime",        [NSNumber numberWithInt:kDateJoinedTag],
                                 nil];
    return projectSortDictionary;
}



@end
