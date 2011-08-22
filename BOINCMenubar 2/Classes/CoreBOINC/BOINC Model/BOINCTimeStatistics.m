//
//  BOINCTimeStatistics.m
//  BOINCMenubar
//
//  Created by BrotherBard on 5/10/09.
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

#import "BOINCTimeStatistics.h"


@implementation BOINCTimeStatistics

@synthesize onFraction;
@synthesize connectedFraction;
@synthesize activeFraction;
@synthesize cpuEfficiency;
@synthesize lastUpdate;

@dynamic    onFractionString;
@dynamic    connectedFractionString;
@dynamic    activeFractionString;
@dynamic    cpuEfficiencyString;





+ (NSString *)formattedStringFromStatistic:(double)statistic
{
    static NSNumberFormatter *timeStatisticsFormatter = nil;
    if (timeStatisticsFormatter == nil) {
        timeStatisticsFormatter = [[NSNumberFormatter alloc] init];
        [timeStatisticsFormatter setNumberStyle:NSNumberFormatterPercentStyle];
        [timeStatisticsFormatter setMaximumFractionDigits:2];
        [timeStatisticsFormatter setMinimumFractionDigits:0];
        [timeStatisticsFormatter setNotANumberSymbol:@"0"];
    }
    
    return [timeStatisticsFormatter stringFromNumber:[NSNumber numberWithDouble:statistic]];
}


- (void) dealloc
{
    [lastUpdate release];
    
    [super dealloc];
}




- (NSString *)onFractionString
{
    return [BOINCTimeStatistics formattedStringFromStatistic:onFraction];
}


- (NSString *)connectedFractionString
{
    if (connectedFraction == -1)
        return @"Always Connected";
    
    return [BOINCTimeStatistics formattedStringFromStatistic:connectedFraction];
}


- (NSString *)activeFractionString
{
    return [BOINCTimeStatistics formattedStringFromStatistic:activeFraction];
}


- (NSString *)cpuEfficiencyString
{
    return [BOINCTimeStatistics formattedStringFromStatistic:cpuEfficiency];
}




- (void)setLastUpdateFromDouble:(double)updateTime
{
    self.lastUpdate = [NSDate dateWithTimeIntervalSince1970:updateTime];
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
    [parseDescription addDoubleSelector:@selector(setOnFraction:)           forElement:@"on_frac"];
    [parseDescription addDoubleSelector:@selector(setConnectedFraction:)    forElement:@"connected_frac"];
    [parseDescription addDoubleSelector:@selector(setActiveFraction:)       forElement:@"active_frac"];
    [parseDescription addDoubleSelector:@selector(setCpuEfficiency:)        forElement:@"cpu_efficiency"];
    [parseDescription addDoubleSelector:@selector(setLastUpdateFromDouble:) forElement:@"last_update"];
    
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
    [theDescription appendFormat:@"%@    onFraction        = %f\n", indentString, self.onFraction];
    [theDescription appendFormat:@"%@    connectedFraction = %f\n", indentString, self.connectedFraction];
    [theDescription appendFormat:@"%@    activeFraction    = %f\n", indentString, self.activeFraction];
    [theDescription appendFormat:@"%@    cpuEfficiency     = %f\n", indentString, self.cpuEfficiency];
    [theDescription appendFormat:@"%@    lastUpdate        = %@\n", indentString, [self.lastUpdate description]];
    
    return theDescription;
}

@end
