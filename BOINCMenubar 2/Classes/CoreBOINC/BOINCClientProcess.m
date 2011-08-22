//
//  BOINCClientProcess.m
//  BOINCMenubar
//
//  Created by BrotherBard on 4/24/09.
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

#import "BOINCClientProcess.h"
#import "BOINCCommonConstants.h"
#import "BOINCClient.h"
#import "BOINCHostConnection.h"
#import "BOINCClientStatus.h"

#import "BBXMLReader.h"

@interface BOINCClientProcess()

- (BOOL)runBOINCClientFromLaunchd;
- (BOOL)runBOINCClientFromBOINCManager;
- (BOOL)runBOINCClientFromApp;
- (BOOL)runBOINCClientFromPath:(NSString *)path;

- (void)hasChildBOINCProcessQuit;
- (void)isClientRunningTestFailed;

@property (nonatomic, readwrite, assign) BOOL isBOINCRunning;
@property (nonatomic, readwrite, assign) BOOL isBOINCChildProcess;

@end





@implementation BOINCClientProcess

@synthesize isBOINCRunning;
@synthesize isBOINCChildProcess;

@dynamic    isChildProcessRunning;


- (id)initWithClient:(BOINCClient *)client
{
    self = [super init];
    if (self == nil)
        return nil;
    
    localClient = client; // weak ref
    
    return self;
}


- (void)runBOINC
{
    if (![localClient.ccConnection isLocalHost])
        return;
    
    if ([localClient.ccConnection isConnected])
        return;
    
    // a little sanity check to see if BOINC has been installed on this computer
    // (could still be the wrong version wrt sandbox permissions)
    // if it is not installed then we can't run BOINC
    // ask if we should install BOINC???
    if (![[NSFileManager defaultManager] fileExistsAtPath:@"/Library/Application Support/BOINC Data"]) {
        BBError(@"Cannot run BOINC Client because BOINC is not installed on this system");
        localClient.connectionStatus = kStatusBOINCNotInstalled;
        return;
    }
    
    if (localClient.connectionStatus <= kStatusNotConnected)
        localClient.connectionStatus = kStatusTestingConnection;
    
    [localClient.ccConnection testConnectionWithTarget:self];
}


- (void)quit
{
    if (self.isChildProcessRunning) {
        shouldTerminateApp = NO;
        [localClient requestQuit];
        
        [self hasChildBOINCProcessQuit];
    }
}


- (void)startChildProcess
{
    if (boincChildProcess && self.isChildProcessRunning)
        return;
    
    // is boinc set to run as a daemon? Then start the launchd job.
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/LaunchDaemons/edu.berkeley.boinc.plist"]) {
        [self runBOINCClientFromLaunchd];
        return;
    }
    
    [self runBOINCClientFromBOINCManager];
    //[self runBOINCClientFromApp];
}


- (NSApplicationTerminateReply)shouldAppTerminate
{
    if (!self.isChildProcessRunning) 
        return NSTerminateNow;
    
    [localClient requestQuit];
    shouldTerminateApp = YES;
    
    [self performSelector:@selector(hasChildBOINCProcessQuit) 
               withObject:nil 
               afterDelay:1.0 
                  inModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
    
    return NSTerminateLater;
}


- (BOOL)isChildProcessRunning
{
    return [boincChildProcess isRunning];
}


- (void)terminateChildProcess
{
    [boincChildProcess terminate];
}



#pragma mark Testing if BOINC is running

- (void)isClientRunningTestSucceded
{
    // use cc_status as a test rpc
    [localClient.ccConnection queueRPCMessage:@"<get_cc_status/>" target:self replySelector:@selector(handleIsClientRunningReply:)];
}


- (void)isClientRunningTestFailed
{
    if (localClient.connectionStatus <= kStatusTestingConnection) {
        BBLog(@"%@", localClient.connectionStatusDescription);
        [localClient closeConnection];
    }
    
    [self startChildProcess];
}



#pragma mark -
#pragma mark Private Methods

- (void)handleIsClientRunningReply:(NSString *)rpcReply
{
    BOINCClientStatus *replyCCStatus = [BBXMLReader objectOfClass:[BOINCClientStatus class] 
                                                 withElementName:@"cc_status" 
                                                   fromXMLString:rpcReply];
    if (!replyCCStatus) {
        BBLog(@"Failed to recieve valid RPC reply while testing for BOINC client connection");
        [self isClientRunningTestFailed];
        return;
    }
    
    // test succeeded, BOINC is running
}

- (BOOL)runBOINCClientFromLaunchd
{
    BBLog(@"Running BOINC from new-style daemon using launchd");
        
    [NSTask launchedTaskWithLaunchPath:@"/bin/launchctl" 
                             arguments:[NSArray arrayWithObjects:@"load", @"/Library/LaunchDaemons/edu.berkeley.boinc.plist", nil]];
    
    // needed in case the job was already loaded but then stopped (load will fail with "already loaded")
    [NSTask launchedTaskWithLaunchPath:@"/bin/launchctl" 
                             arguments:[NSArray arrayWithObjects:@"start", @"edu.berkeley.boinc", nil]];
    
    return YES;
}



// TESTING
// at the moment just for testing, but might be useful
- (BOOL)runBOINCClientFromBOINCManager
{
    // don't just check /Applications because the app may have been moved
    //NSString *managerPath = [[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:@"edu.berkeley.boinc"];
    NSString *managerPath = @"/Applications/BOINCManager.app";
    
    if (managerPath)
        return [self runBOINCClientFromPath:[managerPath stringByAppendingString:@"/Contents/Resources/boinc"]];
    
    return NO;
}


- (BOOL)runBOINCClientFromApp
{
    // this won't work. BOINC requires the path to be /Contents/Resources/boinc or it's security check will fail
    // see check_security.cpp line 134
    // however cocoa apps should not run executables from the resources directory
    NSString *boincPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/Contents/Helpers/boinc"];
    
    // make sure there is a copy of boinc in the app
    if ([[NSFileManager defaultManager] fileExistsAtPath:boincPath])
        return [self runBOINCClientFromPath:boincPath];
    
    return NO;
}


- (BOOL)runBOINCClientFromPath:(NSString *)path
{
    if (!path)
        return NO;
    
    BBLog(@"Running BOINC core client from %@", path);
    
    boincChildProcess = [[NSTask alloc] init];
    [boincChildProcess setLaunchPath:path];
    [boincChildProcess setCurrentDirectoryPath:@"/Library/Application Support/BOINC Data"];
    [boincChildProcess setArguments:[NSArray arrayWithObjects:@"--redirectio", @"--launched_by_manager", nil]];
    [boincChildProcess launch];
    
    self.isBOINCChildProcess = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(taskExited:)
                                                 name:NSTaskDidTerminateNotification 
                                               object:boincChildProcess];
    return YES;
}



#pragma mark Quitting the child process

- (void)taskExited:(NSNotification *)note
{
    BBLog(@"terminationStatus = %d", [boincChildProcess terminationStatus]);
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:NSTaskDidTerminateNotification 
                                                  object:boincChildProcess];
    [boincChildProcess release];
    boincChildProcess = nil;
    isBOINCChildProcess = NO;
    localClient.connectionStatus = kStatusBOINCClientQuit;
    [localClient.ccConnection closeConnection];
}


// allow boinc client 10 seconds to quit
- (void)hasChildBOINCProcessQuit
{
    if (self.isChildProcessRunning && (quitCheckRetries < 10)) {
        quitCheckRetries++;
        [self performSelector:@selector(hasChildBOINCProcessQuit) 
                   withObject:nil 
                   afterDelay:1.0 
                      inModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
        return;
    }
    
    quitCheckRetries = 0;
    
    [self terminateChildProcess];
    self.isBOINCChildProcess = YES;
    
    if (shouldTerminateApp)
        [[NSApplication sharedApplication] replyToApplicationShouldTerminate:YES];
}


@end

