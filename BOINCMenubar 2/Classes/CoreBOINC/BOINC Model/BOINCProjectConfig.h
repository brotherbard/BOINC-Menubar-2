//
//  BOINCProjectConfig.h
//  BOINCMenubar
//
//  Created by BrotherBard on 3/22/09.
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

#import <Cocoa/Cocoa.h>
#import "BBXMLParsingDescription.h"


@interface BOINCProjectConfig : NSObject <BBXMLModelObject>
{
    NSString       *projectName;
    NSString       *masterURL;
    NSString       *rpcPrefix;
    int             minPasswordLength;
    
    BOOL            clientAccountCreationDisabled;
    BOOL            accountCreationDisabled;
    BOOL            webStopped;
    BOOL            schedulerStopped;
    BOOL            usesUsername;
    BOOL            accountManager;
    
    NSString       *termsOfUse;
    NSMutableArray *platforms;
    
    int             errorNumber;
    NSString       *errorMessage;
}
@property (nonatomic, copy)   NSString       *projectName;
@property (nonatomic, copy)   NSString       *masterURL;
@property (nonatomic, copy)   NSString       *rpcPrefix;
@property (nonatomic, assign) int             minPasswordLength;

@property (nonatomic, assign) BOOL            clientAccountCreationDisabled;
@property (nonatomic, assign) BOOL            accountCreationDisabled;
@property (nonatomic, assign) BOOL            webStopped;
@property (nonatomic, assign) BOOL            schedulerStopped;
@property (nonatomic, assign) BOOL            usesUsername;
@property (nonatomic, assign) BOOL            accountManager;

@property (nonatomic, copy)   NSString       *termsOfUse;
@property (nonatomic, retain) NSMutableArray *platforms;

@property (nonatomic, assign) int             errorNumber;
@property (nonatomic, copy)   NSString       *errorMessage;


- (NSString *)debugDescriptionWithIndent:(NSInteger)indent;
- (NSString *)debugDescription;

@end
