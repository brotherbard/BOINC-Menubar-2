//
//  BOINCProject.m
//  BOINCMenubar
//
//  Created by BrotherBard on 3/30/08.
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

#import "BOINCProject.h"

#import "BOINCTask.h"
#import "BOINCURL.h"
#import "BOINCPlatform.h"
#import "BOINCCreditMilestone.h"
#import "BOINCCommonConstants.h"
#import "BOINCClient.h"



//////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BOINCProject


@synthesize client;

@synthesize projectName;
@synthesize masterURL;
@synthesize userName;
@synthesize teamName;
@synthesize hostVenue;
@synthesize hostID;
@synthesize resourceShare;

@synthesize userTotalCredit;
@synthesize userRAC;
@synthesize hostTotalCredit;
@synthesize hostRAC;
@synthesize shouldNotRequestWork;
@synthesize isSuspended;
@synthesize detachWhenDone;
@synthesize isAttachedViaAccountManager;
@synthesize tasks;
@synthesize boincURLs;
@synthesize userCreateTime;

@synthesize platforms;

@synthesize remainingTimeEstimate;
@synthesize taskCount;
@synthesize runningTaskCount;
@synthesize tasksDownloading;
@synthesize tasksToReport;
@synthesize tasksWithErrors;
@synthesize tasksAborted;

@synthesize hostCreditMilestone;
@synthesize userCreditMilestone;




- (id)init
{
    self = [super init];
    if (!self) return nil;
    
    tasks     = [[NSMutableArray alloc] init];
    boincURLs = [[NSMutableArray alloc] init];
    platforms = [[NSMutableArray alloc] init];
    
    return self;
}


- (void)dealloc
{
    [projectName release];
    [masterURL   release];
    [userName    release];
    [teamName    release];
    [hostVenue   release];
    
    [tasks       release];
    [boincURLs   release];
    [platforms   release];
    
    [hostCreditMilestone release];
    [userCreditMilestone release];
    
    [super dealloc];
}



///////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSObject methods

// Equal objects must hash the same, so test the same data that is used to create the hash

- (BOOL)isEqual:(id)object
{
    if (![object isMemberOfClass:[BOINCProject class]])
        return NO;
    
    return [self.masterURL isEqualToString:((BOINCProject *)object).masterURL];
}

- (NSUInteger)hash
{
    return [self.masterURL hash];
}



#pragma mark <NSCopying>
- (id)copyWithZone:(NSZone *)zone
{
    BOINCProject *copiedProject = [[BOINCProject allocWithZone:zone] init];
    
    copiedProject.client                      = self.client;
    
    copiedProject.projectName                 = self.projectName;
    copiedProject.masterURL                   = self.masterURL;
    copiedProject.userName                    = self.userName;
    copiedProject.teamName                    = self.teamName;
    copiedProject.hostVenue                   = self.hostVenue;
    copiedProject.hostID                      = self.hostID;
    copiedProject.resourceShare               = self.resourceShare;
    
    copiedProject.userTotalCredit             = self.userTotalCredit;
    copiedProject.userRAC                     = self.userRAC;
    copiedProject.hostTotalCredit             = self.hostTotalCredit;
    copiedProject.hostRAC                     = self.hostRAC;
    
    copiedProject.shouldNotRequestWork        = self.shouldNotRequestWork;
    copiedProject.isSuspended                 = self.isSuspended;
    copiedProject.detachWhenDone              = self.detachWhenDone;
    copiedProject.isAttachedViaAccountManager = self.isAttachedViaAccountManager;
    
    copiedProject.userCreateTime              = self.userCreateTime;
    
    copiedProject.hostCreditMilestone         = self.hostCreditMilestone;
    copiedProject.userCreditMilestone         = self.userCreditMilestone;
    
    for (BOINCTask *task in self.tasks)
        [copiedProject countTask:task];
    
    for (BOINCURL *url in self.boincURLs)
        [copiedProject addURL:url];
    
    for (BOINCPlatform *platform in self.platforms)
        [copiedProject addPlatform:platform];
    
    
    return copiedProject;
}




/////////////////////////////////////
#pragma mark -
#pragma mark BOINCProject methods

// add up the tasks and the estimated time remaining
- (BOOL)countTask:(BOINCTask *)task
{
    if ([self hasSameURL:task.projectURL]) {
        if (![tasks containsObject:task])
            [self.tasks addObject:task];
        
        //NSString *report = @"";
        if (task.isReadyToReport) {
            tasksToReport++;
            //report = @"isReadyToReport ";
        }
        
        if (task.taskState == 0) {
            // new task
            //BBLog(@"new task");
        } else if (task.taskState == 1) {
            // downloading
            //taskCount++;
            if (task.exitStatus == -186) // for download failed error
                tasksWithErrors++;
            else
                tasksDownloading++;
            //BBLog(@"downloading");
        } else if (task.taskState == 2) {
            // downloaded
            //BBLog(@"downloaded");
            taskCount++;
            if (task.activeTaskSchedulerState == 2) {
                runningTaskCount++;
                //BBLog(@"runningTask");
            }
            //BBLog(@"%@", [task debugDescription]);
            remainingTimeEstimate += task.estimatedCPUTimeRemaining;
        } else if (task.taskState == 3) {
            // compute error
            tasksWithErrors++;
            //BBLog(@"%@compute error", report);
        } else if (task.taskState == 4) {
            // uploading 
            tasksToReport++;
            //BBLog(@"%@uploading", report);
        } else if (task.taskState == 5) {
            // uploaded
            //BBLog(@"%@uploaded", report);
        } else if (task.taskState == 6) {
            // aborted
            tasksAborted++;
            //BBLog(@"%@aborted", report);
        }
        return YES;
    }
    return NO;
}


- (void)clearTaskInfo
{
    taskCount             = 0;
    runningTaskCount      = 0;
    remainingTimeEstimate = 0;
    tasksDownloading      = 0;
    tasksToReport         = 0;
    tasksWithErrors       = 0;
    tasksAborted          = 0;
    [tasks removeAllObjects];
}


- (void)setUserCreateTime:(double)createTime
{
    userCreateTime = [[NSDate dateWithTimeIntervalSince1970:createTime] timeIntervalSinceReferenceDate];
}


- (void)addURL:(BOINCURL *)url
{
    if (url)
        [boincURLs addObject:url];
}


- (void)addURLs:(NSArray *)urls
{
    [self addDefaultProjectURL];
    
    for (id object in urls) 
        if ([object isKindOfClass:[BOINCURL class]])
            [boincURLs addObject:object];
        else if ([object isKindOfClass:[NSArray class]])
            for (id subObject in object)
                if ([subObject isKindOfClass:[BOINCURL class]])
                    [boincURLs addObject:subObject];
}


- (void)addPlatform:(BOINCPlatform *)platform
{
    if (platform)
        [platforms addObject:platform];
}


// if there are no urls then add the project as one
- (void)addDefaultProjectURL
{
    //  all projects have a default link based on the projectName and masterURL
    BOINCURL *projectURL = [[BOINCURL alloc] initWithName:projectName url:masterURL];
    if (projectURL)
        [boincURLs addObject:projectURL];
    [projectURL release];
}


- (BOOL)hasSameURL:(NSString *)url
{
    if ([self.masterURL isEqualToString:url])
        return YES;
    return NO;
}


- (void)updateWithProject:(BOINCProject *)project
{
    if (!project)
        return;
    if (self == project)
        return;
    
    self.projectName                 = project.projectName;
    self.masterURL                   = project.masterURL;
    self.userName                    = project.userName;
    self.teamName                    = project.teamName;
    self.hostVenue                   = project.hostVenue;
    self.userTotalCredit             = project.userTotalCredit;
    self.userRAC                     = project.userRAC;
    self.hostTotalCredit             = project.hostTotalCredit;
    self.hostRAC                     = project.hostRAC;
    self.shouldNotRequestWork        = project.shouldNotRequestWork;
    self.isSuspended                 = project.isSuspended;
    self.detachWhenDone              = project.detachWhenDone;
    self.isAttachedViaAccountManager = project.isAttachedViaAccountManager;
    userCreateTime                   = project.userCreateTime;
    
    [boincURLs release];
    boincURLs = [project.boincURLs mutableCopy];
    if ([boincURLs count] == 0)
        [self addDefaultProjectURL];
    
    [platforms release];
    platforms = [project.platforms mutableCopy];
    
    [self clearTaskInfo];
    
    if ([hostCreditMilestone hasPassedMilestoneWithUpdatedValue:self.hostTotalCredit]) {
        // send a NSNotification
        BBLog(@"project %@ at host %@ total credit %f has passed a milestone %@", projectName, client.fullName, hostTotalCredit, hostCreditMilestone.formattedPreviousMilestone);
        if (self.client) {
            NSDictionary *notificationDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                              self,        kBOINCProjectKey, 
                                              self.client, kBOINCHostKey, 
                                              nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:kBOINCHostCreditMilestoneNotification object:notificationDict];
        }
    }
    
    if ([userCreditMilestone hasPassedMilestoneWithUpdatedValue:self.userTotalCredit]) {
        // send a NSNotification
        BBLog(@"project %@ at user total credit %f has passed a milestone %@", projectName, userTotalCredit, userCreditMilestone.formattedPreviousMilestone);
        NSDictionary *notificationDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                          self,        kBOINCProjectKey, 
                                          self.client, kBOINCHostKey, 
                                          nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kBOINCUserCreditMilestoneNotification object:notificationDict];
    }
}


- (NSString *)remainingTimeString
{
    unsigned long totalTimeRemaining = (unsigned long) self.remainingTimeEstimate;
    
    if (totalTimeRemaining == 0)
        return NSLocalizedString(@"--", @"No time"); // time over and out
    
    NSMutableString *timeString = [NSMutableString string];
    
    // "#d " days
    unsigned long daysRemaing = totalTimeRemaining / (24 * 60 * 60);
    if (daysRemaing > 0)
        [timeString appendString:[NSLocalizedString(@"#d ", @"Day format with initial") stringByReplacingOccurrencesOfString:@"#" withString:[NSString stringWithFormat:@"%u", daysRemaing]]];
    
    
    // "#h " hours
    unsigned long hoursRemaing = (totalTimeRemaining / (60 * 60)) % 24; 
    if ((daysRemaing > 0) || (hoursRemaing > 0))
        [timeString appendString:[NSLocalizedString(@"#h ", @"Hour format with initial") stringByReplacingOccurrencesOfString:@"#" withString:[NSString stringWithFormat:@"%u", hoursRemaing]]];
    
    
    // "#m " minutes
    unsigned long minutesRemaing = (totalTimeRemaining / 60) % 60;
    if ((daysRemaing > 0) || (hoursRemaing > 0) || (minutesRemaing > 0))
        [timeString appendString:[NSLocalizedString(@"#m ", @"Minute format with initial") stringByReplacingOccurrencesOfString:@"#" withString:[NSString stringWithFormat:@"%u", minutesRemaing]]];
    
    
    // "#s" seconds
    unsigned long secondsRemaing = totalTimeRemaining % 60;
    if ((daysRemaing > 0) || (hoursRemaing > 0) || (minutesRemaing > 0) || (secondsRemaing > 0))
        [timeString appendString:[NSLocalizedString(@"#s ", @"Second format with initial") stringByReplacingOccurrencesOfString:@"#" withString:[NSString stringWithFormat:@"%u", secondsRemaing]]];
    
    
    // just passing the time...
    return [[timeString copy] autorelease];
}


- (NSArray *)statusMessages
{
    NSMutableArray *statusMessages = [NSMutableArray array];
    
    if (self.isSuspended)
        [statusMessages addObject:NSLocalizedString(@"Suspended by user", @"Project Status: Suspended by user")];
    
    if (self.shouldNotRequestWork)
        [statusMessages addObject:NSLocalizedString(@"Won't get new tasks", @"Project Status: Won't get new tasks")];
    
    //    if (self.hasEnded)
    //        [statusMessages addObject:NSLocalizedString(@"Project ended - OK to detach", @"Project Status: Project ended - OK to detach")];
    
    if (self.detachWhenDone)
        [statusMessages addObject:NSLocalizedString(@"Will detach when tasks done", @"Project Status: Will detach when tasks done")];
    
    //    if (self.hasPendingSchedulerRPC)
    //        [statusMessages addObject:NSLocalizedString(@"Scheduler request pending", @"Project Status: Scheduler request pending")];
    
    //    if (self.hasSchedulerRPCInProgress)
    //        [statusMessages addObject:NSLocalizedString(@"Scheduler request in progress", @"Project Status: Scheduler request in progress")];
    
    // TODO: add the Communication deferred message using <min_rpc_time>
    
    return statusMessages;
}


- (NSString *)fullStatusMessage
{
    NSArray *statusMessages = [self statusMessages];
    
    if ([statusMessages count] == 0)
        return @"";
    
    if ([statusMessages count] == 1)
        return (NSString *)[statusMessages indexOfObject:0];
    
    NSMutableString *statusMessage = [NSMutableString string];
    NSString *seperator = @"";
    for (NSString *message in statusMessages) {
        [statusMessage appendFormat:@"%@%@", seperator, message];
        seperator = @", ";
    }
    
    return statusMessage;
}


- (void)finishedXMLParsing
{
    if ([boincURLs count] == 0)
        [self addDefaultProjectURL];
    
    self.userCreditMilestone = [BOINCCreditMilestone milestoneForValue:userTotalCredit];
    self.hostCreditMilestone = [BOINCCreditMilestone milestoneForValue:hostTotalCredit];
}



///////////////////////////////////////////////////////////
#pragma mark -
#pragma mark <BBXMLModelObject> protocol method

+ (BBXMLParsingDescription *)xmlParsingDescription
{
    static BBXMLParsingDescription *parseDescription = nil;
    if (parseDescription) 
        return parseDescription;
    
    parseDescription = [[BBXMLParsingDescription alloc] initWithTarget:self];   
    [parseDescription addStringSelector:   @selector(setProjectName:)                 forElement:@"project_name"];
    [parseDescription addStringSelector:   @selector(setMasterURL:)                   forElement:@"master_url"];
    [parseDescription addStringSelector:   @selector(setUserName:)                    forElement:@"user_name"];
    [parseDescription addStringSelector:   @selector(setTeamName:)                    forElement:@"team_name"];
    [parseDescription addStringSelector:   @selector(setHostVenue:)                   forElement:@"host_venue"];
    [parseDescription addNSIntegerSelector:@selector(setHostID:)                      forElement:@"hostid"];
    [parseDescription addDoubleSelector:   @selector(setUserTotalCredit:)             forElement:@"user_total_credit"];
    [parseDescription addDoubleSelector:   @selector(setUserRAC:)                     forElement:@"user_expavg_credit"];
    [parseDescription addDoubleSelector:   @selector(setHostTotalCredit:)             forElement:@"host_total_credit"];
    [parseDescription addDoubleSelector:   @selector(setHostRAC:)                     forElement:@"host_expavg_credit"];
    [parseDescription addBoolSelector:     @selector(setShouldNotRequestWork:)        forElement:@"dont_request_more_work"];
    [parseDescription addBoolSelector:     @selector(setIsSuspended:)                 forElement:@"suspended_via_gui"];
    [parseDescription addBoolSelector:     @selector(setDetachWhenDone:)              forElement:@"detach_when_done"];
    [parseDescription addBoolSelector:     @selector(setIsAttachedViaAccountManager:) forElement:@"attached_via_acct_mgr"];
    [parseDescription addDoubleSelector:   @selector(setUserCreateTime:)              forElement:@"user_create_time"];
    [parseDescription addNSIntegerSelector:@selector(setResourceShare:)               forElement:@"resource_share"];
    
    NSDictionary *ifTeamDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [BOINCURL class], @"gui_url", 
                                      nil];
    NSDictionary *guiUrlsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [BOINCURL class], @"gui_url", 
                                       ifTeamDictionary, @"ifteam", 
                                       nil];
    [parseDescription addArraySelector:@selector(addURLs:) withClassDictionary:guiUrlsDictionary forElement:@"gui_urls"];
    
    [parseDescription addParsingCompletionSelector:@selector(finishedXMLParsing)];
    
    return parseDescription;
}



///////////////////////////////////////////////////////////
#pragma mark -
#pragma mark BOINCProject debug

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"\n%@", [self debugDescriptionWithIndent:0]];
}


- (NSString *)debugDescriptionWithIndent:(NSInteger)indent
{
    NSMutableString *theDescription = [NSMutableString string];
    
    NSMutableString *indentString = [NSMutableString string];
    for (NSInteger i = 0; i < indent; i++)
        [indentString appendString:@"    "];
    
    [theDescription appendFormat:@"%@%@ <%p>\n", indentString, [self className], self];
    [theDescription appendFormat:@"%@    projectName           = %@\n", indentString, self.projectName];
    [theDescription appendFormat:@"%@    masterURL             = %@\n", indentString, self.masterURL];
    [theDescription appendFormat:@"%@    userName              = %@\n", indentString, self.userName];
    [theDescription appendFormat:@"%@    userTotalCredit       = %f\n", indentString, self.userTotalCredit];
    [theDescription appendFormat:@"%@    userRAC               = %f\n", indentString, self.userRAC];
    [theDescription appendFormat:@"%@    teamName              = %@\n", indentString, self.teamName];
    [theDescription appendFormat:@"%@    hostVenue             = %@\n", indentString, self.hostVenue];
    [theDescription appendFormat:@"%@    hostTotalCredit       = %f\n", indentString, self.hostTotalCredit];
    [theDescription appendFormat:@"%@    hostRAC               = %f\n", indentString, self.hostRAC];
    [theDescription appendFormat:@"%@    shouldNotRequestWork  = %@\n", indentString, self.shouldNotRequestWork ? @"YES" : @"NO"];
    [theDescription appendFormat:@"%@    isSuspended           = %@\n", indentString, self.isSuspended          ? @"YES" : @"NO"];
    [theDescription appendFormat:@"%@    taskCount             = %d\n", indentString, self.taskCount];
    [theDescription appendFormat:@"%@    runningTaskCount      = %d\n", indentString, self.runningTaskCount];
    [theDescription appendFormat:@"%@    remainingTimeEstimate = %f\n", indentString, self.remainingTimeEstimate];
    [theDescription appendFormat:@"%@    remainingTimeString   = %@\n", indentString, [self remainingTimeString]];
    
    [theDescription appendFormat:@"%@    userCreditMilestone\n", indentString];
    [theDescription appendString:[userCreditMilestone debugDescriptionWithIndent:indent + 2]];
    [theDescription appendFormat:@"%@    hostCreditMilestone\n", indentString];
    [theDescription appendString:[hostCreditMilestone debugDescriptionWithIndent:indent + 2]];
    
    for (BOINCURL *site in self.boincURLs)
        [theDescription appendString:[site debugDescriptionWithIndent:indent + 1]];
    
    return theDescription;
}


@end
