//
//  BOINCTask.m
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

#import "BOINCTask.h"


@implementation BOINCTask

@synthesize name;
@synthesize workunitName;
@synthesize versionNumber;
@synthesize projectURL;
@synthesize taskState;
@synthesize exitStatus;
@synthesize estimatedCPUTimeRemaining;
@synthesize finalCPUTime;
@synthesize reportDeadline;
@synthesize isReadyToReport;
@synthesize activeTaskSchedulerState;
@synthesize appVersionNumber;
@synthesize slot;
@synthesize activeTaskState;
@synthesize checkpointCPUTime;
@synthesize fractionDone;
@synthesize currentCPUTime;
@synthesize elapsedTime;
@synthesize swapSize;
@synthesize workingSetSize;
@synthesize workingSetSizeSmoothed;
@synthesize pageFaultRate;
@synthesize isWaitingForRAM; 
@synthesize isWaitingForSharedRAM;
@synthesize isHighPriority;
@synthesize hasGraphicsSupport;


///////////////////////////////////////////////////////////

- (void)dealloc
{
    [name         release];
    [workunitName release];
    [projectURL   release];
    
    [super dealloc];
}



///////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSObject methods

// Equal objects must hash the same, so test the same data that is used to create the hash

- (BOOL)isEqual:(id)object
{
    if (![object isMemberOfClass:[BOINCTask class]])
        return NO;
    
    return [self.workunitName isEqualToString:((BOINCTask *)object).workunitName];
}

- (NSUInteger)hash
{
    return [self.workunitName hash];
}



///////////////////////////////////////////////////////////
#pragma mark <NSCopying>
- (id)copyWithZone:(NSZone *)zone
{
    BOINCTask *copiedTask = [[BOINCTask allocWithZone:zone] init];
    
    copiedTask.name                      = self.name;
    copiedTask.workunitName              = self.workunitName;
    copiedTask.versionNumber             = self.versionNumber;
    copiedTask.projectURL                = self.projectURL;
    copiedTask.taskState                 = self.taskState;
    copiedTask.exitStatus                = self.exitStatus;
    copiedTask.estimatedCPUTimeRemaining = self.estimatedCPUTimeRemaining;
    copiedTask.finalCPUTime              = self.finalCPUTime;
    copiedTask.reportDeadline            = self.reportDeadline;
    copiedTask.isReadyToReport           = self.isReadyToReport;
    
    copiedTask.activeTaskSchedulerState  = self.activeTaskSchedulerState;
    copiedTask.appVersionNumber          = self.appVersionNumber;
    copiedTask.slot                      = self.slot;
    copiedTask.activeTaskState           = self.activeTaskState;
    copiedTask.checkpointCPUTime         = self.checkpointCPUTime;
    copiedTask.fractionDone              = self.fractionDone;
    copiedTask.currentCPUTime            = self.currentCPUTime;
    copiedTask.elapsedTime               = self.elapsedTime;
    copiedTask.swapSize                  = self.swapSize;
    copiedTask.workingSetSize            = self.workingSetSize;
    copiedTask.workingSetSizeSmoothed    = self.workingSetSizeSmoothed;
    copiedTask.pageFaultRate             = self.pageFaultRate;
    copiedTask.isWaitingForRAM           = self.isWaitingForRAM;
    copiedTask.isWaitingForSharedRAM     = self.isWaitingForSharedRAM;
    copiedTask.isHighPriority            = self.isHighPriority;
    copiedTask.hasGraphicsSupport        = self.hasGraphicsSupport;
    
    return copiedTask;
}



///////////////////////////////////////////////////////////
#pragma mark BOINCTask methods

- (NSString *)statusString
{
    if (self.activeTaskState == 0)
        return NSLocalizedString(@"Ready to start", @"Task status: Ready to start");
    
    if (self.isWaitingForRAM)
        return NSLocalizedString(@"Waiting for memory", @"Task status: Waiting for memory");
    
    if (self.isWaitingForSharedRAM)
        return NSLocalizedString(@"Waiting for shared memory", @"Task status: Waiting for shared memory");
    
    if (self.activeTaskSchedulerState == 2) { // CPU_SCHED_SCHEDULED
        if (self.isHighPriority)
            return NSLocalizedString(@"Running, high priority", @"Task status: Running, high priority");
        
        return NSLocalizedString(@"Running", @"Task status: Running");
    }
    
    if (self.activeTaskSchedulerState == 1)  // CPU_SCHED_PREEMPTED
        return NSLocalizedString(@"Waiting to run", @"Task status: Waiting to run");
    
    if (self.activeTaskSchedulerState == 0)  // CPU_SCHED_UNINITIALIZED
        return NSLocalizedString(@"Ready to start", @"Task status: Ready to start");
    
    
    return NSLocalizedString(@"Ready to start", @"Task status: Ready to start");
}


- (void)finishedXMLParsing
{
    // based on checkin note for 5.6.21
    //    - GUI RPC: client side: if parse a RESULT and CPU is nonzero
    //               but elapsed time is zero, we must be talking to an old client; 
    //               set elapsed = CPU
    if (self.currentCPUTime && (self.elapsedTime == 0))
        self.elapsedTime = self.currentCPUTime;
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
    
    [parseDescription addStringSelector:@selector(setName:)                      forElement:@"name"];
    [parseDescription addStringSelector:@selector(setWorkunitName:)              forElement:@"wu_name"];
    [parseDescription addIntSelector:   @selector(setVersionNumber:)             forElement:@"version_num"];
    [parseDescription addStringSelector:@selector(setProjectURL:)                forElement:@"project_url"];
    [parseDescription addDoubleSelector:@selector(setEstimatedCPUTimeRemaining:) forElement:@"estimated_cpu_time_remaining"];
    [parseDescription addDoubleSelector:@selector(setFinalCPUTime:)              forElement:@"final_cpu_time"];
    [parseDescription addIntSelector:   @selector(setTaskState:)                 forElement:@"state"];
    [parseDescription addIntSelector:   @selector(setExitStatus:)                forElement:@"exit_status"];
    [parseDescription addBoolSelector:  @selector(setIsReadyToReport:)           forElement:@"ready_to_report"];
    [parseDescription addDoubleSelector:@selector(setReportDeadline:)            forElement:@"report_deadline"];
    
    [parseDescription addSkippedElement:@"active_task"];
    [parseDescription addIntSelector:   @selector(setActiveTaskState:)           forElement:@"active_task_state"];
    [parseDescription addIntSelector:   @selector(setAppVersionNumber:)          forElement:@"app_version_num"];
    [parseDescription addIntSelector:   @selector(setSlot:)                      forElement:@"slot"];
    [parseDescription addIntSelector:   @selector(setActiveTaskSchedulerState:)  forElement:@"scheduler_state"];
    [parseDescription addDoubleSelector:@selector(setCheckpointCPUTime:)         forElement:@"checkpoint_cpu_time"];
    [parseDescription addDoubleSelector:@selector(setFractionDone:)              forElement:@"fraction_done"];
    [parseDescription addDoubleSelector:@selector(setCurrentCPUTime:)            forElement:@"current_cpu_time"];
    [parseDescription addDoubleSelector:@selector(setElapsedTime:)               forElement:@"elapsed_time"];
    [parseDescription addDoubleSelector:@selector(setSwapSize:)                  forElement:@"swap_size"];
    [parseDescription addDoubleSelector:@selector(setWorkingSetSize:)            forElement:@"working_set_size"];
    [parseDescription addDoubleSelector:@selector(setWorkingSetSizeSmoothed:)    forElement:@"working_set_size_smoothed"];
    [parseDescription addDoubleSelector:@selector(setPageFaultRate:)             forElement:@"page_fault_rate"];
    [parseDescription addBoolSelector:  @selector(setIsWaitingForRAM:)           forElement:@"too_large"];
    [parseDescription addBoolSelector:  @selector(setIsWaitingForSharedRAM:)     forElement:@"needs_shmem"];
    [parseDescription addBoolSelector:  @selector(setIsHighPriority:)            forElement:@"edf_scheduled"];
    [parseDescription addBoolSelector:  @selector(setHasGraphicsSupport:)        forElement:@"supports_graphics"];
    
    [parseDescription addParsingCompletionSelector:@selector(finishedXMLParsing)];
    
    return parseDescription;
}





///////////////////////////////////////////////////////////
#pragma mark -
#pragma mark debug

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
    [theDescription appendFormat:@"%@    name                      = %@\n", indentString, self.name];
    [theDescription appendFormat:@"%@    workunitName              = %@\n", indentString, self.workunitName];
    [theDescription appendFormat:@"%@    versionNumber             = %d\n", indentString, self.versionNumber];
    [theDescription appendFormat:@"%@    projectURL                = %@\n", indentString, self.projectURL];
    [theDescription appendFormat:@"%@    estimatedCPUTimeRemaining = %f\n", indentString, self.estimatedCPUTimeRemaining];
    [theDescription appendFormat:@"%@    finalCPUTime              = %f\n", indentString, self.finalCPUTime];
    [theDescription appendFormat:@"%@    taskState                 = %d\n", indentString, self.taskState];
    [theDescription appendFormat:@"%@    exitStatus                = %d\n", indentString, self.exitStatus];
    [theDescription appendFormat:@"%@    isReadyToReport           = %@\n", indentString, self.isReadyToReport ? @"YES" : @"NO"];
    [theDescription appendFormat:@"%@    reportDeadline            = %f\n", indentString, self.reportDeadline];
    
    if (self.activeTaskState) {
        [theDescription appendFormat:@"%@    Active Task Info\n", indentString];
        [theDescription appendFormat:@"%@        activeTaskState          = %d\n", indentString, self.activeTaskState];
        [theDescription appendFormat:@"%@        appVersionNumber         = %d\n", indentString, self.appVersionNumber];
        [theDescription appendFormat:@"%@        slot                     = %d\n", indentString, self.slot];
        [theDescription appendFormat:@"%@        activeTaskSchedulerState = %d\n", indentString, self.activeTaskSchedulerState];
        [theDescription appendFormat:@"%@        checkpointCPUTime        = %f\n", indentString, self.checkpointCPUTime];
        [theDescription appendFormat:@"%@        fractionDone             = %f\n", indentString, self.fractionDone];
        [theDescription appendFormat:@"%@        currentCPUTime           = %f\n", indentString, self.currentCPUTime];
        [theDescription appendFormat:@"%@        elapsedTime              = %f\n", indentString, self.elapsedTime];
        [theDescription appendFormat:@"%@        swapSize                 = %f\n", indentString, self.swapSize];
        [theDescription appendFormat:@"%@        workingSetSize           = %f\n", indentString, self.workingSetSize];
        [theDescription appendFormat:@"%@        workingSetSizeSmoothed   = %f\n", indentString, self.workingSetSizeSmoothed];
        [theDescription appendFormat:@"%@        pageFaultRate            = %f\n", indentString, self.pageFaultRate];
        [theDescription appendFormat:@"%@        isWaitingForRAM          = %@\n", indentString, self.isWaitingForRAM       ? @"YES" : @"NO"];
        [theDescription appendFormat:@"%@        isWaitingForSharedRAM    = %@\n", indentString, self.isWaitingForSharedRAM ? @"YES" : @"NO"];
        [theDescription appendFormat:@"%@        hasGraphicsSupport       = %@\n", indentString, self.hasGraphicsSupport    ? @"YES" : @"NO"];
    }
    
    
    return theDescription;
}


@end
