//
//  BOINCAllProjectsList.m
//  BOINCMenubar
//
//  Created by BrotherBard on 4/25/09.
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

#import "BOINCAllProjectsList.h"
#import "BOINCClient.h"
#import "BOINCProject.h"
#import "BOINCProjectSummary.h"
#import "BOINCAccountManagerSummary.h"
#import "BOINCAccountManager.h"
#import "BOINCClientState.h"



@implementation BOINCAllProjectsList


@synthesize allProjectsDictionary;



- (id)init
{
    self = [super init];
    if (!self) return nil;
    
    projectSummaries      = [[NSMutableArray alloc] init];
    managerSummaries      = [[NSMutableArray alloc] init];
    allProjectsDictionary = [[NSMutableDictionary alloc] init];
    
    return self;
}

- (void) dealloc
{
    [projectSummaries      release];
    [managerSummaries      release];
    [allProjectsDictionary release];
    
    [super dealloc];
}



- (void)addSummary:(id)summary toCategory:(NSString *)category
{
    if ((category == nil) || [category isEqualToString:@""])
        category = @"BMBOtherSummary";
    
    NSMutableArray *array = [allProjectsDictionary objectForKey:category];
    if (array == nil)
        array = [NSMutableArray arrayWithObject:summary];
    else
        [array addObject:summary];
    
    [allProjectsDictionary setObject:array forKey:category];
}


- (void)updateWithClient:(BOINCClient *)client
{
    NSMutableArray *otherProjects = [client.projects mutableCopy];
    
    // update the platforms info and any projects the client is attached to
    for (BOINCProjectSummary *summary in projectSummaries) {
        [summary updateCurrentPlatforms:client.clientState.platforms];
        
        BOINCProject *project = nil;
        for (project in client.projects)
            if ([summary isSummaryForProject:project]) {
                [summary updateSummaryForAttachedProject:project];
                [otherProjects removeObject:project];
                [self addSummary:summary toCategory:@"BMBAttachedSummaries"];
                if (project.isAttachedViaAccountManager)
                    summary.accountManager = client.accountManager;
                break;
            }
        if (project == nil)
            [self addSummary:summary toCategory:summary.projectGeneralArea];
    }
    
    // any items left in otherProjects represent projects that are not in the All Projects List and need a default description
    for (BOINCProject *project in otherProjects) {
        BOINCProjectSummary *summary = [[[BOINCProjectSummary alloc] initWithProject:project] autorelease];
        [summary updateCurrentPlatforms:client.clientState.platforms];
        [self addSummary:summary toCategory:@"BMBAttachedSummaries"];
        if (project.isAttachedViaAccountManager)
            summary.accountManager = client.accountManager;
    }
    [otherProjects release];
    
    BOOL foundAccountManager = NO;
    BOINCAccountManagerSummary *summary = nil;
    for (summary in managerSummaries) {
        // determine if client is attached to account manager
        if ([summary.managerURL isEqualToString:client.accountManager.url]) {
            foundAccountManager = YES;
            summary.isAttached = YES;
            summary.managerName = client.accountManager.name;
            [self addSummary:summary toCategory:@"BMBAttachedAccountManagerSummary"];
        } else
            [self addSummary:summary toCategory:@"BMBAccountManagerSummaries"];
    }
    
    // if client is not attached to any of the listed managers, create a default description
    if (!foundAccountManager && client.accountManager) {
        summary = [[BOINCAccountManagerSummary alloc] initWithManager:client.accountManager];
        [self addSummary:summary toCategory:@"BMBAttachedAccountManagerSummary"];
    }
}


- (void)addProject:(BOINCProjectSummary *)project
{
    if (project)
        [projectSummaries addObject:project];
}


- (void)addManager:(BOINCAccountManagerSummary *)manager
{
    if (manager)
        [managerSummaries addObject:manager];
}



///////////////////////////////////////////////////////////
#pragma mark -
#pragma mark <BBXMLModelObject> protocol method

+ (BBXMLParsingDescription *)xmlParsingDescription
{
    static BBXMLParsingDescription *parseDescription = nil;
    if (parseDescription) 
        return parseDescription;
    
    parseDescription = [[BBXMLParsingDescription alloc] initWithTarget:self];
    
    [parseDescription addObjectSelector:@selector(addProject:) ofClass:[BOINCProjectSummary class]        forElement:@"project"];
    [parseDescription addObjectSelector:@selector(addManager:) ofClass:[BOINCAccountManagerSummary class] forElement:@"account_manager"];
    
    return parseDescription;
}




///////////////////////////////////////////////////////////
#pragma mark -
#pragma mark debug

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"\n%@", [self debugDescriptionWithIndent:0]];
}


- (NSString *)debugDescriptionWithIndent:(NSInteger)indent
{
    NSMutableString *theDescription = [NSMutableString string];
    
    NSMutableString *indentString = [NSMutableString string];
    for (NSInteger i = 0; i < indent; i++)
        [indentString appendString:@"    "];
    
    [theDescription appendFormat:@"%@%@ <%p>\n", indentString, [self className], self];
    
    if ([projectSummaries count] == 0)
        [theDescription appendFormat:@"%@    projectSummaries = <none>\n", indentString];
    else
        for (BOINCProjectSummary *summary in projectSummaries)
            [theDescription appendString:[summary debugDescriptionWithIndent:indent + 1]];
    
    if ([managerSummaries count] == 0)
        [theDescription appendFormat:@"%@    managerSummaries = <none>\n", indentString];
    else
        for (BOINCAccountManagerSummary *summary in managerSummaries)
            [theDescription appendString:[summary debugDescriptionWithIndent:indent + 1]];
    
    
    return theDescription;
}



@end
