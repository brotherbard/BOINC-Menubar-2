//
//  BMBEditHostInformationSheet.h
//  BOINCMenubar
//
//  Created by BrotherBard on 1/1/09.
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


@class BOINCClient;
@class BOINCClientManager;



@interface BMBEditHostInformationSheet : NSWindowController
{
    BOINCClientManager *clientManager;
    
    NSTextField        *nameField;
    NSTextField        *nameRequiredError;
          
    NSTextField        *hostAddressField;
    NSTextField        *hostAddressRequiredError;
    
    BOOL                storePassword;
    NSSecureTextField  *passwordField;
    NSTextField        *passwordrequiredError;
    
    BOINCClient         *host;
    
    id                  didEndTarget;
    BOOL                _isAddingNewHost;
}
@property (nonatomic, retain) IBOutlet NSTextField       *nameField;
@property (nonatomic, retain) IBOutlet NSTextField       *nameRequiredError;

@property (nonatomic, retain) IBOutlet NSTextField       *hostAddressField;
@property (nonatomic, retain) IBOutlet NSTextField       *hostAddressRequiredError;

@property (nonatomic, assign)          BOOL               storePassword;
@property (nonatomic, retain) IBOutlet NSSecureTextField *passwordField;
@property (nonatomic, retain) IBOutlet NSTextField       *passwordrequiredError;


- (IBAction)cancelEditHost:(id)sender;
- (IBAction)confirmEditHost:(id)sender;
- (IBAction)viewFindPasswordHelp:(id)sender;
- (IBAction)viewEditHostInformationHelp:(id)sender;

- (void)beginEditHost:(BOINCClient *)client withClientManager:(id)manager forWindow:(NSWindow *)window target:(id)target;
- (void)beginAddHostInWindow:(NSWindow *)window target:(id)target withClientManager:(id)manager;


@end
