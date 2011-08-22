//
//  BOINCProject.h
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


@class BOINCTask;
@class BOINCURL;
@class BOINCProjectSummary;
@class BOINCPlatform;
@class BOINCCreditMilestone;
@class BOINCClient;


@interface BOINCProject : NSObject <BBXMLModelObject, NSCopying>
{
    BOINCClient    *client;
    
    NSString       *projectName;
    NSString       *masterURL;
    
    NSString       *userName;
    NSString       *teamName;
    NSString       *hostVenue;
    NSInteger       hostID;
    NSInteger       resourceShare;
    
    double          userTotalCredit;
    double          userRAC;
    double          hostTotalCredit;
    double          hostRAC;
    
    BOOL            shouldNotRequestWork;
    BOOL            isSuspended;
    BOOL            detachWhenDone;
    BOOL            isAttachedViaAccountManager;
    
    double          userCreateTime;
    
    NSMutableArray *tasks;
    NSMutableArray *boincURLs;
    NSMutableArray *platforms;
    
    NSInteger       taskCount;
    NSInteger       runningTaskCount;
    double          remainingTimeEstimate;
    NSInteger       tasksDownloading;
    NSInteger       tasksToReport;
    NSInteger       tasksWithErrors;
    NSInteger       tasksAborted;
    
    BOINCCreditMilestone    *hostCreditMilestone;
    BOINCCreditMilestone    *userCreditMilestone;
}
@property (nonatomic, assign)   BOINCClient    *client; // weak ref

@property (nonatomic, copy)     NSString       *projectName;
@property (nonatomic, copy)     NSString       *masterURL;

@property (nonatomic, copy)     NSString       *userName;
@property (nonatomic, copy)     NSString       *teamName;
@property (nonatomic, copy)     NSString       *hostVenue;
@property (nonatomic, assign)   NSInteger       hostID;
@property (nonatomic, assign)   NSInteger       resourceShare;

@property (nonatomic, assign)   double          userTotalCredit;
@property (nonatomic, assign)   double          userRAC;
@property (nonatomic, assign)   double          hostTotalCredit;
@property (nonatomic, assign)   double          hostRAC;

@property (nonatomic, assign)   BOOL            shouldNotRequestWork;
@property (nonatomic, assign)   BOOL            isSuspended;
@property (nonatomic, assign)   BOOL            detachWhenDone;
@property (nonatomic, assign)   BOOL            isAttachedViaAccountManager;

@property (nonatomic, assign)   double          userCreateTime;

@property (nonatomic, readonly) NSMutableArray *tasks;
@property (nonatomic, readonly) NSMutableArray *boincURLs;
@property (nonatomic, readonly) NSMutableArray *platforms;

@property (readonly)            NSInteger       taskCount;
@property (readonly)            NSInteger       runningTaskCount;
@property (readonly)            double          remainingTimeEstimate;
@property (readonly)            NSString       *remainingTimeString;
@property (readonly)            NSInteger       tasksDownloading;
@property (readonly)            NSInteger       tasksToReport;
@property (readonly)            NSInteger       tasksWithErrors;
@property (readonly)            NSInteger       tasksAborted;

@property (nonatomic, retain)   BOINCCreditMilestone *hostCreditMilestone;
@property (nonatomic, retain)   BOINCCreditMilestone *userCreditMilestone;


- (BOOL)countTask:(BOINCTask *)task;
- (void)clearTaskInfo;
- (void)addURL:(BOINCURL *)url;
- (void)addPlatform:(BOINCPlatform *)platform;
- (void)addDefaultProjectURL;

- (BOOL)hasSameURL:(NSString *)url;
- (void)updateWithProject:(BOINCProject *)project;

- (NSString *)remainingTimeString;

- (NSString *)debugDescription;
- (NSString *)debugDescriptionWithIndent:(NSInteger)indent;

@end
