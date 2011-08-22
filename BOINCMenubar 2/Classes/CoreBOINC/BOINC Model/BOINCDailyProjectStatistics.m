//
//  BOINCDailyProjectStatistics.m
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

#import "BOINCDailyProjectStatistics.h"


@implementation BOINCDailyProjectStatistics


@synthesize day;
@synthesize userTotalCredit;
@synthesize userRAC;
@synthesize hostTotalCredit;
@synthesize hostRAC;


- (void) dealloc
{
    [day release];
    
    [super dealloc];
}


- (void)setDateFromXML:(double)date 
{
    self.day = [NSDate dateWithTimeIntervalSince1970:date];
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
    [parseDescription addDoubleSelector:@selector(setDateFromXML:)     forElement:@"day"];
    [parseDescription addDoubleSelector:@selector(setUserTotalCredit:) forElement:@"user_total_credit"];
    [parseDescription addDoubleSelector:@selector(setUserRAC:)         forElement:@"user_expavg_credit"];
    [parseDescription addDoubleSelector:@selector(setHostTotalCredit:) forElement:@"host_total_credit"];
    [parseDescription addDoubleSelector:@selector(setHostRAC:)         forElement:@"host_expavg_credit"];
    
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
    
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterFullStyle];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    NSString *formattedDateString = [dateFormatter stringFromDate:self.day];
    
    [theDescription appendFormat:@"%@%@ <%p>\n", indentString, [self className], self];
    [theDescription appendFormat:@"%@    day             = %@\n", indentString, formattedDateString];
    [theDescription appendFormat:@"%@    userTotalCredit = %f\n", indentString, self.userTotalCredit];
    [theDescription appendFormat:@"%@    userRAC         = %f\n", indentString, self.userRAC];
    [theDescription appendFormat:@"%@    hostTotalCredit = %f\n", indentString, self.hostTotalCredit];
    [theDescription appendFormat:@"%@    hostRAC         = %f\n", indentString, self.hostRAC];
    
    return theDescription;
}

@end
