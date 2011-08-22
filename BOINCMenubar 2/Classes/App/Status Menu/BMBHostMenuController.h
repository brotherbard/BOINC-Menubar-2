//
//  BMBHostMenuController.h
//  BOINCMenubar
//
//  Created by BrotherBard on 3/29/09.
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


// for User Defaults
#define kTotalHostCredit        @"TotalHostCredit"


#define kProjectSortPropertyKey @"ProjectSortProperty"
#define kProjectSortReversedKey @"ProjectSortReversed"



// add new items to the end!
enum projectSortTags {
    kTotalCreditTag = 0,
    kTotalRACTag,
    kHostCreditTag,
    kHostRACTag,
    kProjectNameTag,
    kTotalTasksTag,
    kRunningTasksTag,
    kTotalTimeEstimateTag,
    kResourceShareTag,
    kDateJoinedTag
};


#define kProjectMenuStartTag 42



@class BOINCActiveClientManager;
@class BMBAttributeInfoView;
@class BOINCClient;


@interface BMBHostMenuController : NSObject
{
    BOINCActiveClientManager *clientManager;
    BOINCClient              *host;
    
    // status menu
    NSMenu               *statusMenu;
    
    // main host menu items
    NSMenuItem           *hostTitleMenuItem;
    NSMenuItem           *hostTotalCreditItem;
    BMBAttributeInfoView *hostTotalCreditView;
    NSMenuItem           *hostInfoItem;
    NSMenuItem           *snoozeMenuItem;
    NSMenuItem           *networkAccessMenuItem;
    NSMenuItem           *projectSeperatorMenuItem;
    NSMenuItem           *accountManagerMenuItem;
    NSMenuItem           *activityWindowMenuItem;
    BOOL                  hasMenuJustOpened;
    BOOL                  isHostMenuAtTop;
    BOOL                  areHostsItemsInMenu;
    BOOL                  areProjectItemsInMenu;
    
    // host list submenu
    NSMenu               *hostListMenu;
    NSMenuItem           *editHostMenuItem;
    BOOL                  hasUpdatedHostList;
    BOOL                  isHostListMenuOpen;
    
    // host info view submenu
    NSMenu               *hostInfoSubmenu;
    NSMenuItem           *hostInfoAttributesItem;
    BMBAttributeInfoView *hostInfoView;
    BOOL                  hasUpdatedHostInfo;
    BOOL                  isHostInfoMenuOpen;
    
    NSMutableArray       *projectMenuControllers;
    NSMenuItem           *noProjectsMenuItem;
    NSMenuItem           *clientErrorMessageMenuItem;
    
    NSDictionary         *projectSortDictionary;
    NSArray              *sortedProjects;
}
@property (nonatomic, retain) BOINCClient *host;
@property (nonatomic, retain) NSArray     *sortedProjects;


- (id)initWithClientManager:(BOINCActiveClientManager *)manager forMenu:(NSMenu *)menu;

- (void)updateForHost:(BOINCClient *)client hasMenuJustOpened:(BOOL)justOpened isMenuAtTop:(BOOL)menuAtTop;
- (void)mainMenuDidClose;


@end
