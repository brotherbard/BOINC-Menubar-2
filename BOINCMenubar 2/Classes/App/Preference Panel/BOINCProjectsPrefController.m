//
//  BOINCProjectsPrefController.m
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

#import "BOINCProjectsPrefController.h"
#import "BOINCAttachToProjectSheet.h"
#import "BOINCAttachToAccountManager.h"
#import "BOINCSyncWithAccountManager.h"

#import "BOINCProjectsSummaryTree.h"
#import "BOINCActiveClientManager.h"
#import "BOINCClientManager.h"
#import "BOINCHostSelectionController.h"


// TODO: cache images 
//       possibly use NSURLRequest's NSURLRequestReturnCacheDataElseLoad
//       or save images to a local file and update with a contextual menu item on the image
//       (note: the boinc admins removed the image tags from the projects, it's now only in the account manager's)
// TODO: download favicons of attached projects
//       use in the titles of the source list


#pragma mark -
#pragma mark Constants

// for NSUserDefaults keys
NSString * const kBMBAllProjectsSourceListState = @"BMBAllProjectsSourceListState";
NSString * const kBMBAllProjectsSourceListSelectedSummary = @"selectedSummary";
NSString * const kBMBAllProjectsSourceListExpandedGroups = @"expandedGroups";
NSString * const kBMBAllProjectsSourceListHostGroupNode = @"BMBHostGroupNode";




#pragma mark -

// Private methods
@interface BOINCProjectsPrefController (BMBPrivate)
- (void)updateProjectPreferenceViews;
- (void)switchContentView:(NSView *)contentView toSubview:(NSView *)newView;

- (void)updateSummaries;
- (void)updateMainContentView;
- (BMBProjectNode *)selectedNode;
- (NSString *)titleOfCurrentSelection;
- (void)saveOutlineState;
- (void)restoreOutlineState;
- (void)expandGroups:(NSArray *)groups;
- (void)selectProjectSummary:(NSString *)summaryTitle;
- (void)defaultExpansion;
- (void)defaultSelection;
- (NSArray *)groupItems;
- (NSString *)notesHTMLDescription;
@end




#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BOINCProjectsPrefController


@synthesize projectTree;
@synthesize preferenceForHost;
@synthesize projectTreeController;
@synthesize projectOutlineView;
@synthesize mainContentView;
@synthesize hostSelectionView;
@synthesize hostSelectionController;

@synthesize noHostConnectedSubview;

@synthesize otherProjectsSubview;
@synthesize otherProjectDescriptionWebView;
@synthesize otherProjectURL;

@synthesize projectDescriptionSubview;
@synthesize projectDescriptionWebView;
@synthesize projectStatusContentView;

@synthesize accountManagerSubview;
@synthesize managerDescriptionWebView;
@synthesize managerNotesWebView;
@synthesize clientAttachedToAccountManager;

@synthesize detachWhenDoneSubview;
@synthesize joinedProjectSubview;
@synthesize notJoinedProjectSubview;
@synthesize platformTable;

@synthesize resetProjectSheet;
@synthesize detachProjectSheet;
@synthesize detachAfterSheet;
@synthesize detachAccountManagerSheet;



#pragma mark Public methods

- (id)initWithClientManager:(id)manager
{
    self = [super initWithNibName:@"BOINCProjectsPreferences" bundle:nil];
    if (!self) return nil;
    
    clientManager = manager;
    
    return self;
}


- (void)awakeFromNib
{   
    hostSelectionController = [[BOINCHostSelectionController hostSelectionControllerWithClientManager:clientManager] retain];
    [hostSelectionView addSubview:[hostSelectionController view]];
        
    // make the web view's background transparent so the content looks like part of the dialog (for some reason this can't be set in IB)
    [otherProjectDescriptionWebView setDrawsBackground:NO];
    [projectDescriptionWebView      setDrawsBackground:NO];
    [managerDescriptionWebView      setDrawsBackground:NO];
    [managerNotesWebView            setDrawsBackground:NO];
    
    // an attempt to make the cache last longer for downloaded images (should probably deal with it internally)
    [[projectDescriptionWebView preferences] setCacheModel:WebCacheModelPrimaryWebBrowser];
    [[managerDescriptionWebView preferences] setCacheModel:WebCacheModelPrimaryWebBrowser];
    
    // the user agent to send with html requests by the WebView
    NSString *agent = [NSString stringWithFormat:@"%@ %@", 
                       [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleName"], 
                       [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleVersion"]];
    [otherProjectDescriptionWebView setApplicationNameForUserAgent:agent];
    [projectDescriptionWebView      setApplicationNameForUserAgent:agent];
    [managerDescriptionWebView      setApplicationNameForUserAgent:agent];
    [managerNotesWebView            setApplicationNameForUserAgent:agent];
    
    [projectOutlineView setTarget:self];
    [projectOutlineView setAction:@selector(clickInOutlineView)];
    
    [self.projectTree resetUpdateTime];
}


- (void)dealloc
{
    clientManager = nil;
    
    [projectTree                    release];
    [preferenceForHost              release];
    [projectTreeController          release];
    [projectOutlineView             release];
    [mainContentView                release];
    
    [noHostConnectedSubview         release];
    
    [otherProjectsSubview           release];
    [otherProjectDescriptionWebView release];
    [otherProjectURL                release];
    
    [projectDescriptionSubview      release];
    [projectDescriptionWebView      release];
    [projectStatusContentView       release];
    
    [accountManagerSubview          release];
    [managerDescriptionWebView      release];
    [managerNotesWebView            release];
    
    [detachWhenDoneSubview          release];
    [joinedProjectSubview           release];
    [notJoinedProjectSubview        release];
    [platformTable                  release];
    
    [attachToProjectSheet           release];
    [resetProjectSheet              release];
    [detachProjectSheet             release];
    [detachAfterSheet               release];
    [detachAccountManagerSheet      release];
    
    [super dealloc];
}



// update the project summary information but don't change the order in the outline view
- (void)reloadSummaryTree
{   
    [self.projectTree resetUpdateTime];
    self.projectTree.shouldSkipRandomizingProjects = YES;
    
    [self saveOutlineState];
    [self updateSummaries];
}



#pragma mark BMB_ViewController_Category methods

static const void *activeClientContext;
static const void *allProjectsListContext;

- (void)BMB_contentViewWillLoad
{
    [clientManager addObserver:self forKeyPath:@"activeClient.isConnected"               options:0 context:&activeClientContext];
    [clientManager addObserver:self forKeyPath:@"activeClient.lastAllProjectsListUpdate" options:0 context:&allProjectsListContext];
    
    // if the "Join unlisted project" node is selected then select the text field instead of the outline
    if ([[self selectedNode] isKindOfClass:[BMBOtherProjectNode class]])
        [[[self view] window] makeFirstResponder:otherProjectURL];
    
    [clientManager.activeClient requestAllProjectsListUpdate];
}

- (void)BMB_contentViewDidUnload
{
    [clientManager removeObserver:self forKeyPath:@"activeClient.isConnected"];
    [clientManager removeObserver:self forKeyPath:@"activeClient.lastAllProjectsListUpdate"];
    
    [self saveOutlineState];
    [[[self view] window] makeFirstResponder:nil];
}



#pragma mark KVO Methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == &activeClientContext) {
        if (clientManager.activeClient.isConnected) 
            [clientManager.activeClient requestAllProjectsListUpdate];
        else 
            [self updateProjectPreferenceViews];
        return;
    }
    
    if (context == &allProjectsListContext) {
        if (clientManager.activeClient.isConnected)
            [self updateProjectPreferenceViews];
        return;
    }
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}



#pragma mark Project List NSOutlineView delegate methods

//   the webview has no bindings so it needs to be set in code, other controls in the views are set with bindings in IB
- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{   
    [self updateMainContentView];
}


//  only the children nodes can be selected, special group nodes cannot
- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
{
    return ([[item representedObject] isLeaf]);
}


//  indicate special group items for NSOutlineViews drawing code
-(BOOL)outlineView:(NSOutlineView*)outlineView isGroupItem:(id)item
{
    return (![[item representedObject] isLeaf]);
}


- (BOOL)outlineView:(NSOutlineView *)outlineView shouldCollapseItem:(id)item
{
    NSArray *nodes = [projectTreeController selectedNodes];
    if ([nodes count] && ([[nodes objectAtIndex:0] parentNode] != item))
        return YES;
    
    return NO;
}



#pragma mark Supported Platforms NSTableView delegate methods

//  do not allow selecting anything in the Supported Platforms table (the table is informational only)
- (BOOL)tableView:(NSTableView *)table shouldSelectRow:(NSInteger)rowIndex
{
    return NO;
}



#pragma mark click action

- (void)clickInOutlineView
{
    NSTreeNode *treeNode = [projectOutlineView itemAtRow:[projectOutlineView clickedRow]];
    
    if (treeNode == nil)
        return;
    
    if (![treeNode isLeaf]) {
        if ([projectOutlineView isItemExpanded:treeNode]) {
            // don't allow the group node of the selected node to collapse (that would cause an empty selection)
            NSArray *nodes = [projectTreeController selectedNodes];
            if ([nodes count] && ([[nodes objectAtIndex:0] parentNode] != treeNode)) {
                [projectOutlineView collapseItem:treeNode];
            }
        }
        else
            [projectOutlineView expandItem:treeNode];
    }
}


#pragma mark <WebPolicyDelegate> 

/*
 <WebPolicyDelegate> method
 If the user clicks a link it loads the url in an external web browser.
 If a page is loaded progammatically (via loadHTMLString:baseURL: for example) then that link is opened by the WebView.
 */

- (void)webView:(WebView *)sender decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id <WebPolicyDecisionListener>)listener
{   
    if ([[actionInformation objectForKey:WebActionNavigationTypeKey] intValue] != WebNavigationTypeOther) {
        [listener ignore];
        [[NSWorkspace sharedWorkspace] openURL:[request URL]];
    }
    else
        [listener use];
}



#pragma mark <WebUIDelegate>

/*
 <WebUIDelegate> method
 Only allow the "Copy Link" item in the contextual menu (this only happens when the element is a link).
 The other menu items don't make any sense in this WebView.
 */

- (NSArray *)webView:(WebView *)sender contextMenuItemsForElement:(NSDictionary *)element defaultMenuItems:(NSArray *)defaultMenuItems
{   
    for (NSMenuItem *item in defaultMenuItems)
        if ([item tag] == WebMenuItemTagCopyLinkToClipboard) 
            return [NSArray arrayWithObject:item];
    
    return nil;
}



#pragma mark <WebResourceLoadDelegate>

/*
 <WebResourceLoadDelegate> method
 The only http resources in the webviews are the project image urls.
 Set the cache policy to use the cache regardless of age but to load the image if it doesn't exist yet. This will stop BMB from downloading the images each time the user selects the project. (however I'm not sure how long the cache is kept, an hour? a day? a week?)
 */

- (NSURLRequest *)webView:(WebView *)sender resource:(id)identifier willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse fromDataSource:(WebDataSource *)dataSource
{
    if ([[[request URL] absoluteString] hasPrefix:@"http:"]) {
        NSMutableURLRequest *myRequest = [request mutableCopy];
        
        [myRequest setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
        
        return [myRequest autorelease];
    }
    
    return request;
}



#pragma mark NSApp didEndSheet: modalDelegate 

- (void)didEndSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    [sheet orderOut:self];
}



#pragma mark IBActions

- (IBAction)attachToProjectSummary:(id)sender
{   
    if (!attachToProjectSheet)
        attachToProjectSheet = [[BOINCAttachToProjectSheet alloc] initWithWindowNibName:@"BOINCAttatchToProjectSheet"];
    
    [attachToProjectSheet beginAttachProjectSheetInWindow:[[self view] window]
                                                forClient:clientManager.activeClient
                                       withProjectSummary:(BOINCProjectSummary *)[[self selectedNode] summary]];
    [[attachToProjectSheet window] setDelegate:self];
}


// used to attach to projects not in the all projects list
- (IBAction)attachToProjectURL:(id)sender
{   
    if (!attachToProjectSheet)
        attachToProjectSheet = [[BOINCAttachToProjectSheet alloc] initWithWindowNibName:@"BOINCAttatchToProjectSheet"];
    
    [attachToProjectSheet beginAttachProjectSheetInWindow:[[self view] window]
                                                forClient:clientManager.activeClient
                                                  withURL:[otherProjectURL stringValue]];
    [[attachToProjectSheet window] setDelegate:self];
}


- (IBAction)attachToAccountManagerSummary:(id)sender
{   
    if (!attachToAccountManagerSheet)
        attachToAccountManagerSheet = [[BOINCAttachToAccountManager alloc] initWithWindowNibName:@"BOINCAttachToAccountManager"];
    
    [attachToAccountManagerSheet beginAttachAccountManagerSheetInWindow:[[self view] window]
                                                              forClient:clientManager.activeClient
                                              withAccountManagerSummary:(BOINCAccountManagerSummary *)[[self selectedNode] managerSummary]];
    [[attachToAccountManagerSheet window] setDelegate:self];
}


// used to attach to projects not in the all projects list
- (IBAction)attachToAccountManagerURL:(id)sender
{   
    if (!attachToAccountManagerSheet)
        attachToAccountManagerSheet = [[BOINCAttachToAccountManager alloc] initWithWindowNibName:@"BOINCAttachToAccountManager"];
    
    [attachToAccountManagerSheet beginAttachAccountManagerSheetInWindow:[[self view] window]
                                                              forClient:clientManager.activeClient
                                                                withURL:[otherProjectURL stringValue]];
    [[attachToAccountManagerSheet window] setDelegate:self];
}


- (IBAction)openResetProjectSheet:(id)sender
{
    // ask the user to confirm they want to reset the project
    [NSApp beginSheet:resetProjectSheet
       modalForWindow:[[self view] window] 
        modalDelegate:self 
       didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) 
          contextInfo:nil];
}


- (IBAction)openDetachProjectSheet:(id)sender
{
    if ([[(BOINCProjectSummary *)[[self selectedNode] summary] project] remainingTimeEstimate])
        // if there are uncompleted tasks ask the user to confirm if they want to detach now or detach when done
        [NSApp beginSheet:detachAfterSheet
           modalForWindow:[[self view] window] 
            modalDelegate:self 
           didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) 
              contextInfo:nil];
    else
        // if there are no tasks, then just ask the user to confirm they want to detach
        [NSApp beginSheet:detachProjectSheet
           modalForWindow:[[self view] window] 
            modalDelegate:self 
           didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) 
              contextInfo:nil];
    
}


- (IBAction)openDetachAccountManagerSheet:(id)sender
{
    // ask the user to confirm they want to detach from the account manager
    [NSApp beginSheet:detachAccountManagerSheet
       modalForWindow:[[self view] window] 
        modalDelegate:self 
       didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) 
          contextInfo:nil];
}


// action for the cancel button in all of the sheets except the Attach to Project and Account Manager sheets
- (IBAction)cancelSheet:(id)sender
{
    [NSApp endSheet:[sender window]];
}


- (IBAction)resetProject:(id)sender
{
    [clientManager.activeClient performRPCOperation:kTagProjectReset onProject:[(BOINCProjectSummary *)[[self selectedNode] summary] project]];
    
    [NSApp endSheet:[sender window]];
}


- (IBAction)detachProjectNow:(id)sender
{
    [clientManager.activeClient performRPCOperation:kTagProjectDetach onProject:[(BOINCProjectSummary *)[[self selectedNode] summary] project]];
    
    [self.projectTree resetUpdateTime];
    self.projectTree.shouldSkipRandomizingProjects = YES;
    
    [NSApp endSheet:[sender window]];
}


- (IBAction)detachProjectAfter:(id)sender
{
    [clientManager.activeClient performRPCOperation:kTagProjectDetachWhenDone onProject:[(BOINCProjectSummary *)[[self selectedNode] summary] project]];
    
    [self reloadSummaryTree];
    
    [NSApp endSheet:[sender window]];
}


// don't bother showing a sheet, just cancel the detach directly, they can always detach(after) again
- (IBAction)cancelDetachProjectAfter:(id)sender
{
    [clientManager.activeClient performRPCOperation:kTagProjectDontDetachWhenDone onProject:[(BOINCProjectSummary *)[[self selectedNode] summary] project]];
    
    [self reloadSummaryTree];
}


- (IBAction)detachAccountManager:(id)sender
{
    [self switchContentView:mainContentView toSubview:noHostConnectedSubview];
    [clientManager.activeClient performAccountManagerDetachRequest];
    
    [self.projectTree resetUpdateTime];
    self.projectTree.shouldSkipRandomizingProjects = YES;
    
    [NSApp endSheet:[sender window]];
}


- (IBAction)synchronizeWithAccountManager:(id)sender
{
    if (!syncWithAccountManagerSheet)
        syncWithAccountManagerSheet = [[BOINCSyncWithAccountManager alloc] initWithWindowNibName:@"BOINCSyncWithAccountManager"];
    
    [syncWithAccountManagerSheet beginSyncWithAccountManagerSheetInWindow:[[self view] window]
                                                                forClient:clientManager.activeClient];
    [[syncWithAccountManagerSheet window] setDelegate:self];
}




#pragma mark -
#pragma mark Private methods

- (void)switchContentView:(NSView *)contentView toSubview:(NSView *)newView
{
    while ([[contentView subviews] count] > 0)
        [[[contentView subviews] objectAtIndex:0] removeFromSuperviewWithoutNeedingDisplay];
    
    [contentView addSubview:newView];
    [[contentView window] recalculateKeyViewLoop];
}


- (void)updateProjectPreferenceViews
{
    if (clientManager.activeClient.isConnected) {
        // the active client is connected
        self.clientAttachedToAccountManager = clientManager.activeClient.accountManager ? YES : NO;
        [self updateSummaries];
        self.preferenceForHost = [NSString stringWithFormat:@"Project Preferences for Host: %@", clientManager.activeClient.fullName];
        return;
    }
    
    // there is no active client or it is not connected
    self.preferenceForHost = @"Project Preferences for Host: No Host Connected";
    [self switchContentView:mainContentView toSubview:noHostConnectedSubview];
    [self.projectTree resetUpdateTime];
    self.projectTree = nil;
}


// the source view only allows one item to be selected
- (BMBProjectNode *)selectedNode
{
    NSArray *objects = [projectTreeController selectedObjects];
    
    if (![objects count])
        return nil;
    
    return (BMBProjectNode *)[objects objectAtIndex:0];
}


- (void)updateSummaries
{
    if (!self.projectTree)
        self.projectTree = [[BOINCProjectsSummaryTree alloc] initWithClientManager:clientManager];
    
    [self.projectTree updateSummaries];
    
    [self restoreOutlineState];
}


- (void)updateMainContentView
{
    BMBBaseNode *node = [self selectedNode];
    
    if ([node isKindOfClass:[BMBOtherProjectNode class]]) {
        [[otherProjectDescriptionWebView mainFrame] loadHTMLString:[node htmlDescription] baseURL:nil];
        [self switchContentView:mainContentView toSubview:otherProjectsSubview];
    }
    else if ([node isKindOfClass:[BMBAccountManagerNode class]]) {
        [[managerDescriptionWebView mainFrame] loadHTMLString:[node htmlDescription] baseURL:nil];
        [[managerNotesWebView mainFrame] loadHTMLString:[self notesHTMLDescription] baseURL:nil];
        [self switchContentView:mainContentView toSubview:accountManagerSubview];
    }
    else if ([node isKindOfClass:[BMBProjectNode class]]) {
        
        [[projectDescriptionWebView mainFrame] loadHTMLString:[node htmlDescription] baseURL:nil];
        
        if (mainContentView != projectDescriptionSubview)
            [self switchContentView:mainContentView toSubview:projectDescriptionSubview];
        
        if ((node.projectStatusIndex == 0) && (projectStatusContentView != notJoinedProjectSubview)) {
            // not attached
            [self switchContentView:projectStatusContentView toSubview:notJoinedProjectSubview];
        } else if ((node.projectStatusIndex == 1) && (projectStatusContentView != joinedProjectSubview)) {
            // attached
            [self switchContentView:projectStatusContentView toSubview:joinedProjectSubview];
        } else if ((node.projectStatusIndex == 2) && (projectStatusContentView != detachWhenDoneSubview)) {
            // detaching when done
            [self switchContentView:projectStatusContentView toSubview:detachWhenDoneSubview];
        }
    }
    [[[self view] window] makeFirstResponder:projectOutlineView];
}


#pragma mark saving and restoring the outline view state
/* 
 The order of the general area descriptions change order randomly, in order to let all projects to have a chance in the limelight (and not just those that start with 'AAA...').
 This means that indexes are not usable as a way to save the state of the outline view (the current selection and the open/close state of each base node) so BMB uses the title. Just don't assume that any given title is still in the outline when it is restored.
 Special consideration is needed for the host computer base node. It will change every time the user switches the active host so store a key for that node. (It will also allways be the first node) This way the open/close state will stay the same no matter what host the user is looking at.
 */
- (void)saveOutlineState
{
    NSMutableDictionary *outlineState = [NSMutableDictionary dictionaryWithCapacity:2];
    
    [outlineState setObject:[self titleOfCurrentSelection] forKey:kBMBAllProjectsSourceListSelectedSummary];
    
    NSMutableArray *expandedGroups = [NSMutableArray array];
    NSMutableArray *groups = [[self groupItems] mutableCopy];
    
    if ([groups count]) {
        // store a const key for the host group because the host name can change
        NSTreeNode *hostGroupNode = [groups objectAtIndex:0];
        if ([projectOutlineView isItemExpanded:hostGroupNode])
            [expandedGroups addObject:kBMBAllProjectsSourceListHostGroupNode];
        [groups removeObjectAtIndex:0];
    }
    
    for (NSTreeNode *groupNode in groups)
        if ([projectOutlineView isItemExpanded:groupNode])
            [expandedGroups addObject:[[groupNode representedObject] nodeTitle]];
    [groups release];
    
    [outlineState setObject:expandedGroups forKey:kBMBAllProjectsSourceListExpandedGroups];
    
    [[NSUserDefaults standardUserDefaults] setObject:outlineState forKey:kBMBAllProjectsSourceListState];
}


/*
 Based on the titles of the nodes, restore the open/close state (expansion) of each base node and then select the previously selected project node (if it is still there).
 The first time BMB is run, setup a default state.
 */
- (void)restoreOutlineState
{
    NSDictionary *outlineState = [[NSUserDefaults standardUserDefaults] objectForKey:kBMBAllProjectsSourceListState];
    if (!outlineState) {
        [self defaultExpansion];
        [self defaultSelection];
        [self saveOutlineState];
        return;
    }
    
    [self expandGroups:[outlineState objectForKey:kBMBAllProjectsSourceListExpandedGroups]];
    [self selectProjectSummary:[outlineState objectForKey:kBMBAllProjectsSourceListSelectedSummary]];
    
}


// Based on the stored user default settings expand the base nodes of the outline view
- (void)expandGroups:(NSArray *)groups
{
    NSMutableArray *expandedGroups = [groups mutableCopy];
    NSArray *groupItems = [self groupItems];
    
    if ([expandedGroups count])
        // the current host group is stored as a const key because the host name can change, and it's always the first item
        if ([[expandedGroups objectAtIndex:0] isEqualToString:kBMBAllProjectsSourceListHostGroupNode])  {
            [projectOutlineView expandItem:[groupItems objectAtIndex:0]];
            [expandedGroups removeObjectAtIndex:0];
        }
    
    for (NSString *title in expandedGroups)
        for (NSTreeNode *node in groupItems) 
            if ([title isEqualToString:[[node representedObject] nodeTitle]]) {
                [projectOutlineView expandItem:node];
                break;
            }
    
    [expandedGroups release];
}


// Based on the stored user default settings select the node that was previously selected
- (void)selectProjectSummary:(NSString *)summaryTitle
{   
    NSTreeNode *node = nil;
    for (node in [self groupItems]) {
        NSTreeNode *child = nil;
        for (child in [node childNodes]) 
            if ([[[child representedObject] nodeTitle] isEqualToString:summaryTitle]) {
                [projectOutlineView expandItem:[child parentNode]];
                [projectTreeController setSelectionIndexPath:[child indexPath]];
                break;
            }
        if (child)
            break;
    }
    if (!node)
        //nothing was found that matched the stored selection
        [self defaultSelection];
}


// selects the Join Other Projects item or the account manager (if it exists)
- (void)defaultSelection
{
    for (NSTreeNode *node in [self groupItems]) {
        if ([[(BMBBaseNode *)[node representedObject] nodeTitle] isEqualToString:NSLocalizedString(@"Account Manager", @"Source list title for 'Account Manager' group")]) {
            [projectOutlineView expandItem:node];
            [projectTreeController setSelectionIndexPath:[[[node childNodes] objectAtIndex:0] indexPath]];
            break;
        }
        
        NSTreeNode *child = nil;
        for (child in [node childNodes]) 
            if ([[child representedObject] isKindOfClass:[BMBOtherProjectNode class]]) {
                [projectOutlineView expandItem:[child parentNode]];
                [projectTreeController setSelectionIndexPath:[child indexPath]];
                break;
            }
        if (child)
            break;
    }
}


// expand the host group and the Other Projects groups, leave the general area groups closed
- (void)defaultExpansion
{
    for (NSTreeNode *node in [self groupItems])
        if ([[node representedObject] isExpandedByDefault])
            [projectOutlineView expandItem:node];
}


// return a list of the base nodes of the outline view
- (NSArray *)groupItems
{
    NSMutableArray *groupItems = [NSMutableArray array];
    NSInteger rows = [projectOutlineView numberOfRows];
    for (NSInteger row = 0; row < rows; row++)
        if (![[[projectOutlineView itemAtRow:row] representedObject] isLeaf])
            [groupItems addObject:[projectOutlineView itemAtRow:row]];
    
    return groupItems;
}


- (NSString *)titleOfCurrentSelection
{
    NSArray *objects = [projectTreeController selectedObjects];
    
    if (![objects count])
        return @"";
    
    return [[objects objectAtIndex:0] nodeTitle];
}



#pragma mark notes HTML for account manager view

- (NSString *)notesHTMLDescription
{
    static NSString *notesHTMLDescription = nil;
    
    if (!notesHTMLDescription) {
        NSMutableString* tempString = [NSMutableString stringWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"AccountManagerNotes" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
        
        [tempString replaceOccurrencesOfString:@"FontSize" 
                                    withString:[[NSNumber numberWithDouble:[NSFont systemFontSize] - 1] stringValue] 
                                       options:0 
                                         range:NSMakeRange(0, [tempString length])];
        
        [tempString replaceOccurrencesOfString:@"FontFamilyName" 
                                    withString:[[NSFont systemFontOfSize:0] familyName] 
                                       options:0 
                                         range:NSMakeRange(0, [tempString length])];
        
        notesHTMLDescription = [tempString copy];
    }
    
    return notesHTMLDescription;
}


@end
