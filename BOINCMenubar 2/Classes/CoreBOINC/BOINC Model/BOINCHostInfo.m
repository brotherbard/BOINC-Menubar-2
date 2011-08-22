//
//  BOINCHostInfo.m
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

#import "BOINCHostInfo.h"
#import "BOINCCommonConstants.h"



@implementation BOINCHostInfo


@synthesize timeZone;
@synthesize domainName;
@synthesize hostAddress;
@synthesize hostCPID;
@synthesize cpuCount;
@synthesize cpuVender;
@synthesize cpuModel;
@synthesize cpuFeatures;
@synthesize cpuFloatOperations;
@synthesize cpuIntOperations;
@synthesize cpuMemoryBandwidth;
@synthesize cpuCalculated;
@synthesize ramSize;
@synthesize ramCacheSize;
@synthesize swapSpace;
@synthesize diskSize;
@synthesize diskFreeSpace;
@synthesize operatingSystemName;
@synthesize operatingSystemVersion;

@dynamic    fullOSNameString;
@dynamic    operatingSystemDescriptionArray;
@dynamic    cpuModelDescriptionArray;
@dynamic    cpuFloatOperationsString;
@dynamic    cpuIntOperationsString;
@dynamic    ramSizeString;
@dynamic    ramCacheSizeString;
@dynamic    diskSizeString;
@dynamic    diskFreeSpaceString;

//@synthesize accelerators;





+ (NSString *)formattedStringFromInfo:(double)info
{
    static NSNumberFormatter *hostInfoFormatter = nil;
    if (hostInfoFormatter == nil) {
        hostInfoFormatter = [[NSNumberFormatter alloc] init];
        [hostInfoFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [hostInfoFormatter setRoundingMode:NSNumberFormatterRoundHalfUp];
        [hostInfoFormatter setHasThousandSeparators:YES];
        [hostInfoFormatter setMaximumFractionDigits:2];
        [hostInfoFormatter setMinimumFractionDigits:0];
        [hostInfoFormatter setNotANumberSymbol:@"0"];
    }
    
    return [hostInfoFormatter stringFromNumber:[NSNumber numberWithDouble:info]];
}



- (void)dealloc
{
    [timeZone               release];             
    [domainName             release];           
    [hostAddress            release];          
    [hostCPID               release];             
    [operatingSystemName    release];  
    [operatingSystemVersion release];
    [cpuVender              release];            
    [cpuModel               release];             
    [cpuFeatures            release];          
    
    [super dealloc];
}



// put the OS and Version strings together
// output:
//   Darwin 9.6.0
// or:
//   Linux 2.6.18-92.1.22.el5
// or:
//   Microsoft Windows Server 2008 Enterprise x64 Editon, Service Pack 1, (06.00.6001.00)
- (NSString *)fullOSNameString
{
    return [NSString stringWithFormat:@"%@ %@", self.operatingSystemName, self.operatingSystemVersion];
}


- (NSArray *)operatingSystemDescriptionArray
{
    NSMutableArray *osDescriptionArray = [NSMutableArray array];
    
    NSString *osString = self.fullOSNameString;
    
    // 50 is an arbitrary length I chose to limit the length of this line
    if ([osString length] < 50) {
        [osDescriptionArray addObject:osString];
        return [[osDescriptionArray copy] autorelease];
    }
    
    
    // output:
    //   Microsoft Windows Server 2008 
    [osDescriptionArray addObject:self.operatingSystemName];
    
    
    // windoze computers have really long Version strings so seperate everything out into individual lines
    
    // example string "Enterprise x64 Editon, Service Pack 1, (06.00.6001.00)"
    // output:
    //   Enterprise x64 Editon
    //   Service Pack 1
    //   (06.00.6001.00)
    NSArray *versionLines = [self.operatingSystemVersion componentsSeparatedByString:@","];
    for (NSString *line in versionLines) {
        line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([line isEqualToString:@""])
            continue;
        [osDescriptionArray addObject:line];
    }
    
    return [[osDescriptionArray copy] autorelease];
}


- (NSArray *)cpuModelDescriptionArray
{
    return [[cpuModel stringByReplacingOccurrencesOfString:@"]" withString:@""] componentsSeparatedByString:@"["];
}


- (NSString *)cpuFloatOperationsString
{
    return [NSString stringWithFormat:@"%@ %@", [BOINCHostInfo formattedStringFromInfo:(cpuFloatOperations / CBMegaOperations)], NSLocalizedString(@"million ops/sec", @"")];
}


- (NSString *)cpuIntOperationsString
{
    return [NSString stringWithFormat:@"%@ %@", [BOINCHostInfo formattedStringFromInfo:(cpuIntOperations / CBMegaOperations)], NSLocalizedString(@"million ops/sec", @"")];
}


- (NSString *)ramSizeString
{
    if (ramSize >= CBGigabyte)
        return [NSString stringWithFormat:@"%@ %@", [BOINCHostInfo formattedStringFromInfo:(ramSize / CBGigabyte)], NSLocalizedString(@"GB", @"")];
    
    return [NSString stringWithFormat:@"%@ %@", [BOINCHostInfo formattedStringFromInfo:(ramSize / CBMegabyte)], NSLocalizedString(@"MB", @"")];
}


- (NSString *)ramCacheSizeString
{
    if (ramCacheSize >= CBMegabyte)
        return [NSString stringWithFormat:@"%@ %@", [BOINCHostInfo formattedStringFromInfo:(ramCacheSize / CBMegabyte)], NSLocalizedString(@"MB", @"")];
    
    return [NSString stringWithFormat:@"%@ %@", [BOINCHostInfo formattedStringFromInfo:(ramCacheSize / CBKilobyte)], NSLocalizedString(@"KB", @"")];
}


- (NSString *)diskSizeString
{
    if (diskSize >= CBTerabyte)
        return [NSString stringWithFormat:@"%@ %@", [BOINCHostInfo formattedStringFromInfo:(diskSize / CBTerabyte)], NSLocalizedString(@"TB", @"")];
    
    if (diskSize >= CBGigabyte)
        return [NSString stringWithFormat:@"%@ %@", [BOINCHostInfo formattedStringFromInfo:(diskSize / CBGigabyte)], NSLocalizedString(@"GB", @"")];
    
    return [NSString stringWithFormat:@"%@ %@", [BOINCHostInfo formattedStringFromInfo:(diskSize / CBMegabyte)], NSLocalizedString(@"MB", @"")];
}


- (NSString *)diskFreeSpaceString
{
    if (diskFreeSpace >= CBTerabyte)
        return [NSString stringWithFormat:@"%@ %@", [BOINCHostInfo formattedStringFromInfo:(diskFreeSpace / CBTerabyte)], NSLocalizedString(@"TB", @"")];
    
    if (diskFreeSpace >= CBGigabyte)
        return [NSString stringWithFormat:@"%@ %@", [BOINCHostInfo formattedStringFromInfo:(diskFreeSpace / CBGigabyte)], NSLocalizedString(@"GB", @"")];
    
    return [NSString stringWithFormat:@"%@ %@", [BOINCHostInfo formattedStringFromInfo:(diskFreeSpace / CBMegabyte)], NSLocalizedString(@"MB", @"")];
}


- (NSString *)cpuCountString
{
    return [[NSNumber numberWithInteger:cpuCount] stringValue];
}




- (void)setTimeZoneFromXML:(NSString *)timeString
{
    self.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:[timeString floatValue]];
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
    
    [parseDescription addStringSelector:   @selector(setTimeZoneFromXML:)        forElement:@"timezone"];
    [parseDescription addStringSelector:   @selector(setDomainName:)             forElement:@"domain_name"];
    [parseDescription addStringSelector:   @selector(setHostAddress:)            forElement:@"ip_addr"];
    [parseDescription addStringSelector:   @selector(setHostCPID:)               forElement:@"host_cpid"];
    [parseDescription addStringSelector:   @selector(setOperatingSystemName:)    forElement:@"os_name"];
    [parseDescription addStringSelector:   @selector(setOperatingSystemVersion:) forElement:@"os_version"];
    [parseDescription addStringSelector:   @selector(setCpuVender:)              forElement:@"p_vendor"];
    [parseDescription addStringSelector:   @selector(setCpuModel:)               forElement:@"p_model"];
    [parseDescription addStringSelector:   @selector(setCpuFeatures:)            forElement:@"p_features"];
    [parseDescription addNSIntegerSelector:@selector(setCpuCount:)               forElement:@"p_ncpus"];
    [parseDescription addDoubleSelector:   @selector(setCpuFloatOperations:)     forElement:@"p_fpops"];
    [parseDescription addDoubleSelector:   @selector(setCpuIntOperations:)       forElement:@"p_iops"];
    [parseDescription addDoubleSelector:   @selector(setCpuMemoryBandwidth:)     forElement:@"p_membw"];
    [parseDescription addDoubleSelector:   @selector(setCpuCalculated:)          forElement:@"p_calculated"];
    [parseDescription addDoubleSelector:   @selector(setRamSize:)                forElement:@"m_nbytes"];
    [parseDescription addDoubleSelector:   @selector(setRamCacheSize:)           forElement:@"m_cache"];
    [parseDescription addDoubleSelector:   @selector(setSwapSpace:)              forElement:@"m_swap"];
    [parseDescription addDoubleSelector:   @selector(setDiskSize:)               forElement:@"d_total"];
    [parseDescription addDoubleSelector:   @selector(setDiskFreeSpace:)          forElement:@"d_free"];
    
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
    [theDescription appendFormat:@"%@    domainName             = %@\n", indentString, self.domainName];
    [theDescription appendFormat:@"%@    hostAddress            = %@\n", indentString, self.hostAddress];
    [theDescription appendFormat:@"%@    hostCPID               = %@\n", indentString, self.hostCPID];
    [theDescription appendFormat:@"%@    timeZone               = %@\n", indentString, self.timeZone];
    
    [theDescription appendFormat:@"%@    operatingSystemName    = %@\n", indentString, self.operatingSystemName];
    [theDescription appendFormat:@"%@    operatingSystemVersion = %@\n", indentString, self.operatingSystemVersion];
    
    [theDescription appendFormat:@"%@    cpuVender              = %@\n", indentString, self.cpuVender];
    [theDescription appendFormat:@"%@    cpuModel               = %@\n", indentString, self.cpuModel];
    [theDescription appendFormat:@"%@    cpuFeatures            = %@\n", indentString, self.cpuFeatures];
    [theDescription appendFormat:@"%@    cpuCount               = %d\n", indentString, self.cpuCount];
    [theDescription appendFormat:@"%@    cpuFloatOperations     = %f\n", indentString, self.cpuFloatOperations];
    [theDescription appendFormat:@"%@    cpuIntOperations       = %f\n", indentString, self.cpuIntOperations];
    [theDescription appendFormat:@"%@    cpuMemoryBandwidth     = %f\n", indentString, self.cpuMemoryBandwidth];
    [theDescription appendFormat:@"%@    cpuCalculated          = %f\n", indentString, self.cpuCalculated];
    
    [theDescription appendFormat:@"%@    ramSize                = %f\n", indentString, self.ramSize];
    [theDescription appendFormat:@"%@    ramCacheSize           = %f\n", indentString, self.ramCacheSize];
    [theDescription appendFormat:@"%@    swapSpace              = %f\n", indentString, self.swapSpace];
    [theDescription appendFormat:@"%@    diskSize               = %f\n", indentString, self.diskSize];
    [theDescription appendFormat:@"%@    diskFreeSpace          = %f\n", indentString, self.diskFreeSpace];
    
    return theDescription;
}


@end
