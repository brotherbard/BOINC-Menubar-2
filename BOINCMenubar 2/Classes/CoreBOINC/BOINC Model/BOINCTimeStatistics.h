//
//  BOINCTimeStatistics.h
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


@interface BOINCTimeStatistics : NSObject <BBXMLModelObject>
{
    double  onFraction;         //  <on_frac>
    double  connectedFraction;  //  <connected_frac>
    double  activeFraction;     //  <active_frac>
    double  cpuEfficiency;      //  <cpu_efficiency>  this was removed in 6.4.3 because it was inaccurate
    NSDate *lastUpdate;         //  <last_update>
}
@property (nonatomic, assign) double    onFraction;
@property (nonatomic, assign) double    connectedFraction;
@property (nonatomic, assign) double    activeFraction;
@property (nonatomic, assign) double    cpuEfficiency;
@property (nonatomic, copy)   NSDate   *lastUpdate;

@property (readonly)          NSString *onFractionString;
@property (readonly)          NSString *connectedFractionString;
@property (readonly)          NSString *activeFractionString;
@property (readonly)          NSString *cpuEfficiencyString;


- (NSString *)onFractionString;
- (NSString *)connectedFractionString;
- (NSString *)activeFractionString;
- (NSString *)cpuEfficiencyString;


- (NSString *)debugDescriptionWithIndent:(NSInteger)indent;
- (NSString *)debugDescription;


@end
