//
//  BOINCProjectsSummaryTree.h
//  BOINCMenubar
//
//  Created by BrotherBard on 1/30/09.
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

@class BOINCActiveClientManager;

@interface BOINCProjectsSummaryTree : NSObject
{
    BOINCActiveClientManager *clientManager;
    
    NSArray                *content;
    
    NSDate                 *lastSummaryUpdateTime;
    BOOL                    shouldSkipRandomizingProjects;
    NSMutableArray         *sortedCategoryTitles;
    NSString               *clientNameCache;
}
@property (nonatomic, retain) NSArray             *content;

@property (nonatomic, copy)   NSDate              *lastSummaryUpdateTime;
@property (nonatomic, assign) BOOL                 shouldSkipRandomizingProjects;
@property (nonatomic, copy)   NSMutableArray      *sortedCategoryTitles;
@property (nonatomic, copy)   NSString            *clientNameCache;


- (id)initWithClientManager:(id)manager;

- (void)updateSummaries;
- (void)resetUpdateTime;

@end




#pragma mark -
// support classes

@class BOINCProjectSummary;
@class BOINCAccountManagerSummary;

// BMBBaseNode
// 
// A node in the outline view that represents a title, has a disclosure triangle, is in all caps.
// 
//   --  There is one BMBBaseNode for the current host. It's title is the hostName. It's children are the projects the host is attached to.
//
//   --  There is one BMBBaseNode called "Other Projects" that holds one item that allows the host to attach to projects not in the list.
//
//   --  There is one BMBBaseNode for each category of project (like "Biology and Medicine"). The children are projects that have the same 
//       <general_area> value from the BOINCAllProjectsList and are also not attached to the current host.
//
@interface BMBBaseNode : NSObject 
{
    NSString       *nodeTitle;
    NSMutableArray *children;
    BOOL            isLeaf;
    BOOL            isExpandedByDefault;
    NSInteger       projectStatusIndex;
    long            sortID;
}

@property (nonatomic, copy)   NSString            *nodeTitle;
@property (nonatomic, retain) NSMutableArray      *children;
@property (nonatomic, assign) BOOL                 isLeaf;
@property (nonatomic, assign) BOOL                 isExpandedByDefault;
@property (nonatomic, assign) NSInteger            projectStatusIndex;
@property (readonly)          id                   summary;
@property (readonly)          id                   managerSummary;
@property (readonly)          NSString            *htmlDescription;
@property (readonly)          NSArray             *platforms;
@property (nonatomic, assign) long                 sortID;

+ (BMBBaseNode *)baseNodeWithTitle:(NSString *)title isExpandedByDefault:(BOOL)expand;
- (id)initWithTitle:(NSString *)title isExpandedByDefault:(BOOL)expand;

@end


#pragma mark -
// BMBProjectNode
// 
// A node in the outline that represents a project
// 
@interface BMBProjectNode : BMBBaseNode 
{
    BOINCProjectSummary *projectSummary;
}

+ (BMBProjectNode *)projectNodeForSummary:(BOINCProjectSummary *)projectSummary;
- (id)initWithProjectSummary:(BOINCProjectSummary *)projectSummary;

@end


#pragma mark -
// BMBAccountManagerNode
// 
// A node in the outline that represents an Account Manager
//  
@interface BMBAccountManagerNode : BMBBaseNode 
{
    BOINCAccountManagerSummary *managerSummary;
}

+ (BMBAccountManagerNode *)accountManagerNodeForSummary:(BOINCAccountManagerSummary *)newSummary;
- (id)initWithManagerSummary:(BOINCAccountManagerSummary *)newSummary;

@end


#pragma mark -
// BMBOtherProjectNode
// 
// "Join unlisted project"
// A node in the outline view that represents a placeholder for a GUI to allow the user to attach projects not in the all projects list.
// 
@interface BMBOtherProjectNode : BMBBaseNode 
{
    NSString       *htmlString;
}

+ (BMBOtherProjectNode *)otherProjectNode;

@end

