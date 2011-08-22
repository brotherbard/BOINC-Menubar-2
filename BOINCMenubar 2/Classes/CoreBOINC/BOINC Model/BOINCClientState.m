//
//  BOINCClientState.m
//  BOINCMenubar
//
//  Created by BrotherBard on 2/1/09.
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

#import "BOINCClientState.h"
#import "BOINCPlatform.h"
#import "BOINCHostInfo.h"
#import "BOINCTimeStatistics.h"
#import "BOINCNetStatistics.h"


@implementation BOINCClientState


@synthesize platforms;
@synthesize primaryPlatform;

@synthesize hostVenue;
@synthesize hostInfo;

@synthesize timeStats;
@synthesize netStats;



///////////////////////////////////////////////////////////

- (id)init
{
    self = [super init];
    if (!self) return nil;
    
    platforms = [[NSMutableArray alloc] init];
    
    return self;
}


- (void)dealloc
{
    [platforms       release];
    [primaryPlatform release];
    
    [hostVenue       release];
    [hostInfo        release];
    
    [timeStats       release];
    [netStats        release];
    
    [super dealloc];
}



- (void)setPrimaryPlatformWithName:(NSString *)platformName
{
    self.primaryPlatform = [BOINCPlatform platformWithName:platformName];
}


- (void)addPlatformWithName:(NSString *)platformName
{
    if (!platformName)
        return;
    
    [platforms addObject:[BOINCPlatform platformWithName:platformName]];
}


- (void)finishedXMLParsing
{
    if (([platforms count] > 0) || (self.primaryPlatform == nil))
        return;
    
    
    [platforms addObject:self.primaryPlatform];
    
    for (NSString *platformName in self.primaryPlatform.supportedPlatforms) {
        BOINCPlatform *platform = [BOINCPlatform platformWithName:platformName];
        if (platform)
            [platforms addObject:platform];
    }
    
    //BBLog(@"%@", [self debugDescription]);
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
    [parseDescription addStringSelector:@selector(setPrimaryPlatformWithName:) forElement:@"platform_name"];
    [parseDescription addStringSelector:@selector(addPlatformWithName:)        forElement:@"platform"];
    // not actually sent in the state RPC
    //[parseDescription addStringSelector:@selector(addPlatformName:)        forElement:@"alt_platform"];
    
    [parseDescription addStringSelector:@selector(setHostVenue:) forElement:@"host_venue"];
    [parseDescription addObjectSelector:@selector(setHostInfo:)  ofClass:[BOINCHostInfo class]       forElement:@"host_info"];
    [parseDescription addObjectSelector:@selector(setTimeStats:) ofClass:[BOINCTimeStatistics class] forElement:@"time_stats"];
    [parseDescription addObjectSelector:@selector(setNetStats:)  ofClass:[BOINCNetStatistics class]  forElement:@"net_stats"];
    
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
    [theDescription appendFormat:@"%@    primaryPlatform = %@\n", indentString, self.primaryPlatform.name];
    NSInteger i = 0;
    for (BOINCPlatform *platform in platforms)
        [theDescription appendFormat:@"%@    platform[%d]\n%@", indentString, i++, [platform debugDescriptionWithIndent:indent + 2]];
    
    [theDescription appendFormat:@"%@    hostVenue       = %@\n", indentString, self.hostVenue];
    [theDescription appendString:[self.hostInfo  debugDescriptionWithIndent:indent + 1]];
    [theDescription appendString:[self.netStats  debugDescriptionWithIndent:indent + 1]];
    [theDescription appendString:[self.timeStats debugDescriptionWithIndent:indent + 1]];
    
    
    return theDescription;
}


@end
