//
//  BOINCHostInfo.h
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

#import <Cocoa/Cocoa.h>
#import "BBXMLParsingDescription.h"


@interface BOINCHostInfo : NSObject <BBXMLModelObject>
{
    NSTimeZone *timeZone;                // <timezone>
    NSString   *domainName;              // <domain_name>
    NSString   *hostAddress;             // <ip_addr>
    NSString   *hostCPID;                // <host_cpid>
    
    NSString   *operatingSystemName;     // <os_name>
    NSString   *operatingSystemVersion;  // <os_version>
    
    NSString   *cpuVender;               // <p_vendor>
    NSString   *cpuModel;                // <p_model>
    NSString   *cpuFeatures;             // <p_features>
    NSInteger   cpuCount;                // <p_ncpus>
    double      cpuFloatOperations;      // <p_fpops>
    double      cpuIntOperations;        // <p_iops>
    double      cpuMemoryBandwidth;      // <p_membw>
    double      cpuCalculated;           // <p_calculated>
    
    double      ramSize;                 // <m_nbytes>
    double      ramCacheSize;            // <m_cache>
    double      swapSpace;               // <m_swap>
    double      diskSize;                // <d_total>
    double      diskFreeSpace;           // <d_free>
    
    //NSMutableArray *accelerators;            // <accelerators>
}
@property (nonatomic, copy)   NSTimeZone *timeZone;
@property (nonatomic, copy)   NSString   *domainName;
@property (nonatomic, copy)   NSString   *hostAddress;
@property (nonatomic, copy)   NSString   *hostCPID;

@property (nonatomic, copy)   NSString   *operatingSystemName;
@property (nonatomic, copy)   NSString   *operatingSystemVersion;

@property (nonatomic, copy)   NSString   *cpuVender;
@property (nonatomic, copy)   NSString   *cpuModel;
@property (nonatomic, copy)   NSString   *cpuFeatures;
@property (nonatomic, assign) NSInteger   cpuCount;
@property (nonatomic, assign) double      cpuFloatOperations;
@property (nonatomic, assign) double      cpuIntOperations;
@property (nonatomic, assign) double      cpuMemoryBandwidth;
@property (nonatomic, assign) double      cpuCalculated;

@property (nonatomic, assign) double      ramSize;
@property (nonatomic, assign) double      ramCacheSize;
@property (nonatomic, assign) double      swapSpace;
@property (nonatomic, assign) double      diskSize;
@property (nonatomic, assign) double      diskFreeSpace;

@property (readonly)          NSString   *fullOSNameString;
@property (readonly)          NSArray    *operatingSystemDescriptionArray;
@property (readonly)          NSArray    *cpuModelDescriptionArray;
@property (readonly)          NSString   *cpuFloatOperationsString;
@property (readonly)          NSString   *cpuIntOperationsString;
@property (readonly)          NSString   *ramSizeString;
@property (readonly)          NSString   *ramCacheSizeString;
@property (readonly)          NSString   *diskSizeString;
@property (readonly)          NSString   *diskFreeSpaceString;

//@property (nonatomic, assign) NSMutableArray *accelerators;



- (NSString *)fullOSNameString;
- (NSArray *)operatingSystemDescriptionArray;
- (NSArray *)cpuModelDescriptionArray;
- (NSString *)cpuFloatOperationsString;
- (NSString *)cpuIntOperationsString;
- (NSString *)ramSizeString;
- (NSString *)ramCacheSizeString;
- (NSString *)diskSizeString;
- (NSString *)diskFreeSpaceString;
- (NSString *)cpuCountString;


- (NSString *)debugDescriptionWithIndent:(NSInteger)indent;
- (NSString *)debugDescription;


@end
