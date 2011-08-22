//
//  BOINCClientVersion.m
//  BOINCMenubar
//
//  Created by BrotherBard on 1/25/09.
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

#import "BOINCClientVersion.h"


@implementation BOINCClientVersion

@synthesize majorVersion;
@synthesize minorVersion;
@synthesize releaseVersion;

@dynamic    versionString;



///////////////////////////////////////////////////////////
#pragma mark -
#pragma mark test version 

- (BOOL)isEqualOrLaterToMajorVersion:(int)major minor:(int)minor release:(int)release
{
    if (self.majorVersion > major)
        return NO;
    if (self.majorVersion < major)
        return YES;
    
    if (self.minorVersion > minor)
        return NO;
    if (self.minorVersion < minor)
        return YES;
    
    if (self.releaseVersion > release)
        return NO;
    return YES;
}


- (NSString *)versionString
{
    return [NSString stringWithFormat:@"%d.%d.%d", self.majorVersion, self.minorVersion, self.releaseVersion];
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
    [parseDescription addIntSelector:@selector(setMajorVersion:)   forElement:@"major"];
    [parseDescription addIntSelector:@selector(setMinorVersion:)   forElement:@"minor"];
    [parseDescription addIntSelector:@selector(setReleaseVersion:) forElement:@"release"];
    
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
    [theDescription appendFormat:@"%@    majorVersion   = %d\n", indentString, self.majorVersion];
    [theDescription appendFormat:@"%@    minorVersion   = %d\n", indentString, self.minorVersion];
    [theDescription appendFormat:@"%@    releaseVersion = %d\n", indentString, self.releaseVersion];
    
    return theDescription;
}


- (NSString *)description
{
    return self.versionString;
}



@end
