//
//  BMBProjectMenuController.m
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

#import "BMBProjectMenuController.h"
#import "BOINCActiveClientManager.h"
#import "BMBAppController.h"
#import "BMBStatusMenuController.h"
#import "BMBNumberBadge.h"
#import "BOINCClientManager.h"
#import "BMBAttributeInfoView.h"
#import "BMBAttributeInfoStringCell.h"



@interface BMBProjectMenuController (BMBPrivate)
- (void)createProjectSubmenu;
- (void)createURLMenuItems;
- (void)updateProjectSubmenu;
- (NSMutableArray *)updateAttributes:(NSDictionary *)attributes;
@end




//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
@implementation BMBProjectMenuController

@synthesize project;

@synthesize projectMenuItem;
@synthesize projectViewMenuItem;
@synthesize projectInfoView;
@synthesize projectInformation;

@synthesize accountInfoView;
@synthesize accountViewMenuItem;
@synthesize accountInformation;

@synthesize submenu;
@synthesize showProjectMenuItem;
@synthesize updateMenuItem;
@synthesize suspendMenuItem;
@synthesize noNewWorkMenuItem;

@synthesize lastAttributesUpdate;



// Set up factory defaults for the menu preferences.
+ (void)initialize 
{
    if (self != [BMBProjectMenuController class])
        return;
    
    NSNumber *taskCountBadge  = [NSNumber numberWithBool:YES];
    
    int position = 0;
    NSDictionary *projectMenuAccountName   = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [NSNumber numberWithBool:NO], kAttributeIsVisible,
                                              [NSNumber numberWithInt:position++], kAttributePosition,
                                              nil];
    NSDictionary *projectMenuTotalCredit   = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [NSNumber numberWithBool:YES], kAttributeIsVisible,
                                              [NSNumber numberWithInt:position++], kAttributePosition,
                                              nil];
    NSDictionary *projectMenuHostCredit    = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [NSNumber numberWithBool:YES], kAttributeIsVisible,
                                              [NSNumber numberWithInt:position++], kAttributePosition,
                                              nil];
    NSDictionary *projectMenuTaskCount     = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [NSNumber numberWithBool:NO], kAttributeIsVisible,
                                              [NSNumber numberWithInt:position++], kAttributePosition,
                                              nil];
    NSDictionary *projectMenuTasksToReport = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [NSNumber numberWithBool:NO], kAttributeIsVisible,
                                              [NSNumber numberWithInt:position++], kAttributePosition,
                                              nil];
    NSDictionary *projectMenuTimeEstimate  = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [NSNumber numberWithBool:NO], kAttributeIsVisible,
                                              [NSNumber numberWithInt:position++], kAttributePosition,
                                              nil];
    NSDictionary *projectMenuTeamName      = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [NSNumber numberWithBool:NO], kAttributeIsVisible,
                                              [NSNumber numberWithInt:position++], kAttributePosition,
                                              nil];
    NSDictionary *projectMenuResourceShare = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [NSNumber numberWithBool:NO], kAttributeIsVisible,
                                              [NSNumber numberWithInt:position++], kAttributePosition,
                                              nil];
    NSDictionary *projectMenuHostVenue     = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [NSNumber numberWithBool:NO], kAttributeIsVisible,
                                              [NSNumber numberWithInt:position], kAttributePosition,
                                              nil];
    NSDictionary *projectMenuAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                           projectMenuAccountName,   kMenuAccountName,
                                           projectMenuTotalCredit,   kMenuTotalCredit,
                                           projectMenuHostCredit,    kMenuHostCredit,
                                           projectMenuTaskCount,     kMenuTaskCount,
                                           projectMenuTasksToReport, kMenuTasksToReport,
                                           projectMenuTimeEstimate,  kMenuTimeEstimate,
                                           projectMenuTeamName,      kMenuTeamName,
                                           projectMenuResourceShare, kMenuResourceShare,
                                           projectMenuHostVenue,     kMenuHostVenue,
                                           nil];
    
    position = 0;
    NSDictionary *accountMenuAccountName   = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [NSNumber numberWithBool:YES], kAttributeIsVisible,
                                              [NSNumber numberWithInt:position++], kAttributePosition,
                                              nil];   
    NSDictionary *accountMenuTotalCredit   = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [NSNumber numberWithBool:NO], kAttributeIsVisible,
                                              [NSNumber numberWithInt:position++], kAttributePosition,
                                              nil];
    NSDictionary *accountMenuHostCredit    = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [NSNumber numberWithBool:NO], kAttributeIsVisible,
                                              [NSNumber numberWithInt:position++], kAttributePosition,
                                              nil];
    NSDictionary *accountMenuTaskCount     = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [NSNumber numberWithBool:YES], kAttributeIsVisible,
                                              [NSNumber numberWithInt:position++], kAttributePosition,
                                              nil];
    NSDictionary *accountMenuTasksToReport = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [NSNumber numberWithBool:YES], kAttributeIsVisible,
                                              [NSNumber numberWithInt:position++], kAttributePosition,
                                              nil];
    NSDictionary *accountMenuTimeEstimate  = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [NSNumber numberWithBool:YES], kAttributeIsVisible,
                                              [NSNumber numberWithInt:position++], kAttributePosition,
                                              nil];
    NSDictionary *accountMenuTeamName      = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [NSNumber numberWithBool:YES], kAttributeIsVisible,
                                              [NSNumber numberWithInt:position++], kAttributePosition,
                                              nil];
    NSDictionary *accountMenuResourceShare = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [NSNumber numberWithBool:YES], kAttributeIsVisible,
                                              [NSNumber numberWithInt:position++], kAttributePosition,
                                              nil];
    NSDictionary *accountMenuHostVenue     = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [NSNumber numberWithBool:YES], kAttributeIsVisible,
                                              [NSNumber numberWithInt:position], kAttributePosition,
                                              nil];
    NSDictionary *accountMenuAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                           accountMenuAccountName,   kMenuAccountName,
                                           accountMenuTotalCredit,   kMenuTotalCredit,
                                           accountMenuHostCredit,    kMenuHostCredit,
                                           accountMenuTaskCount,     kMenuTaskCount,
                                           accountMenuTasksToReport, kMenuTasksToReport,
                                           accountMenuTimeEstimate,  kMenuTimeEstimate,
                                           accountMenuTeamName,      kMenuTeamName,
                                           accountMenuResourceShare, kMenuResourceShare,
                                           accountMenuHostVenue,     kMenuHostVenue,
                                           nil];
    
    
    NSDictionary *defaults = [NSDictionary dictionaryWithObjectsAndKeys:
                              taskCountBadge,        @"TaskCountBadge",
                              projectMenuAttributes, kProjectMenuAttributes,
                              accountMenuAttributes, kAccountMenuAttributes,                              
                              nil];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults: defaults];
}


#pragma mark Public methods

+ (BMBProjectMenuController *)menuControllerWithProject:(BOINCProject *)newProject forClient:(BOINCClient *)projectsClient
{
    return [[[BMBProjectMenuController alloc] initWithProject:newProject forClient:projectsClient] autorelease];
}



- (id)initWithProject:(BOINCProject *)newProject forClient:(BOINCClient *)projectsClient
{
    self = [super init];
    if (!self) return nil;
	
    if (![NSBundle loadNibNamed:@"BMBProjectMenu" owner:self]) {
        BBLog(@"[ProjectMenuController initWithProject:statusMenu:] Error, could not load BMBProjectMenu.xib");
        return nil;
    }
    // One quirk of NIB/XIB's is when you load them, all the "top level objects" are retained an extra time
    // so I need to release them an extra time. might as well do it right away
    [projectMenuItem release];
    [projectViewMenuItem release];
    [projectInfoView release];
    [accountInfoView release];
    
    project = [newProject retain];
    client  = projectsClient;
    lastAttributesUpdate = [[NSDate distantPast] copy];
    
    // create and set the project's title
    NSFont *projectFont = [[NSFontManager sharedFontManager] convertFont:[NSFont menuFontOfSize:[NSFont systemFontSize]+0.5f] toHaveTrait:NSBoldFontMask];
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                     projectFont, NSFontAttributeName,
                                     nil];
    NSAttributedString *projectNameString = [[NSAttributedString alloc] initWithString:project.projectName attributes:attrsDictionary];
    [projectMenuItem setAttributedTitle:projectNameString];
    [projectNameString release];
    
    // create the task badge if required
    if ((project.taskCount) && [[NSUserDefaults standardUserDefaults] boolForKey:@"TaskCountBadge"])
        [projectMenuItem setImage:[BMBNumberBadge badgeWithLeftNumber:project.runningTaskCount rightNumber:project.taskCount]];
    else
        [projectMenuItem setImage:nil];
    
    // setup the attribute information view for under the project's title
    NSDictionary *attributes = [[NSUserDefaults standardUserDefaults] objectForKey:kProjectMenuAttributes];
    [projectInfoView setAttributeCells:[self updateAttributes:attributes]];
    projectInfoView.indentLevel = 1;
    
    return self;
}


- (void)dealloc
{
    client = nil;
    
    [project              release];
    [projectMenuItem      release];
    
    [projectInfoView      release];
    [projectViewMenuItem  release];
    [projectInformation   release];
    
    [accountInfoView      release];
    [accountViewMenuItem  release];
    [accountInformation   release];
    
    [submenu              release];
    [showProjectMenuItem  release];
    [updateMenuItem       release];
    [suspendMenuItem      release];
    [noNewWorkMenuItem    release];
    
    [lastAttributesUpdate release];
    
    [super dealloc];
}


#pragma mark NSMenu delegate methods
// for the submenu in the project's title menuitem
- (void)menuNeedsUpdate:(NSMenu *)menu
{
    isSubmenuOpen = YES;
    
    if (hasMenuBeenCreated)
        [self updateProjectSubmenu];
    else
        [self createProjectSubmenu];
}


- (void)menuWillOpen:(NSMenu *)menu
{
    isSubmenuOpen = YES;
}


- (void)menuDidClose:(NSMenu *)menu
{
    isSubmenuOpen = NO;
}


// not a NSMenuDelegate method, from BMBStatusMenuController
- (void)mainMenuDidClose
{
    self.lastAttributesUpdate = [NSDate distantPast];
}



#pragma mark -
- (void)updateProjectAttributesWithWidth:(double)width
{
    projectInfoView.maxCreditValueWidth = width;
    [projectInfoView calculateCellFrames];
    [projectInfoView setNeedsDisplay:YES];
}


- (void)updateProjectMenuItems
{
    // update the task badge if required
    if ((project.taskCount) && [[NSUserDefaults standardUserDefaults] boolForKey:@"TaskCountBadge"]) {
        if ((project.runningTaskCount != cachedRunningCount) || (project.taskCount != cachedTaskCount)) {
            [cachedBadgeImage release];
            cachedBadgeImage = [[BMBNumberBadge badgeWithLeftNumber:project.runningTaskCount rightNumber:project.taskCount] retain];
            cachedRunningCount = project.runningTaskCount;
            cachedTaskCount = project.taskCount;
        }
        if (projectMenuItem.image != cachedBadgeImage) {
            [projectMenuItem setImage:cachedBadgeImage];
            // make sure changes are updated now
            [projectMenuItem.menu itemChanged:projectMenuItem];
        }
    } else if (projectMenuItem.image != nil) {
        [projectMenuItem setImage:nil];
        // make sure changes are updated now
        [projectMenuItem.menu itemChanged:projectMenuItem];
    }
    
    if (project.runningTaskCount || ([[NSDate date] timeIntervalSinceDate:self.lastAttributesUpdate] > 5.0)) {
        // update the attribute information view for under the project's title
        NSDictionary *attributes = [[NSUserDefaults standardUserDefaults] objectForKey:kProjectMenuAttributes];
        [projectInfoView setAttributeCells:[self updateAttributes:attributes]];
        projectInfoView.indentLevel = 1;
        self.lastAttributesUpdate = [NSDate date];
    }
    
    [self updateProjectSubmenu];
}


- (NSInteger)numberOfMainProjectMenuItems
{
    return 2;
}


- (void)removeMainProjectMenuItems
{
    NSMenu *menu = [projectMenuItem menu];
    
    [menu removeItem:projectMenuItem];
    [menu removeItem:projectViewMenuItem];
}


- (void)addMainProjectMenuItemsToMenu:(NSMenu *)menu atIndex:(NSInteger)menuIndex
{
    if ([projectMenuItem menu]) {
        BBLog(@"Error: Adding menuitems's for %@ when they are already in the menu.", project.projectName);
        return;
    }
    
    [menu insertItem:projectMenuItem atIndex:menuIndex++];
    [menu insertItem:projectViewMenuItem atIndex:menuIndex];
}


- (void)moveMainProjectMenuItemsToIndex:(NSInteger)newIndex
{
    NSMenu *menu = [projectMenuItem menu];
    if (!menu) {
        BBLog(@"Error: Moving menuitems's for %@ when they are not in the menu to begin with.", project.projectName);
        return;
    }
    
    // if the new location is after the current location then removing the menu items 
    // will reduce the newIndex by the number of items that we remove
    NSInteger currentIndex = [menu indexOfItem:projectMenuItem];
    if (currentIndex < newIndex)
        newIndex-= [self numberOfMainProjectMenuItems];
    
    [self removeMainProjectMenuItems];
    [self addMainProjectMenuItemsToMenu:menu atIndex:newIndex];
}



#pragma mark menu actions

- (IBAction)showProjectWindow:(id)sender
{
}   


- (IBAction)updateProject:(id)sender
{
    [client performRPCOperation:kTagProjectUpdate onProject:project];
}


- (IBAction)suspendProject:(id)sender
{
    if (project.isSuspended)
        [client performRPCOperation:kTagProjectResume onProject:project];
    else
        [client performRPCOperation:kTagProjectSuspend onProject:project];
}


- (IBAction)downloadingTasks:(id)sender
{
    if (project.shouldNotRequestWork)
        [client performRPCOperation:kTagProjectAllowMoreWork onProject:project];
    else
        [client performRPCOperation:kTagProjectNoMoreWork onProject:project];
}


- (IBAction)openWebSite:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[sender representedObject]]];
}



#pragma mark -
#pragma mark Private Methods

- (void)createProjectSubmenu
{
    // setup the attribute information view in the project's submenu
    NSDictionary *attributes = [[NSUserDefaults standardUserDefaults] objectForKey:kAccountMenuAttributes];
    [accountInfoView setAttributeCells:[self updateAttributes:attributes]];
    [accountInfoView calculateCellFrames];
    
    // set the titles of menu items that control a project
    if (project.isSuspended)
        [suspendMenuItem setTitle:NSLocalizedString(@"Resume Project", @"Resume Project menu label")];
    else
        [suspendMenuItem setTitle:NSLocalizedString(@"Suspend Project", @"Suspend Project menu label")];
    
    if (project.shouldNotRequestWork)
        [noNewWorkMenuItem setTitle:NSLocalizedString(@"Allow Downloading New Tasks", @"Allow Downloading New Tasks menu label")];
    else
        [noNewWorkMenuItem setTitle:NSLocalizedString(@"Stop Downloading New Tasks", @"Stop Downloading New Tasks menu label")];
    
    [self createURLMenuItems];
    
    hasMenuBeenCreated = YES;
}


- (void)createURLMenuItems
{
    for (BOINCURL *site in project.boincURLs) {
        NSMenuItem *siteMenuItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:site.urlName action:@selector(openWebSite:) keyEquivalent:@""];
        [siteMenuItem setRepresentedObject:site.url];
        [siteMenuItem setToolTip:site.urlDescription];
        [siteMenuItem setTarget:self];
        
        [submenu addItem:siteMenuItem];
        
        [siteMenuItem release];
    }
}


- (void)updateProjectSubmenu
{
    if (!isSubmenuOpen)
        return;
    
    // setup the attribute information view in the project's submenu
    NSDictionary *attributes = [[NSUserDefaults standardUserDefaults] objectForKey:kAccountMenuAttributes];
    [accountInfoView setAttributeCells:[self updateAttributes:attributes]];
    [accountInfoView calculateCellFrames];
    [accountInfoView setNeedsDisplay:YES];
    
    // set the titles of menu items that control a project
    if (project.isSuspended)
        [suspendMenuItem setTitle:NSLocalizedString(@"Resume Project", @"Resume Project menu label")];
    else
        [suspendMenuItem setTitle:NSLocalizedString(@"Suspend Project", @"Suspend Project menu label")];
    
    if (project.shouldNotRequestWork)
        [noNewWorkMenuItem setTitle:NSLocalizedString(@"Allow Downloading New Tasks", @"Allow Downloading New Tasks menu label")];
    else
        [noNewWorkMenuItem setTitle:NSLocalizedString(@"Stop Downloading New Tasks", @"Stop Downloading New Tasks menu label")];
}


- (NSMutableArray *)updateAttributes:(NSDictionary *)attributes
{
    NSMutableArray *attributeCells = [NSMutableArray array];
    for (NSString *string in attributes)
        [attributeCells addObject:[NSNull null]];
    
    // Account: name
    NSDictionary *attributeDict = [attributes objectForKey:kMenuAccountName];
    if ([[attributeDict objectForKey:kAttributeIsVisible] boolValue]) {
        NSString *accountLabel = NSLocalizedString(@"Account:", @"Account menu label");
        
        [attributeCells replaceObjectAtIndex:[[attributeDict objectForKey:kAttributePosition] intValue]
                                  withObject:[BMBAttributeInfoStringCell cellWithLabel:accountLabel 
                                                                                 value:project.userName]];
    }
    
    // Total Credit: ###,###  RAC: #,###.##
    attributeDict = [attributes objectForKey:kMenuTotalCredit];
    if ([[attributeDict objectForKey:kAttributeIsVisible] boolValue]) {
        NSString *creditLabel = NSLocalizedString(@"Total Credit:", @"Total Credit menu label");
        NSString *racLabel    = NSLocalizedString(@"RAC:", @"RAC menu label");
        
        [attributeCells replaceObjectAtIndex:[[attributeDict objectForKey:kAttributePosition] intValue]
                                  withObject:[BMBAttributeInfoCreditCell cellWithCreditLabel:creditLabel 
                                                                                    RACLabel:racLabel 
                                                                                 creditValue:project.userTotalCredit 
                                                                                    RACValue:project.userRAC]];
    }
    
    // Host Credit: ###,###  RAC: #,###.##
    attributeDict = [attributes objectForKey:kMenuHostCredit];
    if ([[attributeDict objectForKey:kAttributeIsVisible] boolValue]) {
        NSString *creditLabel = NSLocalizedString(@"Host Credit:", @"Host Credit menu label");
        NSString *racLabel    = NSLocalizedString(@"RAC:", @"RAC menu label");
        
        [attributeCells replaceObjectAtIndex:[[attributeDict objectForKey:kAttributePosition] intValue]
                                  withObject:[BMBAttributeInfoCreditCell cellWithCreditLabel:creditLabel 
                                                                                    RACLabel:racLabel 
                                                                                 creditValue:project.hostTotalCredit 
                                                                                    RACValue:project.hostRAC]];
    }
    
    // Team: team name
    attributeDict = [attributes objectForKey:kMenuTeamName];
    if ([[attributeDict objectForKey:kAttributeIsVisible] boolValue]) {
        NSString *teamLabel = NSLocalizedString(@"Team:", @"Team menu label");
        
        NSString *teamName = project.teamName;
        if ([teamName isEqualToString:@""])
            teamName = @"--";
        
        [attributeCells replaceObjectAtIndex:[[attributeDict objectForKey:kAttributePosition] intValue]
                                  withObject:[BMBAttributeInfoStringCell cellWithLabel:teamLabel 
                                                                                 value:teamName]];
    }
    
    //Host Venue: venue
    attributeDict = [attributes objectForKey:kMenuHostVenue];
    if ([[attributeDict objectForKey:kAttributeIsVisible] boolValue]) {
        NSString *venueLabel = NSLocalizedString(@"Host Venue:", @"Host Venue menu label");
        
        NSString *venue = project.hostVenue;
        if ([venue isEqualToString:@""])
            venue = @"--";
        
        [attributeCells replaceObjectAtIndex:[[attributeDict objectForKey:kAttributePosition] intValue]
                                  withObject:[BMBAttributeInfoStringCell cellWithLabel:venueLabel 
                                                                                 value:venue]];
    }
    
    // Resource Share: #,###
    attributeDict = [attributes objectForKey:kMenuResourceShare];
    if ([[attributeDict objectForKey:kAttributeIsVisible] boolValue]) {
        NSString *resourceLabel = NSLocalizedString(@"Resource Share:", @"Resource Share menu label");
        
        [attributeCells replaceObjectAtIndex:[[attributeDict objectForKey:kAttributePosition] intValue]
                                  withObject:[BMBAttributeInfoNumberCell cellWithLabel:resourceLabel 
                                                                           doubleValue:project.resourceShare]];
    }
    
    // Tasks: # (# Running)
    attributeDict = [attributes objectForKey:kMenuTaskCount];
    if ([[attributeDict objectForKey:kAttributeIsVisible] boolValue]) {
        NSString *taskLabel = NSLocalizedString(@"Tasks:", @"Tasks menu label");
        
        NSMutableString *taskCount = [NSMutableString string];
        
        if (project.taskCount == 0)
            [taskCount setString:@"--"];
        else {
            [taskCount appendFormat:@"%d", project.taskCount];
            if (project.runningTaskCount)
                [taskCount appendFormat:@" (%d %@)", project.runningTaskCount, NSLocalizedString(@"Running", @"Task Running label")];
        }
        [attributeCells replaceObjectAtIndex:[[attributeDict objectForKey:kAttributePosition] intValue]
                                  withObject:[BMBAttributeInfoStringCell cellWithLabel:taskLabel 
                                                                                 value:taskCount]];
    }
    
    // Tasks to Report: # (# Errors)
    attributeDict = [attributes objectForKey:kMenuTasksToReport];
    if ([[attributeDict objectForKey:kAttributeIsVisible] boolValue]) {
        NSString *taskLabel = NSLocalizedString(@"Tasks to Report:", @"Tasks to Report menu label");
        
        NSMutableString *taskCount = [NSMutableString string];
        
        if (project.tasksToReport == 0)
            [taskCount setString:@"--"];
        else {
            [taskCount appendFormat:@"%d", project.tasksToReport];
            if (project.tasksWithErrors)
                [taskCount appendFormat:@" (%d %@)", project.tasksWithErrors, NSLocalizedString(@"Errors", @"Task Errors label")];
        }
        
        [attributeCells replaceObjectAtIndex:[[attributeDict objectForKey:kAttributePosition] intValue]
                                  withObject:[BMBAttributeInfoStringCell cellWithLabel:taskLabel 
                                                                                 value:taskCount]];
    }
    
    // Time Estimate: ##d ##h ##m
    attributeDict = [attributes objectForKey:kMenuTimeEstimate];
    if ([[attributeDict objectForKey:kAttributeIsVisible] boolValue]) {
        NSString *timeLabel = NSLocalizedString(@"Time Estimate:", @"Remaining Time Estimate menu label");
        
        [attributeCells replaceObjectAtIndex:[[attributeDict objectForKey:kAttributePosition] intValue]
                                  withObject:[BMBAttributeInfoStringCell cellWithLabel:timeLabel 
                                                                                 value:project.remainingTimeString]];
    }
    
    [attributeCells removeObject:[NSNull null]];
    
    return attributeCells;
}


@end
