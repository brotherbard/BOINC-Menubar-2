//
//  ClientManager.m
//  BOINCMenubar
//
//  Created by BrotherBard on 4/18/08.
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

#import "BOINCClientManager.h"
#import "BOINCKeychain.h"
#import "BOINCKeychainItem.h"
#import <Keychain/KeychainItem.h>
#import "BOINCLogInWindowController.h"

#import "BB_XMLNodeXPathCategory.h"




//////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BOINCClientManager


@synthesize clients;
@synthesize keychain;
@synthesize localClient;
@synthesize localBOINCProcess;



// deals with the common init for the client managers
// read all the client info from the keychain and populate the clients array
- (id)init
{
    self = [super init];
    if (!self) return nil;
    
    clients = [[NSMutableArray alloc] init];
    keychain = [BOINCKeychain keychainWithClientManager:self];
    
    NSArray *allBOINCKeychainItems = [keychain allBOINCKeychainItems];
    
    for (BOINCKeychainItem *item in allBOINCKeychainItems)
        [self addClientForKeychainItem:item];
    
    if ([clients count] == 0) {
        // if there are no clients in the keychain, create a default localhost client
        BOINCKeychainItem *newItem = [[BOINCKeychainItem alloc] initWithPassword:nil address:@"localhost" name:@"This Computer"];
        [self addClientForKeychainItem:newItem];
        localBOINCProcess = [[BOINCClientProcess alloc] initWithClient:self.localClient];
        [newItem release];
    }
    
    // just setting up for possible random numbers later
    srandomdev();
    
    [self performSelector:@selector(setupTimers) withObject:nil afterDelay:0];
    
    return self;
}


- (void)dealloc
{
    [clients               release];
    [loginWindowController release];
    [keychain              release];
    [localClient           release];
    [localBOINCProcess     release];
    
    [super dealloc];
}



#pragma mark clients KVC
// KVC methods for clients array
- (NSUInteger)countOfClients
{
    return [self.clients count];
}


- (BOINCClient *)objectInClientsAtIndex:(NSUInteger)objectIndex
{
    return [self.clients objectAtIndex:objectIndex];
}


- (void)insertObject:(BOINCClient *)client inClientsAtIndex:(NSUInteger)objectIndex
{
    [self.clients insertObject:client atIndex:objectIndex];
}


- (void)removeObjectFromClientsAtIndex:(NSUInteger)objectIndex
{   
    [self.clients removeObjectAtIndex:objectIndex];
}



#pragma mark Adding / Removing Clients

- (void)addClientForKeychainItem:(BOINCKeychainItem *)item
{
    BBLog(@"%@", item);
    BOINCClient *client = [[BOINCClient alloc] initWithBOINCKeychainItem:item];
    [self addClient:client];
    [client release];
}


static const void *isAlwaysConnectedKVOContext;

- (void)addClient:(BOINCClient *)client
{
    [self insertObject:client inClientsAtIndex:[clients count]];
    if ((self.localClient == nil) && [client isLocalHost])
        self.localClient = client;
    
    client.isAlwaysConnected = [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@ isAlwaysConnected", client.uuid]];
    
    
    [client addObserver:self forKeyPath:@"isAlwaysConnected" options:0 context:&isAlwaysConnectedKVOContext];
}


- (void)removeClient:(BOINCClient *)client
{
    if (client.isConnected)
        [client closeConnection];
    if ([client isEqual:self.localClient])
        self.localClient = nil;
    
    // warn the client they will be deleted
    [client willDeleteClient];
    
    [client removeObserver:self forKeyPath:@"isAlwaysConnected"];
    
    [self removeObjectFromClientsAtIndex:[clients indexOfObject:client]];
}


- (BOINCClient *)clientForUUID:(NSString *)searchUUID
{
    BOINCClient *client = nil;
    for (client in self.clients)
        if ([client.uuid isEqualToString:searchUUID])
            break;
    
    return client;
}



#pragma mark KVO methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == &isAlwaysConnectedKVOContext) {
        // the client's isAlwaysConnected property changed
        BOINCClient *client = object;
        [[NSUserDefaults standardUserDefaults] setBool:client.isAlwaysConnected
                                                forKey:[NSString stringWithFormat:@"%@ isAlwaysConnected", client.uuid]];
        return;
    }
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}



#pragma mark Connecting Clients

- (void)connectToClientByUUID:(NSString *)newUUID
{
    BOINCClient *client = [self clientForUUID:newUUID];
    
    if (client.isConnected) {
        [self connectToClient:client withPassword:nil];
        return;
    }
    
    if (loginWindowController.client.uuid == client.uuid) {
        // if the login window is already open for this client bring it into the foreground to make sure it is visible
        // (it may be hidden by windows from other apps)
    	[loginWindowController showLoginWindow];
        return;
    }
    
    // if the login window is already up then cancel it
    [loginWindowController cancel:nil];
    
    BOOL forceNewPassword = NO;
    if (client.connectionStatus == kStatusPasswordFailed) {
        BBLog(@"forcing request of a new password because the existing password has failed");
        forceNewPassword = YES;
    }
    
    if (client.isPasswordInKeychain && !forceNewPassword) {
        // use password stored in keychain
        BBLog(@"Password for \"%@\" in Keychain", client.clientName);
        [self connectToClient:client withPassword:nil];
        return;
    }
    
    if (client.isLocalHost && !forceNewPassword) {
        // read password from BOINC's local password file
        BBLog(@"Password for \"%@\" in BOINC's local password file", client.clientName);
        [self connectToClient:client withPassword:[client readLocalPassword]];
        return;
    } 
    
    // ask participant for password
    BBLog(@"Asking for password to \"%@\"", client.clientName);
    loginWindowController = [[BOINCLoginWindowController alloc] initWithClient:client clientManager:self];
    [loginWindowController showWindow:nil];
}


// subclasses should override to change behaviour
- (void)connectToClient:(BOINCClient *)client withPassword:(NSString *)password
{
    if (![client connectWithPassword:password]) {
        // should send a notification???
        return;
    }
    
    BBLog(@"Failed attempting connection to client = %@", client.fullName);
}



#pragma mark Running the local BOINC client process
- (void)runLocalBOINCProcess
{
    if (localBOINCProcess == nil)
        localBOINCProcess = [[BOINCClientProcess alloc] initWithClient:self.localClient];
    
    [localBOINCProcess runBOINC];
}


- (void)stopLocalBOINCProcess
{
    if (localBOINCProcess.isChildProcessRunning)
        [localBOINCProcess quit];
}


- (NSApplicationTerminateReply)shouldAppTerminate
{
    if (localBOINCProcess == nil)
        return NSTerminateNow;
    
    return [localBOINCProcess shouldAppTerminate];
}




#pragma mark Login window

- (void)loginWindowClosed
{
    [loginWindowController release];
    loginWindowController = nil;
}



#pragma mark Timers

- (void)setupTimers
{
    // this will run all the time
    [[NSRunLoop currentRunLoop] addTimer:[NSTimer timerWithTimeInterval:1.0f 
                                                                 target:self 
                                                               selector:@selector(updateClientStatus:) 
                                                               userInfo:nil 
                                                                repeats:YES] 
                                 forMode:NSRunLoopCommonModes];
}

- (void)updateClientStatus:(NSTimer *)timer
{
    for (BOINCClient *client in clients) {
        if (client.connectionStatus == kStatusPasswordFailed)
            continue;
        
        if (!client.isConnected && client.isAlwaysConnected)
            [self connectToClientByUUID:client.uuid];
        
        if (client.isConnected)
            [client requestCCStatusUpdate];
    }
}



@end
