//
//  BMBGrowlNotifier.m
//  BOINCMenubar
//
//  Created by BrotherBard on 5/24/09.
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

#import "BMBGrowlNotifier.h"
#import "BMBAppController.h"
#import "BOINCActiveClientManager.h"
#import "BOINCClientManager.h"



// Private methods
@interface BMBGrowlNotifier()

- (void)removeObservers;
- (void)updateNotifications;
- (void)updateProjectsAndTasks;

@end

// KVO context
static const void *ccStatusKVOContext;
static const void *projectsAndTasksKVOContext;
static const void *activeClientKVOContext;


// Strings
#define kBMBGrowlProjectCreditMilestones     @"Project Credit Milestones"

#define kBMBGrowlHostCreditMilestones        @"Host Credit Milestones"

#define kBMBGrowlWorkunitsAndResults         @"Workunits and Results"
#define kBMBGrowlWorkunits                   @"Workunits"
#define kBMBGrowlResults                     @"Results"

#define kBMBGrowlNetworkConnection           @"Network Connection"

#define kBMBGrowlBOINCMenubarAppName         @"BOINCMenubar"



@implementation BMBGrowlNotifier



- (id)initWithClientManager:(BOINCActiveClientManager *)manager
{
    self = [super init];
    if (self == nil) 
        return nil;
    
    clientManager       = manager; // weak ref
    cachedClientStatus  = [[BOINCClientStatus alloc] init];
    cachedTasksByClient = [[NSMutableDictionary alloc] init];
    clickContexts       = [[NSMutableDictionary alloc] init];
    
    // load Growl
    NSBundle *myBundle    = [NSBundle bundleForClass:[self class]];
    NSString *growlPath   = [[myBundle privateFrameworksPath] stringByAppendingPathComponent:@"Growl.framework"];
    NSBundle *growlBundle = [NSBundle bundleWithPath:growlPath];
    if (growlBundle && [growlBundle load])
        [GrowlApplicationBridge setGrowlDelegate:self];
    else
        BBError(@"Could not load Growl.framework");
    
    // observe the notifications that CoreBOINC sends for credit milestones
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userCreditMilestone:)
                                                 name:kBOINCUserCreditMilestoneNotification 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hostCreditMilestone:)
                                                 name:kBOINCHostCreditMilestoneNotification 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hostTotalCreditMilestone:)
                                                 name:kBOINCHostTotalCreditMilestoneNotification 
                                               object:nil];
    
    // observe parts of the active client so we can update our cache of project tasks
    [clientManager addObserver:self 
                    forKeyPath:@"activeClient" 
                       options:NSKeyValueObservingOptionInitial 
                       context:&activeClientKVOContext];
    
    [clientManager addObserver:self 
                    forKeyPath:@"activeClient.ccStatus" 
                       options:NSKeyValueObservingOptionInitial 
                       context:&ccStatusKVOContext];
    
    waitingForProjectsAndTasksUpdate = YES;
    
    [clientManager addObserver:self 
                    forKeyPath:@"activeClient.lastProjectsAndTasksUpdate" 
                       options:NSKeyValueObservingOptionInitial 
                       context:&projectsAndTasksKVOContext];
    
    return self;
}

- (void)dealloc
{
    [self removeObservers];
    
    [cachedClientStatus  release];
    [cachedTasksByClient release];
    [clickContexts       release];
    
    [super dealloc];
}



#pragma mark Growl Delegate Methods

- (NSString *)applicationNameForGrowl
{
    return kBMBGrowlBOINCMenubarAppName;
}


- (void)growlNotificationWasClicked:(id)clickContext
{
    BBLog(@"%@", clickContext);
    [clickContexts removeObjectForKey:clickContext];
}


- (void)growlNotificationTimedOut:(id)clickContext
{
    BBLog(@"%@", clickContext);
    [clickContexts removeObjectForKey:clickContext];
}




#pragma mark Notification Methods
- (void)userCreditMilestone:(NSNotification *)notification
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kShowGrowlNotifications])
        return;
    
    BBMark;
    NSDictionary *notificationDict = [notification object];
    BOINCProject *project = [notificationDict objectForKey:kBOINCProjectKey];
    BOINCClient   *host    = [notificationDict objectForKey:kBOINCHostKey];
    
    [GrowlApplicationBridge notifyWithTitle:[NSString stringWithFormat:@"BOINC: %@", project.projectName]
                                description:[NSString stringWithFormat:NSLocalizedString(@"%@ has passed %@ credits!", @""), 
                                             project.userName, 
                                             project.userCreditMilestone.formattedPreviousMilestone]
                           notificationName:kBMBGrowlProjectCreditMilestones
                                   iconData:nil
                                   priority:0
                                   isSticky:NO
                               clickContext:nil
                                 identifier:[NSString stringWithFormat:@"%@ %@ %@", 
                                             kBMBGrowlProjectCreditMilestones, 
                                             host.uuid, 
                                             project.projectName]];
}


- (void)hostCreditMilestone:(NSNotification *)notification
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kShowGrowlNotifications])
        return;
    
    BBMark;
    NSDictionary *notificationDict = [notification object];
    BOINCProject *project = [notificationDict objectForKey:kBOINCProjectKey];
    BOINCClient   *host    = [notificationDict objectForKey:kBOINCHostKey];
    
    [GrowlApplicationBridge notifyWithTitle:[NSString stringWithFormat:@"BOINC: %@", project.projectName]
                                description:[NSString stringWithFormat:NSLocalizedString(@"%@ has passed %@ credits!", @""), 
                                             host.fullName, 
                                             project.hostCreditMilestone.formattedPreviousMilestone]
                           notificationName:kBMBGrowlHostCreditMilestones
                                   iconData:nil
                                   priority:0
                                   isSticky:NO
                               clickContext:nil
                                 identifier:[NSString stringWithFormat:@"%@ %@ %@", 
                                             kBMBGrowlHostCreditMilestones, 
                                             host.uuid,
                                             project.projectName]];
}


- (void)hostTotalCreditMilestone:(NSNotification *)notification
{    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kShowGrowlNotifications])
        return;
    
    BBMark;
    BOINCClient *client = [notification object];
    
    [GrowlApplicationBridge notifyWithTitle:[NSString stringWithFormat:@"BOINC: %@", client.fullName]
                                description:[NSString stringWithFormat:NSLocalizedString(@"%@ has surpassed %@ credits in all projects!", @""), 
                                             client.fullName, 
                                             client.hostTotalCreditMilestone.formattedPreviousMilestone]
                           notificationName:kBMBGrowlHostCreditMilestones
                                   iconData:nil
                                   priority:0
                                   isSticky:NO
                               clickContext:nil
                                 identifier:[NSString stringWithFormat:@"Total %@ %@", 
                                             kBMBGrowlHostCreditMilestones, 
                                             client.uuid]];
}


- (void)project:(BOINCProject *)project inClient:(BOINCClient *)client reportedResults:(NSUInteger)resultsCount downloadedWorkunits:(NSUInteger)workunitsCount
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kShowGrowlNotifications])
        return;
    
    NSString *context = [NSString stringWithFormat:@"%@ %@ %@",
                         kBMBGrowlWorkunitsAndResults,
                         client.uuid, 
                         project.projectName];
    BBLog(@"%@", context);
    BBLog(@"newWorkunits = %d  newResults = %d", workunitsCount, resultsCount);
    
    NSDictionary *dictionary = [clickContexts objectForKey:context];
    if (dictionary) {
        BBLog(@"oldWorkunits = %d  oldResults = %d", [[dictionary objectForKey:kBMBGrowlWorkunits] intValue], [[dictionary objectForKey:kBMBGrowlResults] intValue]);
        workunitsCount += [[dictionary objectForKey:kBMBGrowlWorkunits] intValue];
        resultsCount   += [[dictionary objectForKey:kBMBGrowlResults] intValue];
    }
    
    dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                  [NSNumber numberWithUnsignedInteger:workunitsCount], kBMBGrowlWorkunits,
                  [NSNumber numberWithUnsignedInteger:resultsCount],   kBMBGrowlResults,
                  nil];
    [clickContexts setObject:dictionary forKey:context];
    
    NSMutableString *description = [NSMutableString string];
    if (resultsCount)
        [description appendFormat:NSLocalizedString(@"\tReported results: %d", @""), resultsCount];
    if (resultsCount && workunitsCount)
        [description appendString:@"\n"];
    if (workunitsCount)
        [description appendFormat:NSLocalizedString(@"\tDownloaded workunits: %d", @""), workunitsCount];
    
    [GrowlApplicationBridge notifyWithTitle:[NSString stringWithFormat:@"BOINC: %@", client.fullName]
                                description:[NSString stringWithFormat:@"%@\n%@", project.projectName, description ]
                           notificationName:kBMBGrowlWorkunitsAndResults
                                   iconData:nil
                                   priority:0
                                   isSticky:NO
                               clickContext:context
                                 identifier:context];
}




#pragma mark KVO methods

- (void)removeObservers
{   
    [clientManager removeObserver:self forKeyPath:@"activeClient"];
    [clientManager removeObserver:self forKeyPath:@"activeClient.ccStatus"];
    [clientManager removeObserver:self forKeyPath:@"activeClient.lastProjectsAndTasksUpdate"];
	[[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == &activeClientKVOContext) {
        if (cachedActiveClient != clientManager.activeClient) {
            cachedActiveClient = clientManager.activeClient;
            waitingForProjectsAndTasksUpdate = YES;
        }
        return;
    }
    
    if (context == &ccStatusKVOContext) {
        [self updateNotifications];
        return;
    }
    
    if (context == &projectsAndTasksKVOContext) {
        if (waitingForProjectsAndTasksUpdate) {
            BBLog(@"%@", object);
            [self updateProjectsAndTasks];
            waitingForProjectsAndTasksUpdate = NO;
        }
        return;
    }
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}



#pragma mark KVO responders

- (void)updateNotifications
{
    BBLog(@"%@", [clientManager.activeClient.ccStatus debugDescription]);
    
    int networkStatus = clientManager.activeClient.ccStatus.networkStatus;
    if (networkStatus == cachedClientStatus.networkStatus)
        return;
    
    cachedClientStatus.networkStatus = networkStatus;
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kShowGrowlNotifications])
        return;
    
    if (networkStatus == kNetworkStatusNeedsConnection)
        [GrowlApplicationBridge notifyWithTitle:[NSString stringWithFormat:@"BOINC: %@", clientManager.activeClient.fullName]
                                    description:NSLocalizedString(@"BOINC needs a network connection", @"BOINC needs a network connection")
                               notificationName:kBMBGrowlNetworkConnection
                                       iconData:nil
                                       priority:1
                                       isSticky:YES
                                   clickContext:nil
                                     identifier:[NSString stringWithFormat:@"%@ %@", kBMBGrowlNetworkConnection, clientManager.activeClient.uuid]];
    
    // if BOINC had a network connection and now doesn't want it, it probably communicated with a project
    if (networkStatus == kNetworkStatusCanDisconnect) {
        waitingForProjectsAndTasksUpdate = YES;
        [clientManager.activeClient requestProjectsAndTasksUpdate];
    }
}


// count up workunits downloaded and results reported and send a growl notification
- (void)updateProjectsAndTasks
{
    BOINCClient *client = cachedActiveClient;
    if (client == nil)
        return;
    
    NSMutableDictionary *cachedTasksByProject = [cachedTasksByClient objectForKey:client.uuid];
    if (cachedTasksByProject == nil) {
        cachedTasksByProject = [NSMutableDictionary dictionary];
        [cachedTasksByClient setObject:cachedTasksByProject forKey:client.uuid];
    }
    
    // go through each project and check for any new or missing tasks
    for (BOINCProject *project in client.projects) {
        //BBLog(@"Project: %@", project.projectName);
        NSMutableDictionary *cachedTasks = [cachedTasksByProject objectForKey:project.projectName];
        if (cachedTasks == nil) {
            // this is a new project, add it's tasks to the cache but don't send any notifications
            cachedTasks = [NSMutableDictionary dictionary];
            for (BOINCTask *task in project.tasks)
                [cachedTasks setObject:task forKey:task.name];
            [cachedTasksByProject setObject:cachedTasks forKey:project.projectName];
            continue;
        }
        
        // workunits are new tasks that have just been downloaded, any tasks that don't
        // exist in the cache are workunits
        NSMutableArray *workunits = [NSMutableArray array];
        
        // results are tasks that have been reported, so start with all the cached 
        // tasks and remove any that still exist, the remaining tasks have been reported
        NSMutableArray *results = [[[cachedTasks allValues] mutableCopy] autorelease];
        
        for (BOINCTask *task in project.tasks) {
            BOINCTask *cachedTask = [cachedTasks objectForKey:task.name];
            if (cachedTask == nil)
                [workunits addObject:task];
            else
                [results removeObject:task];
        }
        
        NSUInteger resultsCount = [results count];
        if (resultsCount)
            for (BOINCTask *task in results)
                [cachedTasks removeObjectForKey:task.name];
        
        NSUInteger workunitsCount = [workunits count];
        if (workunitsCount)
            for (BOINCTask *task in workunits)
                [cachedTasks setObject:task forKey:task.name];
        
        if (resultsCount || workunitsCount)
            [self project:project inClient:client reportedResults:resultsCount downloadedWorkunits:workunitsCount];
        
       // BBLog(@"workunitsCount = %d  resultsCount = %d  cachedTasks = %d  projectTasks = %d  taskCount = %d", 
       //       workunitsCount, resultsCount, [cachedTasks count], [project.tasks count], project.taskCount);
    }
}




@end
