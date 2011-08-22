//
//  BOINCClientStatus.h
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

#import <Cocoa/Cocoa.h>
#import "BBXMLParsingDescription.h"



@interface BOINCClientStatus : NSObject <BBXMLModelObject>
{
    int    networkStatus;
    int    amsPasswordError;
    int    taskSuspendReason;
    int    networkSuspendReason;
    int    taskMode;
    int    networkMode;
    int    permanentTaskMode;
    int    permanentNetworkMode;
    double taskModeDelay;
    double networkModeDelay;
    BOOL   disallowAttach;
    BOOL   simpleGUIOnly;
}
@property (nonatomic, assign) int    networkStatus;
@property (nonatomic, assign) int    amsPasswordError;
@property (nonatomic, assign) int    taskSuspendReason;
@property (nonatomic, assign) int    networkSuspendReason;
@property (nonatomic, assign) int    taskMode;
@property (nonatomic, assign) int    networkMode;
@property (nonatomic, assign) int    permanentTaskMode;
@property (nonatomic, assign) int    permanentNetworkMode;
@property (nonatomic, assign) double taskModeDelay;
@property (nonatomic, assign) double networkModeDelay;
@property (nonatomic, assign) BOOL   disallowAttach;
@property (nonatomic, assign) BOOL   simpleGUIOnly;

@property (readonly) NSString *taskSuspendedReasonDescription;

- (BOOL)didStateChange:(BOINCClientStatus *)compareStatus;


- (NSString *)debugDescriptionWithIndent:(NSInteger)indent;
- (NSString *)debugDescription;


@end
