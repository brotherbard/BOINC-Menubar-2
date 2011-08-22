//
//  BOINCNetStatistics.m
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

#import "BOINCNetStatistics.h"
#import "BOINCCommonConstants.h"


@implementation BOINCNetStatistics

@synthesize uploadBandwidthRate;
@synthesize uploadRecentAverageBytes;
@synthesize uploadAverageUpdated;
@synthesize downloadBandwidthRate;
@synthesize downloadRecentAverageBytes;
@synthesize downloadAverageUpdated;





+ (NSString *)formattedStringFromStatistic:(double)statistic
{
    static NSNumberFormatter *netStatisticsFormatter = nil;
    if (netStatisticsFormatter == nil) {
        netStatisticsFormatter = [[NSNumberFormatter alloc] init];
        [netStatisticsFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [netStatisticsFormatter setRoundingMode:NSNumberFormatterRoundHalfUp];
        [netStatisticsFormatter setHasThousandSeparators:YES];
        [netStatisticsFormatter setMaximumFractionDigits:2];
        [netStatisticsFormatter setMinimumFractionDigits:0];
        [netStatisticsFormatter setNotANumberSymbol:@"0"];
    }
    
    return [netStatisticsFormatter stringFromNumber:[NSNumber numberWithDouble:statistic]];
}


- (void) dealloc
{
    [uploadAverageUpdated   release];
    [downloadAverageUpdated release];
    
    [super dealloc];
}


- (NSString *)uploadBandwidthRateString
{
    return [NSString stringWithFormat:@"%@ %@", [BOINCNetStatistics formattedStringFromStatistic:(uploadBandwidthRate / CBKilobyte)], NSLocalizedString(@"KB/sec", @"")];
}


- (NSString *)downloadBandwidthRateString
{
    return [NSString stringWithFormat:@"%@ %@", [BOINCNetStatistics formattedStringFromStatistic:(downloadBandwidthRate / CBKilobyte)], NSLocalizedString(@"KB/sec", @"")];
}


- (NSString *)uploadRecentAverageBytesString
{
    if (uploadRecentAverageBytes >= CBGigabyte)
        return [NSString stringWithFormat:@"%@ %@", [BOINCNetStatistics formattedStringFromStatistic:(uploadRecentAverageBytes / CBGigabyte)], NSLocalizedString(@"GB/day", @"")];
    
    if (uploadRecentAverageBytes >= CBMegabyte)
        return [NSString stringWithFormat:@"%@ %@", [BOINCNetStatistics formattedStringFromStatistic:(uploadRecentAverageBytes / CBMegabyte)], NSLocalizedString(@"MB/day", @"")];
    
    return [NSString stringWithFormat:@"%@ %@", [BOINCNetStatistics formattedStringFromStatistic:(uploadRecentAverageBytes / CBKilobyte)], NSLocalizedString(@"KB/day", @"")];
}


- (NSString *)downloadRecentAverageBytesString
{
    if (downloadRecentAverageBytes >= CBGigabyte)
        return [NSString stringWithFormat:@"%@ %@", [BOINCNetStatistics formattedStringFromStatistic:(downloadRecentAverageBytes / CBGigabyte)], NSLocalizedString(@"GB/day", @"")];
    
    if (downloadRecentAverageBytes >= CBMegabyte)
        return [NSString stringWithFormat:@"%@ %@", [BOINCNetStatistics formattedStringFromStatistic:(downloadRecentAverageBytes / CBMegabyte)], NSLocalizedString(@"MB/day", @"")];
    
    return [NSString stringWithFormat:@"%@ %@", [BOINCNetStatistics formattedStringFromStatistic:(downloadRecentAverageBytes / CBKilobyte)], NSLocalizedString(@"KB/day", @"")];
}



- (void)setUploadAverageUpdatedFromDouble:(double)updateTime
{
    self.uploadAverageUpdated = [NSDate dateWithTimeIntervalSince1970:updateTime];
}

- (void)setDownloadAverageUpdatedFromDouble:(double)updateTime
{
    self.downloadAverageUpdated = [NSDate dateWithTimeIntervalSince1970:updateTime];
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
    [parseDescription addDoubleSelector:@selector(setUploadBandwidthRate:)              forElement:@"bwup"];
    [parseDescription addDoubleSelector:@selector(setUploadRecentAverageBytes:)         forElement:@"avg_up"];
    [parseDescription addDoubleSelector:@selector(setUploadAverageUpdatedFromDouble:)   forElement:@"avg_time_up"];
    [parseDescription addDoubleSelector:@selector(setDownloadBandwidthRate:)            forElement:@"bwdown"];
    [parseDescription addDoubleSelector:@selector(setDownloadRecentAverageBytes:)       forElement:@"avg_down"];
    [parseDescription addDoubleSelector:@selector(setDownloadAverageUpdatedFromDouble:) forElement:@"avg_time_down"];
    
    
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
    [theDescription appendFormat:@"%@    uploadBandwidthRate        = %f\n", indentString, self.uploadBandwidthRate];
    [theDescription appendFormat:@"%@    uploadRecentAverageBytes   = %f\n", indentString, self.uploadRecentAverageBytes];
    [theDescription appendFormat:@"%@    uploadAverageUpdated       = %@\n", indentString, self.uploadAverageUpdated];
    [theDescription appendFormat:@"%@    downloadBandwidthRate      = %f\n", indentString, self.downloadBandwidthRate];
    [theDescription appendFormat:@"%@    downloadRecentAverageBytes = %f\n", indentString, self.downloadRecentAverageBytes];
    [theDescription appendFormat:@"%@    downloadAverageUpdated     = %@\n", indentString, self.downloadAverageUpdated];
    
    return theDescription;
}

@end
