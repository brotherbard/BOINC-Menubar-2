//
//  BOINCProjectSummary.m
//  BOINCMenubar
//
//  Created by BrotherBard on 7/6/08.
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

#import "BOINCProjectSummary.h"
#import "BOINCProject.h"
#import "BOINCPlatform.h"
#import "BOINCPlatforms.h"
#import "BOINCAccountManager.h"


@implementation BOINCProjectSummary

@synthesize projectName;
@synthesize projectURL;
@synthesize projectGeneralArea;
@synthesize projectSpecificArea;
@synthesize projectDescription;
@synthesize projectHome;
@synthesize projectImageURL;
@synthesize platforms;
@synthesize isAttached;
@synthesize project;
@synthesize accountManager;
@synthesize htmlDescription;
@synthesize sortID;



+ (NSString *)projectDescriptionHTMLString
{
    static NSString *projectDescriptionHTML = nil;
    
    if (!projectDescriptionHTML) 
        projectDescriptionHTML = [[NSString stringWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"ProjectDescription" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil] retain];
    
    return projectDescriptionHTML;
}


+ (NSString *)projectWithoutDescriptionHTMLString
{
    static NSString *noProjectDescriptionHTML = nil;
    
    if (!noProjectDescriptionHTML) 
        noProjectDescriptionHTML = [[NSString stringWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"NoProjectDescription" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil] retain];
    
    return noProjectDescriptionHTML;
}


- (id)initWithProject:(BOINCProject *)existingProject
{
    self = [super init];
    if (!self) return nil;
    
    isAttached  = YES;
    project     = [existingProject retain];
    projectName = [existingProject.projectName copy];
    projectURL  = [existingProject.masterURL   copy];
    
    return self;
}


- (void)dealloc
{
    [projectName         release];
    [projectURL          release];
    [projectGeneralArea  release];
    [projectSpecificArea release];
    [projectDescription  release];
    [projectHome         release];
    [platforms           release];
    [projectImageURL     release];
    [project             release];
    [accountManager      release];
    [htmlDescription     release];
    
    [super dealloc];
}


- (void)updateCurrentPlatforms:(NSArray *)clientPlatforms
{
    for (BOINCPlatform *currentPlatform in clientPlatforms)
        for (BOINCPlatform *platform in platforms) {
            if ([currentPlatform.name isEqualToString:platform.name]) {
                platform.isCurrentPlatform = YES;
                // this is a bit of a hack (make a custom cell!!!)
                platform.checkmark = @"✔";
            }
        }
    
    NSSortDescriptor *currentPlatformDescriptor = 
    [[[NSSortDescriptor alloc] initWithKey:@"isCurrentPlatform" ascending:NO] autorelease];
    
    NSSortDescriptor *systemNameDescriptor = 
    [[[NSSortDescriptor alloc] initWithKey:@"operatingSystemName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)] autorelease];
    
    NSSortDescriptor *architectureNameDescriptor = 
    [[[NSSortDescriptor alloc] initWithKey:@"architectureName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)] autorelease];
    
    [platforms sortUsingDescriptors:[NSArray arrayWithObjects:
                                     currentPlatformDescriptor, 
                                     systemNameDescriptor, 
                                     architectureNameDescriptor, 
                                     nil]];
}


// used to check if this project summary matches any of the attached projects
- (BOOL)isSummaryForProject:(BOINCProject *)searchProject
{
    if ([searchProject hasSameURL:self.projectURL] || ([searchProject.projectName caseInsensitiveCompare:self.projectName] == NSOrderedSame)) 
        return YES;
    return NO;
}


// if this project matches an attached project then update the info here
- (void)updateSummaryForAttachedProject:(BOINCProject *)attachedProject
{
    self.isAttached = YES;
    self.project = attachedProject;
    
    // use the attached project's project name so user can find the project in the list even if the project changes their name????
    self.projectName = attachedProject.projectName;
    
    // use URL from All Project's List????  (if the project updates it then user goes to that new site)
    // or show both URL's???
    //self.projectURL = attachedProject.masterURL;
}


// this is called lazily to load the html description of the project's summary
- (NSString *)htmlDescription
{
    if (htmlDescription)
        return htmlDescription;
    
    NSMutableString *tempString = nil;
    
    if (projectDescription) 
        tempString = [[BOINCProjectSummary projectDescriptionHTMLString] mutableCopy];
    else 
        tempString = [[BOINCProjectSummary projectWithoutDescriptionHTMLString] mutableCopy];
    
    [tempString replaceOccurrencesOfString:@"FontSize" 
                                withString:[[NSNumber numberWithDouble:[NSFont systemFontSize] - 1] stringValue] 
                                   options:0 
                                     range:NSMakeRange(0, [tempString length])];
    
    [tempString replaceOccurrencesOfString:@"FontFamilyName" 
                                withString:[[NSFont systemFontOfSize:0] familyName] 
                                   options:0 
                                     range:NSMakeRange(0, [tempString length])];
    
    if (projectURL)
        [tempString replaceOccurrencesOfString:@"<ProjectURL/>" 
                                    withString:projectURL 
                                       options:0 
                                         range:NSMakeRange(0, [tempString length])];
    
    if (projectImageURL)
        [tempString replaceOccurrencesOfString:@"<ProjectImageURL/>" 
                                    withString:[NSString stringWithFormat:@"<img src='%@'>", projectImageURL] 
                                       options:0 
                                         range:NSMakeRange(0, [tempString length])];
    
    if (projectHome)
        [tempString replaceOccurrencesOfString:@"<ProjectHome/>" 
                                    withString:projectHome 
                                       options:0 
                                         range:NSMakeRange(0, [tempString length])];
    
    if (projectSpecificArea)
        [tempString replaceOccurrencesOfString:@"<ProjectSpecificArea/>" 
                                    withString:projectSpecificArea 
                                       options:0 
                                         range:NSMakeRange(0, [tempString length])];
    
    if (projectDescription)
        [tempString replaceOccurrencesOfString:@"<ProjectDescription/>" 
                                    withString:projectDescription 
                                       options:0 
                                         range:NSMakeRange(0, [tempString length])];
    
    self.htmlDescription = tempString;
    [tempString release];
    return htmlDescription;
}



#pragma mark for XML parsing
- (void)setPlatformsArray:(BOINCPlatforms *)newPlatforms
{
    self.platforms = newPlatforms.platforms;
}



- (void)finishedXMLParsing
{
    if ([platforms count] == 0) 
        [platforms addObject:[BOINCPlatform platformWithName:@"unknown"]];
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
    [parseDescription addStringSelector:   @selector(setProjectName:)         forElement:@"name"];
    [parseDescription addStringSelector:   @selector(setProjectURL:)          forElement:@"url"];
    [parseDescription addStringSelector:   @selector(setProjectGeneralArea:)  forElement:@"general_area"];
    [parseDescription addStringSelector:   @selector(setProjectSpecificArea:) forElement:@"specific_area"];
    [parseDescription addXMLStringSelector:@selector(setProjectDescription:)  forElement:@"description"];
    [parseDescription addStringSelector:   @selector(setProjectHome:)         forElement:@"home"];
    [parseDescription addStringSelector:   @selector(setProjectImageURL:)     forElement:@"image"];
    [parseDescription addObjectSelector:   @selector(setPlatformsArray:) ofClass:[BOINCPlatforms class] forElement:@"platforms"];
    
    [parseDescription addParsingCompletionSelector:@selector(finishedXMLParsing)];
    
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
    [theDescription appendFormat:@"%@    projectName         = %@\n", indentString, self.projectName];
    [theDescription appendFormat:@"%@    projectURL          = %@\n", indentString, self.projectURL];
    [theDescription appendFormat:@"%@    projectImageURL     = %@\n", indentString, self.projectImageURL];
    [theDescription appendFormat:@"%@    projectHome         = %@\n", indentString, self.projectHome];
    [theDescription appendFormat:@"%@    projectGeneralArea  = %@\n", indentString, self.projectGeneralArea];
    [theDescription appendFormat:@"%@    projectSpecificArea = %@\n", indentString, self.projectSpecificArea];
    [theDescription appendFormat:@"%@    projectDescription  = %@\n", indentString, self.projectDescription];
    [theDescription appendFormat:@"%@    isAttached          = %@\n", indentString, self.isAttached ? @"YES" : @"NO"];
    [theDescription appendFormat:@"%@    project             = %@\n", indentString, self.project.projectName];
    
    if ([platforms count] == 0)
        [theDescription appendFormat:@"%@    platforms           = <none>\n", indentString];
    else
        for (BOINCPlatform *platform in platforms)
            [theDescription appendString:[platform debugDescriptionWithIndent:indent + 1]];
    
    
    return theDescription;
}



@end
