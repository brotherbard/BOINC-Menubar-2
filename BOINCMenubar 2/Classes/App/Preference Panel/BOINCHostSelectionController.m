//
//  BOINCHostSelectionController.m
//  BOINCMenubar
//
//  Created by BrotherBard on 7/5/09.
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

#import "BOINCHostSelectionController.h"
#import "BMBClientSortDescriptors.h"
#import "BOINCActiveClientManager.h"
#import "BOINCClientManager.h"



@interface BOINCHostSelectionController()

- (id)initWithClientManager:(BOINCActiveClientManager *)manager;
- (void)removeHostListMenuItems;
- (void)updateHostListMenuItems;

@end



@implementation BOINCHostSelectionController


@synthesize hostPopUpButton;
@synthesize hostListMenu;



+ (BOINCHostSelectionController *)hostSelectionControllerWithClientManager:(BOINCActiveClientManager *)manager
{
    return [[[self alloc] initWithClientManager:manager] autorelease];
}


static const void *hostSelectionContext;

- (id)initWithClientManager:(BOINCActiveClientManager *)manager
{
    self = [super initWithNibName:@"BOINCHostSelectionView" bundle:nil];
    if (!self) return nil;
    
    clientManager = manager;
    
    [clientManager addObserver:self 
                    forKeyPath:@"clients" 
                       options:0 
                       context:&hostSelectionContext];
    [clientManager addObserver:self 
                    forKeyPath:@"activeClient" 
                       options:0 
                       context:&hostSelectionContext];
    [clientManager addObserver:self 
                    forKeyPath:@"activeClient.connectionStatus" 
                       options:0 
                       context:&hostSelectionContext];
    [[BMBClientSortDescriptors sharedClientSortDescriptors] addObserver:self 
                                                             forKeyPath:@"clientSortDescriptors" 
                                                                options:0 
                                                                context:&hostSelectionContext];
    
    return self;
}


- (void)dealloc
{
    [[BMBClientSortDescriptors sharedClientSortDescriptors] removeObserver:self forKeyPath:@"clientSortDescriptors"];
    
    [hostPopUpButton release];
    [hostListMenu    release];
    
    [super dealloc];
}


- (void)awakeFromNib
{
    [self updateHostListMenuItems];
}



#pragma mark Menu actions

- (void)selectHost:(id)sender
{
    [clientManager connectToClientByUUID:[sender representedObject]];
}



#pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == &hostSelectionContext) {
        [self updateHostListMenuItems];
        return;
    }
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}




#pragma mark NSMenu delegate methods

- (void)menuNeedsUpdate:(NSMenu *)menu
{
    [self updateHostListMenuItems];
}



#pragma mark Private methods

- (void)removeHostListMenuItems
{
    while ([hostListMenu numberOfItems])
        [hostListMenu removeItemAtIndex:0];
}


- (void)updateHostListMenuItems
{
    [self removeHostListMenuItems];
    
    NSArray *clients = [clientManager.clients sortedArrayUsingDescriptors:[[BMBClientSortDescriptors sharedClientSortDescriptors] clientSortDescriptors]];
    
    for (BOINCClient *client in clients) {
        NSMenuItem *hostItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:client.fullName action:@selector(selectHost:) keyEquivalent:@""];
        
        [hostItem setTarget:self];
        [hostItem setRepresentedObject:client.uuid];
        [hostItem setToolTip:[NSString stringWithFormat:NSLocalizedString(@"Change the Preference Window to show information for \"%@\"", @"The tooltip for the list of hosts the user has"), client.fullName]];
        
        if ([client isEqual:clientManager.activeClient])
            [hostItem setState:NSOnState];
        
        [hostListMenu addItem:hostItem];
        [hostItem release];
    }
    
    [hostPopUpButton selectItemWithTitle:clientManager.activeClient.fullName];
}



@end
