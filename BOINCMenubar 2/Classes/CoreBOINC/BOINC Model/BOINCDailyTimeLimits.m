//
//  BOINCDailyTimeLimits.m
//  BOINCMenubar
//
//  Created by BrotherBard on 1/24/09.
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

#import "BOINCDailyTimeLimits.h"


@implementation BOINCDailyTimeLimits

@synthesize weekdayIndex;

@synthesize hasCPULimits;
@synthesize cpuStartHour;
@synthesize cpuEndHour;

@synthesize hasNetLimits;
@synthesize netStartHour;
@synthesize netEndHour;



+ (id)blankDayTimeLimit
{
    return [[[BOINCDailyTimeLimits alloc] init] autorelease];
}



- (id)init
{
    self = [super init];
    if (!self) return nil;
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"H.m"];
    
    // make sure that default date objects are created
    self.cpuStartHour = [formatter dateFromString:@"0.0"];
    self.cpuEndHour   = [formatter dateFromString:@"0.0"];
    self.netStartHour = [formatter dateFromString:@"0.0"];
    self.netEndHour   = [formatter dateFromString:@"0.0"];
    
    
    return self;
}


- (void)dealloc
{
    [cpuStartHour release];
    [cpuEndHour   release];
    [netStartHour release];
    [netEndHour   release];
    
    [super dealloc];
}



#pragma mark <NSCopying>
- (id)copyWithZone:(NSZone *)zone
{
    BOINCDailyTimeLimits *copiedLimits = [[BOINCDailyTimeLimits allocWithZone:zone] init];
    
    copiedLimits.weekdayIndex = self.weekdayIndex;
    
    copiedLimits.hasCPULimits = self.hasCPULimits;
    copiedLimits.cpuStartHour = self.cpuStartHour;
    copiedLimits.cpuEndHour   = self.cpuEndHour;
    
    copiedLimits.hasNetLimits = self.hasNetLimits;
    copiedLimits.netStartHour = self.netStartHour;
    copiedLimits.netEndHour   = self.netEndHour;
    
    return copiedLimits;
}



#pragma mark XML-specific setters
- (void)setCpuStartHourFromXMLString:(NSString *)timeString
{
    self.cpuStartHour = [formatter dateFromString:timeString];
    self.hasCPULimits = YES;
}


- (void)setCpuEndHourFromXMLString:(NSString *)timeString
{
    self.cpuEndHour = [formatter dateFromString:timeString];
    self.hasCPULimits = YES;
}



- (void)setNetStartHourFromXMLString:(NSString *)timeString
{
    self.netStartHour = [formatter dateFromString:timeString];
    self.hasNetLimits = YES;
}



- (void)setNetEndHourFromXMLString:(NSString *)timeString
{
    self.netEndHour = [formatter dateFromString:timeString];
    self.hasNetLimits = YES;
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
    [parseDescription addNSIntegerSelector:@selector(setWeekdayIndex:)           forElement:@"day_of_week"];
    [parseDescription addStringSelector:@selector(setCpuStartHourFromXMLString:) forElement:@"start_hour"];
    [parseDescription addStringSelector:@selector(setCpuEndHourFromXMLString:)   forElement:@"end_hour"];
    [parseDescription addStringSelector:@selector(setNetStartHourFromXMLString:) forElement:@"net_start_hour"];
    [parseDescription addStringSelector:@selector(setNetEndHourFromXMLString:)   forElement:@"net_end_hour"];
    
    return parseDescription;
}



///////////////////////////////////////////////////////////
#pragma mark -
#pragma mark XML Representation

- (NSString *)xmlRepresentation
{
    // first check to see if we need to output anything
    if (!self.hasCPULimits && !self.hasNetLimits)
        return @"";
    
    NSMutableString *xmlString = [NSMutableString string];
    
    // if weekdayIndex == -1 then this is the daily limits, so don't output the <day_prefs> or <day_of_week> tags
    if (self.weekdayIndex >= 0) {
        [xmlString appendString:@"    <day_prefs>\n"];
        [xmlString appendFormat:@"        <day_of_week>%d</day_of_week>\n", self.weekdayIndex];
    }
    
    // if weekdayIndex == -1 then this is the daily limits, so always output the start/end tags
    if (self.hasCPULimits || (self.weekdayIndex == -1)) {
        [xmlString appendFormat:@"        <start_hour>%@</start_hour>\n", [formatter stringFromDate:self.cpuStartHour]];
        [xmlString appendFormat:@"        <end_hour>%@</end_hour>\n", [formatter stringFromDate:self.cpuEndHour]];
    }
    
    if (self.hasNetLimits || (self.weekdayIndex == -1)) {
        [xmlString appendFormat:@"        <net_start_hour>%@</net_start_hour>\n", [formatter stringFromDate:self.netStartHour]];
        [xmlString appendFormat:@"        <net_end_hour>%@</net_end_hour>\n", [formatter stringFromDate:self.netEndHour]];
    }
    
    if (self.weekdayIndex >= 0) 
        [xmlString appendString:@"    </day_prefs>\n"];
    
    return xmlString;
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
    
    [theDescription appendFormat:@"%@    weekdayIndex = %d\n", indentString, self.weekdayIndex];
    if (self.hasCPULimits) {
        [theDescription appendFormat:@"%@    cpuStartHour = %@\n", indentString, [formatter stringFromDate:self.cpuStartHour]];
        [theDescription appendFormat:@"%@    cpuEndHour   = %@\n", indentString, [formatter stringFromDate:self.cpuEndHour]];
    }
    if (self.hasNetLimits) {
        [theDescription appendFormat:@"%@    netStartHour = %@\n", indentString, [formatter stringFromDate:self.netStartHour]];
        [theDescription appendFormat:@"%@    netEndHour   = %@\n", indentString, [formatter stringFromDate:self.netEndHour]];
    }
    
    return theDescription;
}


@end
