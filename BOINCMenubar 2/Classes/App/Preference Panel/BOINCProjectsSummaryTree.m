//
//  BOINCProjectsSummaryTree.m
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

#import "BOINCProjectsSummaryTree.h"
#import "BOINCActiveClientManager.h"
#import "BOINCClientManager.h"
#import "BOINCAllProjectsList.h"
#import "BOINCAccountManagerSummary.h"



// Private
@interface BOINCProjectsSummaryTree ()

- (NSArray *)updatedAllProjectsList;

- (void)addAttachedProjectSummaries:(NSMutableArray *)attachedSummaries 
                     accountManager:(BOINCAccountManagerSummary *)attachedAccountManager
                        toTreeArray:(NSMutableArray *)outlineTreeArray;

- (void)addOtherSummaryToTreeArray:(NSMutableArray *)outlineTreeArray;

- (void)addAccountManagerSummary:(NSMutableArray *)managerSummaries 
                     toTreeArray:(NSMutableArray *)outlineTreeArray;

- (void)addInactiveProjectSummaries:(NSMutableArray *)allProjectSummaries 
                        toTreeArray:(NSMutableArray *)outlineTreeArray 
                       withCategory:(NSString *)category;


- (void)sortArrayAlphabeticallyByTitle:(NSMutableArray *)array;
- (void)shuffleSummaries:(NSMutableArray *)array;
- (void)restoreSortOrderForSummaries:(NSMutableArray *)array;
- (void)shuffleCategories:(NSMutableArray *)categories;
- (void)restoreSortOrderForCategories:(NSMutableArray *)categories;

@end



//////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BOINCProjectsSummaryTree


@synthesize content;

@synthesize lastSummaryUpdateTime;
@synthesize shouldSkipRandomizingProjects;
@synthesize sortedCategoryTitles;
@synthesize clientNameCache;


- (id)initWithClientManager:(id)manager
{
    self = [super init];
    if (!self) return nil;
    
    clientManager = manager;
    lastSummaryUpdateTime = [[NSDate distantPast] copy];
    
    return self;
}


- (void)dealloc
{
    [content release];
    
    [lastSummaryUpdateTime release];
    [clientNameCache release];
    [sortedCategoryTitles release];
    
    [super dealloc];
}


- (void)updateSummaries
{
    if (([self.clientNameCache isEqualToString:clientManager.activeClient.clientName] == NO)
        || ([[NSDate date] timeIntervalSinceDate:self.lastSummaryUpdateTime] > 3600.0))
    {
        self.clientNameCache = clientManager.activeClient.clientName;
        self.lastSummaryUpdateTime = [NSDate date];
        
        self.content = [self updatedAllProjectsList];
    }
}


- (void)resetUpdateTime
{
    self.lastSummaryUpdateTime = [NSDate distantPast];
}



# pragma mark creating the all projects array

// Project summaries are read from BOINCs <allProjectsList/> RPC which is provided by the BOINC administrators
// a basic summary is added for projects the client is attached to that are not in that list
- (NSArray *)updatedAllProjectsList
{
    NSMutableArray *outlineTreeArray = [NSMutableArray array];
    
    NSMutableDictionary *allProjectSummaries = clientManager.activeClient.allProjectsList.allProjectsDictionary;
    NSMutableArray *categories = [[[allProjectSummaries allKeys] mutableCopy] autorelease];
    
    // attached projects and account manager
    [self addAttachedProjectSummaries:[allProjectSummaries objectForKey:@"BMBAttachedSummaries"] 
                       accountManager:[[allProjectSummaries objectForKey:@"BMBAttachedAccountManagerSummary"] lastObject] 
                          toTreeArray:outlineTreeArray];
    [categories removeObject:@"BMBAttachedAccountManagerSummary"];
    [categories removeObject:@"BMBAttachedSummaries"];
    
    // the "join other projects" item and account managers
    [self addOtherSummaryToTreeArray:outlineTreeArray];
    
    // unattached account managers
    [self addAccountManagerSummary:[allProjectSummaries objectForKey:@"BMBAccountManagerSummaries"] toTreeArray:outlineTreeArray];
    [categories removeObject:@"BMBAccountManagerSummaries"];
    
    // the boinc project managers want the projects in a random order to give all the projects an equal chance of being seen
    if (shouldSkipRandomizingProjects) 
        [self restoreSortOrderForCategories:categories];
    else
        [self shuffleCategories:categories];
    
    for (NSString *category in categories)
        [self addInactiveProjectSummaries:[allProjectSummaries objectForKey:category] toTreeArray:outlineTreeArray withCategory:category];
    
    return outlineTreeArray;
}


// active projects are projects that the host is currently attached to
- (void)addAttachedProjectSummaries:(NSMutableArray *)attachedSummaries accountManager:(BOINCAccountManagerSummary *)attachedAccountManager toTreeArray:(NSMutableArray *)outlineTreeArray
{
    NSMutableArray *attachedProjects = [NSMutableArray array];
    
    for (BOINCProjectSummary *summary in attachedSummaries)
        [attachedProjects addObject:[BMBProjectNode projectNodeForSummary:summary]];
    
    // sort the attached projects
    [self sortArrayAlphabeticallyByTitle:attachedProjects];
    
    // if there is an account manager, put it at the top of the attached list
    if (attachedAccountManager)
        [attachedProjects insertObject:[BMBAccountManagerNode accountManagerNodeForSummary:attachedAccountManager] atIndex:0];
    
    BMBBaseNode *attachedProjectsNode = [BMBBaseNode baseNodeWithTitle:clientManager.activeClient.clientName isExpandedByDefault:YES];
    attachedProjectsNode.children = attachedProjects;
    
    [outlineTreeArray addObject:attachedProjectsNode];
}


// other projects is a placeholder for GUI to allow the user to attach the host to projects not in the all projects list
- (void)addOtherSummaryToTreeArray:(NSMutableArray *)outlineTreeArray
{
    BMBBaseNode *otherProjects = [BMBBaseNode baseNodeWithTitle:NSLocalizedString(@"Other Projects", @"Source list title for 'Other Projects' group") isExpandedByDefault:YES];
    
    otherProjects.children = [NSArray arrayWithObject:[BMBOtherProjectNode otherProjectNode]];
    
    [outlineTreeArray addObject:otherProjects];
}


// account managers
- (void)addAccountManagerSummary:(NSMutableArray *)managerSummaries toTreeArray:(NSMutableArray *)outlineTreeArray
{
    if ([managerSummaries count] == 0)
        return;
    
    NSMutableArray *managers = [NSMutableArray array];

    for (BOINCAccountManagerSummary *summary in managerSummaries)
        if (!summary.isAttached)
            [managers addObject:[BMBAccountManagerNode accountManagerNodeForSummary:summary]];
    
    BMBBaseNode *accountManagerNode = [BMBBaseNode baseNodeWithTitle:NSLocalizedString(@"Account Managers", @"Source list title for 'Account Managers' group") isExpandedByDefault:YES];
    accountManagerNode.children = managers;
    
    [outlineTreeArray addObject:accountManagerNode];
}


// inactive projects are projects the host is currently not attached to
- (void)addInactiveProjectSummaries:(NSMutableArray *)inactiveSummaries toTreeArray:(NSMutableArray *)outlineTreeArray withCategory:(NSString *)category
{   
    NSMutableArray *generalAreaSummaries = [NSMutableArray array];
    
    for (BOINCProjectSummary *summary in inactiveSummaries)
        [generalAreaSummaries addObject:[BMBProjectNode projectNodeForSummary:summary]];
    
    if (shouldSkipRandomizingProjects) 
        [self restoreSortOrderForSummaries:generalAreaSummaries];
    else
        [self shuffleSummaries:generalAreaSummaries];
    
    BMBBaseNode *generalAreaNode = [BMBBaseNode baseNodeWithTitle:category isExpandedByDefault:NO];
    generalAreaNode.children = generalAreaSummaries;
    
    [outlineTreeArray addObject:generalAreaNode];
}


- (void)sortArrayAlphabeticallyByTitle:(NSMutableArray *)array
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"nodeTitle" 
                                                                   ascending:YES 
                                                                    selector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray *alphabeticByTitle = [NSArray arrayWithObject:sortDescriptor];
    [sortDescriptor release];
    
    [array sortUsingDescriptors:alphabeticByTitle];
}


- (void)restoreSortOrderForSummaries:(NSMutableArray *)array
{
    if ([array count] <= 1)
        return;
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sortID" ascending:YES];
    NSArray *sortByID = [NSArray arrayWithObject:sortDescriptor];
    [sortDescriptor release];
    
    [array sortUsingDescriptors:sortByID];
}


- (void)shuffleSummaries:(NSMutableArray *)summaries
{
    if ([summaries count] <= 1)
        return;
    
    for (NSUInteger shuffleIndex = [summaries count] - 1; shuffleIndex > 0; shuffleIndex--)
        [summaries exchangeObjectAtIndex:shuffleIndex withObjectAtIndex:random() % (shuffleIndex + 1)];
    
    NSUInteger sortID = 0;
    for (BOINCProjectSummary *summary in summaries)
        [summary setSortID:sortID++];
}


// It shouldn't happen, but since the last time we shuffled the categories there may have been a category added/deleted
// to/from the list and I want it to finish up at the end. Otherwise I would just use sortedCategoryTitles directly.
- (void)restoreSortOrderForCategories:(NSMutableArray *)categories
{
    if ([categories count] <= 1)
        return;
    
    NSUInteger sortIndex = 0;
    for (NSString *categoryTitle in self.sortedCategoryTitles) {
        NSUInteger  categoryIndex = [categories indexOfObject:categoryTitle];
        if (categoryIndex != NSNotFound)
            [categories exchangeObjectAtIndex:sortIndex++ withObjectAtIndex:categoryIndex];
    }
}


- (void)shuffleCategories:(NSMutableArray *)categories
{
    if ([categories count] <= 1)
        return;
    
    for (NSUInteger shuffleIndex = [categories count] - 1; shuffleIndex > 0; shuffleIndex--)
        [categories exchangeObjectAtIndex:shuffleIndex withObjectAtIndex:random() % (shuffleIndex + 1)];
    
    self.sortedCategoryTitles = categories;
}


@end    //BOINCProjectsSummaryTree





#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BMBBaseNode


@synthesize nodeTitle;
@synthesize children;
@synthesize isLeaf;
@synthesize isExpandedByDefault;
@synthesize projectStatusIndex;
@synthesize sortID;

@dynamic summary;
@dynamic managerSummary;
@dynamic htmlDescription;


+ (BMBBaseNode *)baseNodeWithTitle:(NSString *)title isExpandedByDefault:(BOOL)expand
{
    return [[[BMBBaseNode alloc] initWithTitle:[title uppercaseString] isExpandedByDefault:expand] autorelease];
}

- (id)initWithTitle:(NSString *)title isExpandedByDefault:(BOOL)expand
{
    self = [super init];
    if (!self) return nil;
    
    nodeTitle = [title copy];
    isLeaf = NO;
    isExpandedByDefault = expand;
    projectStatusIndex = 0;
    
    return self;
}


- (void)dealloc
{
    [nodeTitle release];
    [children release];
    
    [super dealloc];
}


- (NSString *)htmlDescription
{
    return nil;
}


- (id)summary
{
    return nil;
}
- (id)managerSummary
{
    return nil;
}



- (NSArray *)platforms
{
    return nil;
}



@end    //BMBBaseNode





#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BMBProjectNode


+ (BMBProjectNode *)projectNodeForSummary:(BOINCProjectSummary *)projectSummary
{
    return [[[BMBProjectNode alloc] initWithProjectSummary:projectSummary] autorelease];
}


- (id)initWithProjectSummary:(BOINCProjectSummary *)newSummary
{
    self = [super initWithTitle:newSummary.projectName isExpandedByDefault:NO];
    if (!self) return nil;
    
    projectSummary = [newSummary retain];
    isLeaf = YES;
    
    if (projectSummary.project.detachWhenDone)
        projectStatusIndex = 2;
    else 
        projectStatusIndex = projectSummary.isAttached;
    
    return self;
}


- (void)dealloc
{
    [projectSummary release];
    
    [super dealloc];
}


- (NSString *)htmlDescription
{
    return projectSummary.htmlDescription;
}


- (id)summary
{
    return projectSummary;
}


- (NSArray *)platforms
{
    return projectSummary.platforms;
}


@end    //BMBProjectNode



#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BMBAccountManagerNode


+ (BMBAccountManagerNode *)accountManagerNodeForSummary:(BOINCAccountManagerSummary *)newSummary
{
    return [[[BMBAccountManagerNode alloc] initWithManagerSummary:newSummary] autorelease];
}


- (id)initWithManagerSummary:(BOINCAccountManagerSummary *)newSummary
{
    self = [super initWithTitle:newSummary.managerName isExpandedByDefault:NO];
    if (!self) return nil;
    
    managerSummary = [newSummary retain];
    isLeaf = YES;
    
    return self;
}


- (void)dealloc
{
    [managerSummary release];
    
    [super dealloc];
}


- (NSString *)htmlDescription
{
    return managerSummary.htmlDescription;
}


- (id)managerSummary
{
    return managerSummary;
}

@end    //BMBAccountManagerNode




#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BMBOtherProjectNode


+ (BMBOtherProjectNode *)otherProjectNode
{
    return [[[BMBOtherProjectNode alloc] init] autorelease];
}


- (id)init 
{
    self = [super initWithTitle:NSLocalizedString(@"Join unlisted project", "Source list title for 'Join unlisted project'")
            isExpandedByDefault:NO];
    if (!self) return nil;
    
    isLeaf = YES;
    
    return self;
}


- (NSString *)htmlDescription
{
    if (htmlString)
        return htmlString;
    
    NSString *baseHTMLPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"OtherProjects" ofType:@"html"];
    
    htmlString = [NSString stringWithContentsOfFile:baseHTMLPath encoding:NSUTF8StringEncoding error:nil];
    
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"FontSize" 
                                                       withString:[[NSNumber numberWithDouble:[NSFont systemFontSize] - 1] stringValue]];
    
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"FontFamilyName" 
                                                       withString:[[NSFont systemFontOfSize:0] familyName]];
    
    return [htmlString retain];
}


@end    //BMBOtherProjectNode



