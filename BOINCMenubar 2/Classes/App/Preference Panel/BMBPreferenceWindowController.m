//
//  BMBPreferenceWindowController.m
//  BOINCMenubar
//
//  Created by BrotherBard on 4/11/08.
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


#import "BMBPreferenceWindowController.h"
#import "BOINCActiveClientManager.h"

// subclasses of NSViewController for each preference view
#import "BMBGeneralPrefsController.h"
#import "BMBAppearancePrefsController.h"
#import "BMBSoftwareUpdatesController.h"
#import "BMBAdvancedPrefsController.h"
#import "BMBHostsPrefController.h"
#import "BOINCPrefsController.h"
#import "BOINCNetworkPrefsContoller.h"
#import "BOINCProjectsPrefController.h"


// the default implementations are empty, each subclass will override with custom implemenations
@implementation NSViewController (BMB_ViewController_Category)
- (void)BMB_contentViewWillLoad
{
}
- (void)BMB_contentViewDidUnload
{
}
@end



#pragma mark -
// Private methods
@interface BMBPreferenceWindowController (BMBPrivate)
- (void)switchWindowToView:(NSView *)newView;
@end



// view keys (one for each preference view)
NSString * const kBMBGeneralPrefKey    = @"General Preference";
NSString * const kBMBAppearancePrefKey = @"Appearance Preference";
NSString * const kBMBUpdatesPrefKey    = @"Software Updates";
//NSString * const kBMBAdvancedPrefKey   = @"Advanced Preference";
NSString * const kBMBHostsPrefKey      = @"Hosts Preference";
NSString * const kBOINCPrefKey         = @"BOINC Preference";
NSString * const kBOINCNetworkPrefKey  = @"Network Preference";
NSString * const kBOINCProjectsPrefKey = @"Projects Preference";


////
NSString * const kPreferenceToolbarItemKey = @"Preference ToolbarItem";




#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BMBPreferenceWindowController

@synthesize prefViewDictionary;
@synthesize prefItemDictionary;
@synthesize activePrefKey;
@synthesize prefToolbar;


// Set up factory defaults for user preferences.
+ (void)initialize 
{
    if (self != [BMBPreferenceWindowController class])
        return;
    
    NSDictionary *defaults = [NSDictionary dictionaryWithObject:kBMBGeneralPrefKey forKey:kPreferenceToolbarItemKey];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}



#pragma mark -
#pragma mark Public methods

- (id)initWithClientManager:(id)clientManager
{
    self = [super initWithWindowNibName:@"BMBPreferences" owner:self];
    if (!self) return nil;
    
    prefViewDictionary = 
    [[NSDictionary alloc] initWithObjectsAndKeys:
     [[[BMBGeneralPrefsController    alloc] init]                                autorelease], kBMBGeneralPrefKey,
     [[[BMBAppearancePrefsController alloc] init]                                autorelease], kBMBAppearancePrefKey,
     [[[BMBSoftwareUpdatesController alloc] init]                                autorelease], kBMBUpdatesPrefKey,
     [[[BMBHostsPrefController       alloc] initWithClientManager:clientManager] autorelease], kBMBHostsPrefKey,
     [[[BOINCPrefsController         alloc] initWithClientManager:clientManager] autorelease], kBOINCPrefKey,
     [[[BOINCNetworkPrefsContoller   alloc] initWithClientManager:clientManager] autorelease], kBOINCNetworkPrefKey,
     [[[BOINCProjectsPrefController  alloc] initWithClientManager:clientManager] autorelease], kBOINCProjectsPrefKey,
     nil];
    
    return self;
}


- (void)dealloc
{
    [prefViewDictionary release];
    [prefItemDictionary release];
    [activePrefKey release];
    [prefToolbar release];
    
    [super dealloc];
}


// load all the toolbar items stored in the NIB into a dict to use later (using the paletteLabel as the key)
- (void)awakeFromNib
{
    NSMutableDictionary *tempItemDict = [NSMutableDictionary dictionaryWithCapacity:[[prefToolbar items] count]];
    for (NSToolbarItem *item in [prefToolbar items]) 
        [tempItemDict setObject:item forKey:[item paletteLabel]];
    self.prefItemDictionary = tempItemDict;
}




#pragma mark changing the current view


- (void)openPrefWindowWithPrefKey:(NSString *)prefKey
{   
    if (!prefKey) 
        prefKey = [[NSUserDefaults standardUserDefaults] stringForKey:kPreferenceToolbarItemKey];
    
    // if this is the first time, cause the window to load it's NIB 
    if ([self isWindowLoaded] == NO) { 
        if (![[self window] setFrameUsingName:@"BMBPreferencesWindow" force:YES]) {
            [[self window] center];
            [[self window] setFrameAutosaveName:@"BMBPreferencesWindow"];
        }
        [[self window] setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces];
    }
    
    // check to see if a sheet is open
    if ([[self window] attachedSheet]) {
        // there is a sheet open, so don't do anything
        NSBeep();
    } else {
        NSToolbarItem *item = [self.prefItemDictionary objectForKey:prefKey];
        if (item == nil)
            item = [self.prefItemDictionary objectForKey:kBMBGeneralPrefKey];
        
        [prefToolbar setSelectedItemIdentifier:item.itemIdentifier];
        [self setPrefViewForToolbarItem:item];
    }
    
    [NSApp activateIgnoringOtherApps:YES];
    [[self window] makeKeyAndOrderFront:self];
}


/*
 toolbarItem  action method
 Resizes the window to the new view's size and allows the old and new view controllers to do cleanup/setup.
 
 If the user is clicking the icon for the view that is already active get out to stop the view controllers from getting the contentViewDidUnload and contentViewDidLoad messages and wasting cpu cycles drawing the same view.
 
 This is normaly called when the user clicks one of the toolbar items but is also called by openPrefWindowWithViewKey:
 */
- (IBAction)setPrefViewForToolbarItem:(id)prefToolbarItem
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    if (self.activePrefKey == [prefToolbarItem paletteLabel])
        return;
    
    NSViewController *newPrefView = [self.prefViewDictionary objectForKey:[prefToolbarItem paletteLabel]];
    [newPrefView BMB_contentViewWillLoad];
    
    [[self window] setTitle:[prefToolbarItem label]];
    [self switchWindowToView:[newPrefView view]];
    
    [(NSViewController *) [self currentViewController] BMB_contentViewDidUnload];
    
    self.activePrefKey = [prefToolbarItem paletteLabel];
    [[NSUserDefaults standardUserDefaults] setObject:self.activePrefKey forKey:kPreferenceToolbarItemKey];
    
    [pool release];
}


- (id)currentViewController
{
    return [self.prefViewDictionary objectForKey:self.activePrefKey];
}


#pragma mark NSToolbar delegate methods

/* 
 toolbar delegate method
 returns the identifiers of the subset of toolbar items that are selectable
 (in this case they all are)
 */
- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar
{
    NSMutableArray *identifiers = [NSMutableArray array];
    for (NSToolbarItem *item in [self.prefItemDictionary allValues])
        [identifiers addObject:[item itemIdentifier]];
    
    return identifiers;
}




#pragma mark NSWindow delegate methods

/* 
 window delegate method
 allow the last active view to do any clean up
 */
- (void)windowWillClose:(NSNotification *)notification
{   
    // this commits any changes in text fields and other controls the user was editing at the time the window closes
    [[self window] makeFirstResponder:[self window]];
    [(NSViewController *)[self.prefViewDictionary objectForKey:self.activePrefKey] BMB_contentViewDidUnload];
    
    // clear out the contentView
    self.activePrefKey = nil;
    if ([[[[self window] contentView] subviews] count] > 0)
        [[[[[self window] contentView] subviews] objectAtIndex:0] removeFromSuperviewWithoutNeedingDisplay];
    
    // make sure that preferences are saved
    [[NSUserDefaults standardUserDefaults] synchronize];
}




#pragma mark -
#pragma mark Private methods

/* 
 remove the old view(s), resize the window to fit a new view, and add that view
 
 Window coordinates are based on the lower left corner, so changing the height alone will move the top of the window.  Calculate the difference between the new view and the old one to offset the bottom of the window and the height by the same amount.  Note that (currently) the BMB preferences window is a set width for all views.
 
 Remove any existing subviews so that the window is empty during the resize animation.
 
 After the window has changed to the new size, add the new view.
 */
- (void)switchWindowToView:(NSView *)newView
{
    while ([[[[self window] contentView] subviews] count] > 0)
        [[[[[self window] contentView] subviews] objectAtIndex:0] removeFromSuperviewWithoutNeedingDisplay];
    
    double contentHeightDelta = [newView bounds].size.height - [[[self window] contentView] bounds].size.height;
    NSRect newWindowFrame = [[self window] frame];
    newWindowFrame.origin.y -= contentHeightDelta;
    newWindowFrame.size.height += contentHeightDelta;
    
    [[self window] setFrame:newWindowFrame display:YES animate:YES];
    
    [[[self window] contentView] addSubview:newView];
}




@end
