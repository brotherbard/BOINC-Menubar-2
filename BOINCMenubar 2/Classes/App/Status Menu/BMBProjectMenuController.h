//
//  BMBProjectMenuController.h
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

//
//  A controller for handling the menus for a project in the Status Menu.
//  A new BMBProjectMenuController is created for each project by BMBStatusMenuController.
//

#import <Cocoa/Cocoa.h>



#define kAttributeIsVisible @"visible"
#define kAttributePosition  @"position"

#define kProjectMenuAttributes @"ProjectMenuAttributes"
#define kAccountMenuAttributes @"AccountMenuAttributes"

#define kMenuTotalCredit   @"MenuTotalCredit"
#define kMenuHostCredit    @"MenuHostCredit"
#define kMenuAccountName   @"MenuAccountName"
#define kMenuTeamName      @"MenuTeamName"
#define kMenuResourceShare @"MenuResourceShare"
#define kMenuHostVenue     @"MenuHostVenue"
#define kMenuTaskCount     @"MenuTaskCount"
#define kMenuTasksToReport @"MenuTasksToReport"
#define kMenuTimeEstimate  @"MenuTimeEstimate"



@class BOINCProject;
@class BOINCClient;
@class BMBAttributeInfoView;


@interface BMBProjectMenuController : NSObject
{
    BOINCProject         *project;
    BOINCClient           *client;   //  weak ref
    
    NSMenuItem           *projectMenuItem;
    
    // project info in the main menu
    BMBAttributeInfoView *projectInfoView;
    NSMenuItem           *projectViewMenuItem;
    NSMutableArray       *projectInformation;
    
    // project info in submenu
    BMBAttributeInfoView *accountInfoView;
    NSMenuItem           *accountViewMenuItem;
    NSMutableArray       *accountInformation;
    
    // the project's submenu
    NSMenu               *submenu;
    NSMenuItem           *showProjectMenuItem;
    NSMenuItem           *updateMenuItem;
    NSMenuItem           *suspendMenuItem;
    NSMenuItem           *noNewWorkMenuItem;
    
    // flags
    BOOL                  hasMenuBeenCreated;
    BOOL                  isSubmenuOpen;
    
    double                cachedRunningCount;
    double                cachedTaskCount;
    NSImage              *cachedBadgeImage;
    NSDate               *lastAttributesUpdate;
}
@property (nonatomic, assign)          BOINCProject         *project;

@property (nonatomic, retain) IBOutlet NSMenuItem           *projectMenuItem;

@property (nonatomic, retain) IBOutlet BMBAttributeInfoView *projectInfoView;
@property (nonatomic, retain) IBOutlet NSMenuItem           *projectViewMenuItem;
@property (nonatomic, retain)          NSMutableArray       *projectInformation;

@property (nonatomic, retain) IBOutlet BMBAttributeInfoView *accountInfoView;
@property (nonatomic, retain) IBOutlet NSMenuItem           *accountViewMenuItem;
@property (nonatomic, retain)          NSMutableArray       *accountInformation;

@property (nonatomic, retain) IBOutlet NSMenu               *submenu;
@property (nonatomic, retain) IBOutlet NSMenuItem           *showProjectMenuItem;
@property (nonatomic, retain) IBOutlet NSMenuItem           *updateMenuItem;
@property (nonatomic, retain) IBOutlet NSMenuItem           *suspendMenuItem;
@property (nonatomic, retain) IBOutlet NSMenuItem           *noNewWorkMenuItem;

@property (nonatomic, copy) NSDate *lastAttributesUpdate;


+ (BMBProjectMenuController *)menuControllerWithProject:(BOINCProject *)newProject forClient:(BOINCClient *)projectsClient;
- (id)initWithProject:(BOINCProject *)newProject forClient:(BOINCClient *)projectsClient;

- (NSInteger)numberOfMainProjectMenuItems;
- (void)removeMainProjectMenuItems;
- (void)addMainProjectMenuItemsToMenu:(NSMenu *)menu atIndex:(NSInteger)menuIndex;
- (void)moveMainProjectMenuItemsToIndex:(NSInteger)newIndex;

- (void)updateProjectMenuItems;
- (void)updateProjectAttributesWithWidth:(double)width;
- (void)mainMenuDidClose;

// menu actions
- (IBAction)showProjectWindow:(id)sender;
- (IBAction)updateProject:(id)sender;
- (IBAction)suspendProject:(id)sender;
- (IBAction)downloadingTasks:(id)sender;
- (IBAction)openWebSite:(id)sender;


@end
