//
//  BMBActiveClientManager.m
//  BOINCMenubar
//
//  Created by BrotherBard on 2/20/09.
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

#import "BOINCActiveClientManager.h"
#import "BOINCClientManager.h"



// for the preference defaults dictionary
NSString * const kPreviousClientUUIDKey = @"Previous Client UUID";
NSString * const kAlwaysConnectedClientUUIDsKey = @"Always Connected Client UUIDs";




///////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BOINCActiveClientManager

@synthesize activeClient;


// Set up factory defaults for preferences.
+ (void)initialize 
{   
    if (self != [BOINCActiveClientManager class])
        return;
    
    NSDictionary *defaults = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"localhost", kPreviousHostUUIDKey,
                              nil];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults: defaults];
}


- (id)init
{
    self = [super init];
    if (!self) return nil;
    
    NSString *previousClientUUID = [[NSUserDefaults standardUserDefaults] stringForKey:kPreviousHostUUIDKey];
    
    BOINCClient *client = [self clientForUUID:previousClientUUID];
    if (client)
        [self connectToClientByUUID:client.uuid];
    else if ([clients count])
        [self connectToClientByUUID:[[clients objectAtIndex:0] uuid]];
    
    return self;
}


- (void) dealloc
{
    [activeClient release];
    
    [super dealloc];
}



// override then call super's method
- (void)connectToClientByUUID:(NSString *)newUUID
{
    if ([self.activeClient.uuid isEqualToString:newUUID] && self.activeClient.isConnected)
        return;
    
    [super connectToClientByUUID:newUUID];
}

    
// override of super's method
- (void)connectToClient:(BOINCClient *)client withPassword:(NSString *)password
{
    // close the connection to the old client
    if ((self.activeClient.isConnected || (self.activeClient.connectionStatus > kStatusNotConnected)) && (self.activeClient.isAlwaysConnected == NO)) {
        BBLog(@"closing connection to old active client = %@", self.activeClient.fullName);
        [self.activeClient closeConnection];
    }
    
    // start the connect process to the new client (note: |connectWithPassword:| is asyncronous so it returns right away)
    if (client.isConnected || [client connectWithPassword:password]) {
        self.activeClient = client;
        
        [[NSUserDefaults standardUserDefaults] setObject:self.activeClient.uuid forKey:kPreviousHostUUIDKey];
        
        BBLog(@"Connecting to new active client = %@", self.activeClient.fullName);
        return;
    } 

    BBLog(@"Failed attempting connection to client = %@", client.fullName);
}


- (void)removeClient:(BOINCClient *)client
{
    if ([client.uuid isEqualToString:self.activeClient.uuid])
        self.activeClient = nil;
    
    [super removeClient:client];
}



@end
