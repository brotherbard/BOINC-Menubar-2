//
//  BOINCProjectSummary.h
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

#import <Cocoa/Cocoa.h>
#import "BBXMLParsingDescription.h"


@class BOINCProject;
@class BOINCPlatform;
@class BOINCPlatforms;
@class BOINCAccountManager;


@interface BOINCProjectSummary : NSObject <BBXMLModelObject>
{
    // from AllProjectsList XML
    NSString            *projectName;
    NSString            *projectURL;
    NSString            *projectGeneralArea;
    NSString            *projectSpecificArea;
    NSString            *projectDescription;
    NSString            *projectHome;
    NSString            *projectImageURL;
    NSMutableArray      *platforms;
    
    // for attached projects
    BOOL                 isAttached;
    BOINCProject        *project;
    BOINCAccountManager *accountManager;
    
    NSString            *htmlDescription;
    long                 sortID;
}
@property (nonatomic, copy)   NSString            *projectName;
@property (nonatomic, copy)   NSString            *projectURL;
@property (nonatomic, copy)   NSString            *projectGeneralArea;
@property (nonatomic, copy)   NSString            *projectSpecificArea;
@property (nonatomic, copy)   NSString            *projectDescription;
@property (nonatomic, copy)   NSString            *projectHome;
@property (nonatomic, copy)   NSString            *projectImageURL;
@property (nonatomic, retain) NSMutableArray      *platforms;

@property (nonatomic, assign) BOOL                 isAttached;
@property (nonatomic, retain) BOINCProject        *project;
@property (nonatomic, retain) BOINCAccountManager *accountManager;

@property (nonatomic, copy)   NSString            *htmlDescription;
@property (nonatomic, assign) long                 sortID;


- (id)initWithProject:(BOINCProject *)existingProject;

- (BOOL)isSummaryForProject:(BOINCProject *)searchProject;
- (void)updateSummaryForAttachedProject:(BOINCProject *)attachedProject;
- (void)updateCurrentPlatforms:(NSArray *)clientPlatforms;


- (NSString *)debugDescriptionWithIndent:(NSInteger)indent;
- (NSString *)debugDescription;


@end
