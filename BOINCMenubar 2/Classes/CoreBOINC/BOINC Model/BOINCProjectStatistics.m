//
//  BOINCProjectStatistics.m
//  BOINCMenubar
//
//  Created by BrotherBard on 7/11/09.
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

#import "BOINCProjectStatistics.h"
#import "BOINCDailyProjectStatistics.h"


@implementation BOINCProjectStatistics


@synthesize masterURL;
@synthesize dailyStatistics;



- (id)init
{
    self = [super init];
    if (!self) return self;
    
    dailyStatistics = [[NSMutableArray alloc] init];
    
    return self;
}


- (void)dealloc
{
    [masterURL       release];
    [dailyStatistics release];
    
    [super dealloc];
}



///////////////////////////////////////////////////////////
#pragma mark -
#pragma mark XML-specific setters

- (void)addDailyStatistic:(BOINCDailyProjectStatistics *)statistics
{
    if (!statistics)
        return;
    
    [dailyStatistics addObject:statistics];
}



///////////////////////////////////////////////////////////
#pragma mark -
#pragma mark <BBXMLModelObject> protocol methods

+ (BBXMLParsingDescription *)xmlParsingDescription
{
    static BBXMLParsingDescription *parseDescription = nil;
    if (parseDescription) 
        return parseDescription;
    
    parseDescription = [[BBXMLParsingDescription alloc] initWithTarget:self];
    [parseDescription addStringSelector:@selector(setMasterURL:) forElement:@"master_url"];
    [parseDescription addObjectSelector:@selector(addDailyStatistic:) ofClass:[BOINCDailyProjectStatistics class] forElement:@"daily_statistics"];
    
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
    [theDescription appendFormat:@"%@    masterURL          = %@\n", indentString, self.masterURL];
    
    for (BOINCDailyProjectStatistics *statistic in self.dailyStatistics)
        [theDescription appendString:[statistic debugDescriptionWithIndent:indent + 1]];
    
    return theDescription;
}

@end
