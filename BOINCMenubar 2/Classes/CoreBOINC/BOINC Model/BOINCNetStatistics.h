//
//  BOINCNetStatistics.h
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

#import <Cocoa/Cocoa.h>
#import "BBXMLParsingDescription.h"

// in the boinc code <bwup> and <bwdown> are listed as:
//   / estimate of max transfer rate; computed as an average of
//   / the rates of recent file transfers, weighted by file size.
//   / This ignores concurrency of transfers.
// and they are what the host computer summary web pages use as "Average upload rate" and "Average download rate"

// the <avg_up> and <avg_down> seem like they are recent average bytes per day
// boinc uses the same update_average() method that it does for RAC


@interface BOINCNetStatistics : NSObject <BBXMLModelObject>
{
    double  uploadBandwidthRate;        //  <bwup>
    double  uploadRecentAverageBytes;   //  <avg_up>
    NSDate *uploadAverageUpdated;       //  <avg_time_up>
    double  downloadBandwidthRate;      //  <bwdown>
    double  downloadRecentAverageBytes; //  <avg_down>
    NSDate *downloadAverageUpdated;     //  <avg_time_down>
}
@property (nonatomic, assign) double  uploadBandwidthRate;
@property (nonatomic, assign) double  uploadRecentAverageBytes;
@property (nonatomic, copy)   NSDate *uploadAverageUpdated;
@property (nonatomic, assign) double  downloadBandwidthRate;
@property (nonatomic, assign) double  downloadRecentAverageBytes;
@property (nonatomic, copy)   NSDate *downloadAverageUpdated;

- (NSString *)uploadBandwidthRateString;
- (NSString *)downloadBandwidthRateString;
- (NSString *)uploadRecentAverageBytesString;
- (NSString *)downloadRecentAverageBytesString;


- (NSString *)debugDescriptionWithIndent:(NSInteger)indent;
- (NSString *)debugDescription;


@end
