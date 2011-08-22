//
//  BMBGeneralPrefsController.m
//  BOINCMenubar
//
//  Created by BrotherBard on 4/13/08.
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

#import "BMBGeneralPrefsController.h"
#import "BMBAppController.h"
#import "BBAppSessionLoginState.h"

// TODO: add a Start BOINC Client
// When starting BOINCMenubar 2: [x] Start BOINC Client

//////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BMBGeneralPrefsController

@synthesize appLoginState;


- (id)init
{
    self = [super initWithNibName:@"BMBGeneralPreferences" bundle:nil];
    if (!self) return nil;
    
    return self;
}
    



#pragma mark BMB_ViewController_Category methods

static const void *sessionLoginListContext;

- (void)BMB_contentViewWillLoad
{
    [[BBAppSessionLoginState sharedController] addObserver:self 
                                                forKeyPath:@"isAppInSessionLoginList" 
                                                   options:NSKeyValueObservingOptionInitial 
                                                   context:&sessionLoginListContext];
}


- (void)BMB_contentViewDidUnload
{
    [[BBAppSessionLoginState sharedController] removeObserver:self 
                                                   forKeyPath:@"isAppInSessionLoginList"];
}


#pragma mark KVO Methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == &sessionLoginListContext) {
        // the state of isAppInSessionLoginList changed
        self.appLoginState = [[BBAppSessionLoginState sharedController] isAppInSessionLoginList];
    }
    else
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}



#pragma mark IB Action Methods

- (IBAction)toggleLoginState:(id)sender
{
    [[BBAppSessionLoginState sharedController] toggleAppSessionLoginListState];
    self.appLoginState = [[BBAppSessionLoginState sharedController] isAppInSessionLoginList];
}


- (IBAction)openGrowlPreferences:(id)sender
{
    NSString *growlPrefPath = @"/Library/PreferencePanes/Growl.prefPane";
    if ([[NSFileManager defaultManager] fileExistsAtPath:growlPrefPath])
        [[NSWorkspace sharedWorkspace] openFile:growlPrefPath];
}



@end
