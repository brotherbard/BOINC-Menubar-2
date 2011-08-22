//
//  BOINCProjectsPrefController.h
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

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>


@class BOINCActiveClientManager;
@class BOINCAttachToProjectSheet;
@class BOINCAttachToAccountManager;
@class BOINCSyncWithAccountManager;
@class BOINCProjectsSummaryTree;
@class BOINCHostSelectionController;


@interface BOINCProjectsPrefController : NSViewController 
{
    BOINCActiveClientManager     *clientManager;
    
    BOINCProjectsSummaryTree     *projectTree;
    NSString                     *preferenceForHost;
    NSTreeController             *projectTreeController;
    NSOutlineView                *projectOutlineView;
    NSView                       *mainContentView;
    NSView                       *hostSelectionView;
    BOINCHostSelectionController *hostSelectionController;
    
    NSView                       *noHostConnectedSubview;
    
    NSView                       *otherProjectsSubview;
    WebView                      *otherProjectDescriptionWebView;
    NSTextField                  *otherProjectURL;
    
    NSView                       *projectDescriptionSubview;
    WebView                      *projectDescriptionWebView;
    NSView                       *projectStatusContentView;
    
    NSView                       *accountManagerSubview;
    WebView                      *managerDescriptionWebView;
    WebView                      *managerNotesWebView;
    BOOL                          clientAttachedToAccountManager;
    
    NSView                       *detachWhenDoneSubview;
    NSView                       *joinedProjectSubview;
    NSView                       *notJoinedProjectSubview;
    NSTableView                  *platformTable;
    
    BOINCAttachToProjectSheet    *attachToProjectSheet;
    BOINCAttachToAccountManager  *attachToAccountManagerSheet;
    BOINCSyncWithAccountManager  *syncWithAccountManagerSheet;
    NSWindow                     *resetProjectSheet;
    NSWindow                     *detachProjectSheet;
    NSWindow                     *detachAfterSheet;
    NSWindow                     *detachAccountManagerSheet;
}
@property (nonatomic, retain) BOINCProjectsSummaryTree     *projectTree;
@property (nonatomic, retain)          NSString            *preferenceForHost;
@property (nonatomic, retain) IBOutlet NSTreeController    *projectTreeController;
@property (nonatomic, retain) IBOutlet NSOutlineView       *projectOutlineView;
@property (nonatomic, retain) IBOutlet NSView              *mainContentView;
@property (nonatomic, retain) IBOutlet NSView              *hostSelectionView;
@property (nonatomic, retain) BOINCHostSelectionController *hostSelectionController;

@property (nonatomic, retain) IBOutlet NSView              *noHostConnectedSubview;

@property (nonatomic, retain) IBOutlet NSView              *otherProjectsSubview;
@property (nonatomic, retain) IBOutlet WebView             *otherProjectDescriptionWebView;
@property (nonatomic, retain) IBOutlet NSTextField         *otherProjectURL;

@property (nonatomic, retain) IBOutlet NSView              *projectDescriptionSubview;
@property (nonatomic, retain) IBOutlet WebView             *projectDescriptionWebView;
@property (nonatomic, retain) IBOutlet NSView              *projectStatusContentView;

@property (nonatomic, retain) IBOutlet NSView              *accountManagerSubview;
@property (nonatomic, retain) IBOutlet WebView             *managerDescriptionWebView;
@property (nonatomic, retain) IBOutlet WebView             *managerNotesWebView;
@property (nonatomic, assign)          BOOL                 clientAttachedToAccountManager;

@property (nonatomic, retain) IBOutlet NSView              *detachWhenDoneSubview;
@property (nonatomic, retain) IBOutlet NSView              *joinedProjectSubview;
@property (nonatomic, retain) IBOutlet NSView              *notJoinedProjectSubview;
@property (nonatomic, retain) IBOutlet NSTableView         *platformTable;

@property (nonatomic, retain) IBOutlet NSWindow            *resetProjectSheet;
@property (nonatomic, retain) IBOutlet NSWindow            *detachProjectSheet;
@property (nonatomic, retain) IBOutlet NSWindow            *detachAfterSheet;
@property (nonatomic, retain) IBOutlet NSWindow            *detachAccountManagerSheet;


- (id)initWithClientManager:(id)manager;

- (IBAction)attachToProjectSummary:(id)sender;
- (IBAction)attachToProjectURL:(id)sender;
- (IBAction)attachToAccountManagerSummary:(id)sender;
- (IBAction)attachToAccountManagerURL:(id)sender;
- (IBAction)openResetProjectSheet:(id)sender;
- (IBAction)openDetachProjectSheet:(id)sender;
- (IBAction)cancelSheet:(id)sender;
- (IBAction)resetProject:(id)sender;
- (IBAction)detachProjectNow:(id)sender;
- (IBAction)detachProjectAfter:(id)sender;
- (IBAction)cancelDetachProjectAfter:(id)sender;
- (IBAction)synchronizeWithAccountManager:(id)sender;

- (IBAction)openDetachAccountManagerSheet:(id)sender;
- (IBAction)detachAccountManager:(id)sender;

- (void)reloadSummaryTree;
- (void)didEndSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;


@end

