//
//  BMBHostsPrefController.m
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

#import "BMBHostsPrefController.h"
#import "BOINCActiveClientManager.h"
#import "BMBEditHostInformationSheet.h"

#import "BOINCClientManager.h"



//////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BMBHostsPrefController


@synthesize clientList;
@synthesize hostsTable;
@synthesize removeHostButton;


- (id)initWithClientManager:(id)manager
{
    self = [super initWithNibName:@"BMBHostsPreferences" bundle:nil];
    if (!self) return nil;
    
    clientManager = manager;
    
    return self;
}


- (void)dealloc
{
    clientManager = nil;
    [clientList               release];
    [editHostInformationSheet release];
    
    [hostsTable               release];
    [removeHostButton         release];
    
    [statusArray              release];
    
    [selectedRowAttributes    release];
    [warningAttributes        release];
    [connectedAttributes      release];
    [inProgressAttributes     release];
    
    [super dealloc];
}


- (void)awakeFromNib
{
    selectedRowAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:[NSColor whiteColor], NSForegroundColorAttributeName, nil];
    
    NSColor *warningColor = [NSColor colorWithCalibratedRed:0.75f green:0.0f blue:0.0f alpha:1.0f];
    warningAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:warningColor, NSForegroundColorAttributeName, nil];
    
    NSColor *connectedColor = [NSColor colorWithCalibratedRed:0.0f green:0.75f blue:0.0f alpha:1.0f];
    connectedAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:connectedColor, NSForegroundColorAttributeName, nil];
    
    inProgressAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:[NSColor blackColor], NSForegroundColorAttributeName, nil];
}



#pragma mark BMB_ViewController_Category methods

static const void *hostsContext;

- (void)BMB_contentViewWillLoad
{
    [[[self view] window] makeFirstResponder:hostsTable];
    
    [clientManager addObserver:self forKeyPath:@"clients" options:NSKeyValueObservingOptionInitial context:&hostsContext];
    [clientManager addObserver:self forKeyPath:@"activeClient" options:0 context:&hostsContext];
    [clientManager addObserver:self forKeyPath:@"activeClient.connectionStatus" options:0 context:&hostsContext];
}


- (void)BMB_contentViewDidUnload
{
    [clientManager removeObserver:self forKeyPath:@"clients"];
    [clientManager removeObserver:self forKeyPath:@"activeClient"];
    [clientManager removeObserver:self forKeyPath:@"activeClient.connectionStatus"];
    
    [[[self view] window] makeFirstResponder:nil];
}



#pragma mark KVO Methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == &hostsContext) {
        // the activeClient.connectionStatus, activeClient or clients array changed
        self.clientList = [clientManager.clients sortedArrayUsingDescriptors:[hostsTable sortDescriptors]];
        [hostsTable reloadData];
    } else
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}



#pragma mark Action methods

- (IBAction)removeHost:(id)sender
{
    BOINCClient *client = [self.clientList objectAtIndex:[hostsTable selectedRow]];
    BBError(@"Removing client: %@", client);
    [clientManager removeClient:client];
}



- (IBAction)addHost:(id)sender
{
    if (!editHostInformationSheet)
        editHostInformationSheet = [[BMBEditHostInformationSheet alloc] initWithWindowNibName:@"BMBEditHostInformationSheet"];
    
    [editHostInformationSheet beginAddHostInWindow:[[self view] window] 
                                            target:self
                                 withClientManager:clientManager];
}



- (IBAction)editHost:(id)sender
{
    if ([hostsTable selectedRow] == -1)
        return;
    
    BOINCClient *editHost = [self.clientList objectAtIndex:[hostsTable selectedRow]];
    
    if (!editHostInformationSheet)
        editHostInformationSheet = [[BMBEditHostInformationSheet alloc] initWithWindowNibName:@"BMBEditHostInformationSheet"];
    
    [editHostInformationSheet beginEditHost:editHost
                          withClientManager:clientManager
                                  forWindow:[[self view] window] 
                                     target:self];
}



- (IBAction)showHostPreferenceHelp:(id)sender
{
    BBLog(@"Say something informative");
}


- (IBAction)toggleIsAlwaysConnected:(id)sender
{
    if ([hostsTable selectedRow] == -1)
        return;
    
    BOINCClient *client = [self.clientList objectAtIndex:[hostsTable selectedRow]];
    client.isAlwaysConnected = !client.isAlwaysConnected;
    
    [hostsTable reloadData];
}




#pragma mark TableView Delegate Methods

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    if ([hostsTable selectedRow] == -1)
        [removeHostButton setEnabled:NO];
    else
        [removeHostButton setEnabled:YES];
}



#pragma mark TableView DataSource Methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [clientList count];
}


- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)column row:(NSInteger)rowIndex
{
    BOINCClient *client = [self.clientList objectAtIndex:rowIndex];
    
    if ([[column identifier] isEqualToString:@"connectionStatus"]) {
        int connectionStatus = client.connectionStatus;
        
        if (connectionStatus == kStatusNotConnected)
            return @"";
        
        // determines what color the text should be (based first on whether it is selected then on it's status)
        NSDictionary *attributesDict;
        if ([aTableView selectedRow] == rowIndex)
            attributesDict = selectedRowAttributes;
        else if (connectionStatus < 0)
            attributesDict = warningAttributes;
        else if (connectionStatus == kStatusConnected)
            attributesDict = connectedAttributes;
        else
            attributesDict = inProgressAttributes;
        
        return [[[NSAttributedString alloc] initWithString:client.connectionStatusDescription attributes:attributesDict] autorelease];
    }
    
    // for the rest of the columns, the column identifier is the property key
    return [client valueForKey:[column identifier]];
}

- (void)tableView:(NSTableView *)aTableView sortDescriptorsDidChange:(NSArray *)oldDescriptors
{
    self.clientList = [clientList sortedArrayUsingDescriptors:[hostsTable sortDescriptors]];
}



#pragma mark DidEnd Selector Methods

- (void)didEndEditHost
{
    [hostsTable reloadData];
}


- (void)didEndAddHost:(BOINCClient *)client 
{
    if (client) {
        [clientManager addClient:client];
        [hostsTable reloadData];
    }
}

@end
