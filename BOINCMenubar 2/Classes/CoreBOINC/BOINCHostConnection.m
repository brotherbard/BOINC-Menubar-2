//
//  BOINCHostConnection.m
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

#import "BOINCHostConnection.h"
#import "AsyncSocket.h"
#import "BOINCClient.h"
#import "BOINCClientProcess.h"

#import "BB_XMLNodeXPathCategory.h"
#import "BOINCCommonConstants.h"

#import <arpa/inet.h>
#import <netdb.h>


// end of text
NSString * const kETX     = @"\003";

// TCP socket port for the core client
const int kBOINCSocketPort = 31416;

// no timeout
const int kDefaultTimeout = -1;


///////////////////////////////////////////////////////////
// a helper class for keeping track of the current RPC request info
@interface RPCInfo : NSObject
{
    id        target;
    NSString *request;
    SEL       selector;
}
@property (nonatomic, assign) id        target;
@property (nonatomic, copy)   NSString *request;
@property (nonatomic, assign) SEL       selector;

+ (id)infoForRequest:(NSString *)newRequest target:(id)newTarget selector:(SEL)newSelector;

- (id)initWithRequest:(NSString *)newRequest target:(id)newTarget selector:(SEL)newSelector;

@end


///////////////////////////////////////////////////////////
@implementation RPCInfo

@synthesize target;
@synthesize request;
@synthesize selector;

+ (id)infoForRequest:(NSString *)newRequest target:(id)newTarget selector:(SEL)newSelector
{
    return [[[RPCInfo alloc] initWithRequest:(NSString *)newRequest target:(id)newTarget selector:newSelector] autorelease];
}

- (id)initWithRequest:(NSString *)newRequest target:(id)newTarget selector:(SEL)newSelector
{
    self = [super init];
    if (!self) return nil;
    
    target   = newTarget;
    request  = [newRequest copy];
    selector = newSelector;
    
    return self;
}

@end



///////////////////////////////////////////////////////////
@implementation BOINCHostConnection

@synthesize hostAddress;


- (id)initWithClient:(id)newDelegate
{
    self = [super init];
    if (!self) return nil;
    
    client = newDelegate;
    messageQueue = [[NSMutableArray alloc] init];
    
    return self;
}

- (void)dealloc
{
    [self closeConnection];
    
    [clientSocket release];
    [hostAddress  release];
    [messageQueue release];
    
    [super dealloc];
}


///////////////////////////////////////////////////////////
#pragma mark -
#pragma mark BOINCHostConnection methods

// AsyncSocket uses CFSocket which is broken for computers with two or more active ethernet interfaces
// so create a BSD socket manually and use that instead
// TODO: add support for IPv6 when(if) BOINC upgrades
- (BOOL)openConnection
{
    if (   client.connectionStatus == kStatusNotConnected
        || client.connectionStatus == kStatusBOINCNotInstalled
        || client.connectionStatus == kStatusBOINCClientQuit )
        return NO;
    
    if (isConnecting)
        return YES;
    
    // hostAddress may be an address (IPv4) or a host name
    if (!hostAddress || [hostAddress isEqualToString:@""]) {
        BBError(@"No host address");
        return NO;
    }
    
    // TODO: determine if we are in a broken state and reset the connection
    
    if ([clientSocket isConnected]) {
        BBLog(@"connecting to client that is already connected");
        return YES;
    }
    
    // get the socket file descritpor
    int _clientSocket = socket(AF_INET, SOCK_STREAM, 0); 
    if (_clientSocket == -1) {
        BBError(@"Could not create server socket.  [socket() error is %s]", strerror(errno));
        return NO;
    }
    
    // setup the address
    struct sockaddr_in clientAddress;
    bzero(&clientAddress, sizeof(struct sockaddr_in));
    clientAddress.sin_len = sizeof(struct sockaddr_in);
    clientAddress.sin_family = AF_INET;
    clientAddress.sin_port = htons(kBOINCSocketPort);
    if (inet_pton(AF_INET, [hostAddress UTF8String], &clientAddress.sin_addr) <= 0) {
        struct hostent *hostInfo = gethostbyname([hostAddress UTF8String]);
        if (hostInfo == NULL) {
            BBError(@"Invalid host name/address. [inet_pton() error is %s] [gethostbyname() error is %s]", strerror(errno), hstrerror(h_errno));
            return NO;
        }
        clientAddress.sin_addr = *(struct in_addr *) hostInfo->h_addr;
    }
    
    [messageQueue removeAllObjects];
    
    clientSocket = [[AsyncSocket alloc] initWithDelegate:self];
    [clientSocket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
    NSError *error = nil;
    isConnecting = YES;
    //if (![clientSocket connectToHost:hostAddress onPort:kBOINCSocketPort error:&error]) { // broken
    if (![clientSocket connectToAddress:[NSData dataWithBytes:&clientAddress length:clientAddress.sin_len] error:&error]) {
        BBError(@"Error starting connection: %@", error);
        isConnecting = NO;
        return NO;
    }
    
    return YES;
}


- (void)testConnectionWithTarget:(id)target
{
    isTestingConnection = YES;
    testingDelegate = target;
    
    if (!isConnecting)
        [self openConnection];
}


- (void)closeConnection
{
    [clientSocket disconnect];
    [messageQueue removeAllObjects];
    messageInProgress = NO;
    [clientSocket release];
    clientSocket = nil;
    isConnecting = NO;
}


- (BOOL)isConnected
{
    return [clientSocket isConnected];
}


- (BOOL)isLocalHost
{
    static NSArray *namesAndAddresses = nil;
    if (!namesAndAddresses)
        namesAndAddresses = [[[[NSHost currentHost] names] arrayByAddingObjectsFromArray:[[NSHost currentHost] addresses]] retain];
    
    //BBError(@"%@", namesAndAddresses);
    for (NSString *address in namesAndAddresses)
        if ([hostAddress isEqualToString:address])
            return YES;
    
    return NO;
}



///////////////////////////////////////////////////////////
#pragma mark -
#pragma mark RPC

//  Takes a string with the request XML in it and wraps it in the BOINC request root element.
- (void)writeNextMessage
{
    if ([messageQueue count]) {
        messageInProgress = YES;
        RPCInfo *messageInfo = [messageQueue objectAtIndex:0];
        NSMutableString *message = [NSMutableString stringWithFormat: @"<boinc_gui_rpc_request>%@</boinc_gui_rpc_request>%@", messageInfo.request, kETX];
        NSData *messageData = [message dataUsingEncoding:NSUTF8StringEncoding];
        //BBLog(@"write = %@", messageInfo.request);
        [clientSocket writeData:messageData withTimeout:kDefaultTimeout tag:0];
    }
}


- (void)queueRPCMessage:(NSString *)request target:(id)target replySelector:(SEL)selector
{
    if (![self isConnected])
        return;
    
    // stop multiple requests for the same RPC from piling up (like updateCCStatus)
    if ([[(RPCInfo *)[messageQueue lastObject] request] isEqualToString:request]) {
        BBLog(@"RPC request is already in the queue: %@", request);
        return;
    }
    
    // setup the RPCInfo
    [messageQueue addObject:[RPCInfo infoForRequest:request target:target selector:selector]];
    
    // if there's no message currently waiting for a reply then send it now
    if (!messageInProgress)
        [self writeNextMessage];
}



///////////////////////////////////////////////////////////
#pragma mark -
#pragma mark AsyncSocket delegate methods

- (BOOL)onSocketWillConnect:(AsyncSocket *)sock
{
    BBLog(@"Will Connect to Client: %@", hostAddress);
    return YES;
}


- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    BBLog(@"Did Connect to Client %@:%hu", host, port);
    
    if (isTestingConnection) {
        isTestingConnection = NO;
        [(BOINCClientProcess *)testingDelegate isClientRunningTestSucceded];
        if (!isConnecting)
            return;
    }
    
    isConnecting = NO;
    connectionRetries = 0;
    
    [client clientConnectionDidConnect];
}


- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    //BBLog(@"Client Did Write Data: %@:%hu", [sock connectedHost], [sock connectedPort]);
    
    [sock readDataToData:[kETX dataUsingEncoding:NSUTF8StringEncoding] withTimeout:kDefaultTimeout tag:tag];
}


- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    //BBLog(@"Client Did Read Data: %@:%hu", [sock connectedHost], [sock connectedPort]);
    RPCInfo *messageInfo = [[messageQueue objectAtIndex:0] retain];
    [messageQueue removeObjectAtIndex:0];
    
    // remove the ETX code from the end of the reply
    NSData *replyData = [data subdataWithRange:NSMakeRange(0, [data length] - 1)];
    // I am making the assumtion that all future RPC replies will continue to be in "ISO-8859-1"
    NSString *reply = [[[NSString alloc] initWithData:replyData encoding:NSISOLatin1StringEncoding] autorelease];
    if (!reply) {
        BBError(@"Error reading/converting the XML data");
        messageInProgress = NO;
        [self writeNextMessage];
        [messageInfo release];
        return;
    }
    
    // The boinc client may reply with an xml declaration after the first xml element (which is *bad*) so I'm
    // deleting the the xml declaration. There is no useful info in it (the encoding was changed to UTF8 above).
    //
    // There are only a few RPC replies that do this, but I don't know if there will be more in the future, 
    // which makes this the safest thing to do. The sad part is this is the only reason to convert to NSString, 
    // otherwise I could just keep it in NSData and not mess with any of this.
    NSRange xmlDeclaration = [reply rangeOfString:@"<?xml version="];
    if (xmlDeclaration.location != NSNotFound) {
        NSRange closingTag = [reply rangeOfString:@"?>"];
        NSRange rangeToDelete = NSMakeRange(xmlDeclaration.location, closingTag.location + closingTag.length - xmlDeclaration.location);
        reply = [reply stringByReplacingCharactersInRange:rangeToDelete withString:@""];
    }
    
    //    if ([messageInfo.request isEqualToString:@"<get_state/>"]) {
    //      BBLog(@"reply for = %@", messageInfo.request);
    //      BBLog(@"%@", reply);
    //    }
    
    if (messageInfo.selector != NULL)
            [messageInfo.target performSelector:messageInfo.selector withObject:reply];
    
    [messageInfo release];
    
    messageInProgress = NO;
    [self writeNextMessage];
}


// if the socket failed to connect to the host try again:
//     once a second for the first 15
//     every 5 seconds for 2 minutes
//     then once a minute after that
//     (should there be a longer backoff???)
// useful when the computer is just starting up and BOINC is still getting started
// or if a remote host is rebooted
- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)error
{
    BBLog(@"Client Will Disconnect: %@:%hu withError: %@", [sock connectedHost], [sock connectedPort], [error localizedDescription]);
    
    if (isTestingConnection) {
        isTestingConnection = NO;
        BBLog(@"The local BOINC client is not running");
        [(BOINCClientProcess *)testingDelegate isClientRunningTestFailed];
        if (!isConnecting)
            return;
    }
    
    BBLog(@"[%d] %@", [error code], [error localizedDescription]);
    
    if (error && (client.connectionStatus != kStatusPasswordFailed) && isConnecting && ((connectionRetries < 44) || client.isAlwaysConnected)) {
        connectionRetries++;
        isConnecting = NO;
        double delay = 1.0;
        if (connectionRetries >= 39)
            delay = 60.0;
        else if (connectionRetries >= 15)
            delay = 5.0;
        
        BBLog(@"Opening connection to client %@ failed %u times. Retrying connection in %f secs.", hostAddress, connectionRetries, delay);
        if (client.isAlwaysConnected)
            BBLog(@"Client is always connected");
        
        [self performSelector:@selector(openConnection)
                   withObject:nil
                   afterDelay:delay
                      inModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
        return;
    }
    
    [client closeConnection];
    [messageQueue removeAllObjects];
    messageInProgress = NO;
}


- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    BBLog(@"Client Did Disconnect: %@", hostAddress);
}

@end
