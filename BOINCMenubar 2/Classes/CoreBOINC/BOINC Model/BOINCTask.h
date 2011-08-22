//
//  BOINCTask.h
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

#import <Cocoa/Cocoa.h>
#import "BBXMLParsingDescription.h"


@interface BOINCTask : NSObject <BBXMLModelObject, NSCopying>
{
    NSString *name;
    NSString *workunitName;
    int       versionNumber;
    NSString *projectURL;
    int       taskState;
    int       exitStatus;
    double    estimatedCPUTimeRemaining;
    double    finalCPUTime;
    double    reportDeadline;
    BOOL      isReadyToReport;
    
    // active task info
    int       activeTaskSchedulerState;
    int       appVersionNumber;
    int       slot;
    int       activeTaskState;
    double    checkpointCPUTime;
    double    fractionDone;
    double    currentCPUTime;
    double    elapsedTime;
    double    swapSize;
    double    workingSetSize;
    double    workingSetSizeSmoothed;
    double    pageFaultRate;
    BOOL      isWaitingForRAM; 
    BOOL      isWaitingForSharedRAM;
    BOOL      isHighPriority;
    BOOL      hasGraphicsSupport;
}
@property (nonatomic, copy)   NSString *name;
@property (nonatomic, copy)   NSString *workunitName;
@property (nonatomic, assign) int       versionNumber;
@property (nonatomic, copy)   NSString *projectURL;
@property (nonatomic, assign) int       taskState;
@property (nonatomic, assign) int       exitStatus;
@property (nonatomic, assign) double    estimatedCPUTimeRemaining;
@property (nonatomic, assign) double    finalCPUTime;
@property (nonatomic, assign) double    reportDeadline;
@property (nonatomic, assign) BOOL      isReadyToReport;

@property (nonatomic, assign) int       activeTaskSchedulerState;
@property (nonatomic, assign) int       appVersionNumber;
@property (nonatomic, assign) int       slot;
@property (nonatomic, assign) int       activeTaskState;
@property (nonatomic, assign) double    checkpointCPUTime;
@property (nonatomic, assign) double    fractionDone;
@property (nonatomic, assign) double    currentCPUTime;
@property (nonatomic, assign) double    elapsedTime;
@property (nonatomic, assign) double    swapSize;
@property (nonatomic, assign) double    workingSetSize;
@property (nonatomic, assign) double    workingSetSizeSmoothed;
@property (nonatomic, assign) double    pageFaultRate;
@property (nonatomic, assign) BOOL      isWaitingForRAM; 
@property (nonatomic, assign) BOOL      isWaitingForSharedRAM; 
@property (nonatomic, assign) BOOL      isHighPriority;
@property (nonatomic, assign) BOOL      hasGraphicsSupport;



- (NSString *)debugDescriptionWithIndent:(NSInteger)indent;
- (NSString *)debugDescription;

@end
