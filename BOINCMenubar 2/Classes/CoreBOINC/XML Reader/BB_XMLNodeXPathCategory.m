//
//  BB_XMLNodeXPathCategory.m
//  BrotherBard's NSXMLNode XPath Additions
//
//  Created by BrotherBard on 3/14/08.
//  Copyright 2008-2009 BrotherBard <nkinsinger at brotherbard dot com>. All rights reserved.
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

#import "BB_XMLNodeXPathCategory.h"


@implementation NSXMLNode (BB_XMLNodeXPathCategory)

- (NSString *)bb_XMLStringFromXPath:(NSString *)nodePath
{
    NSArray *nodeArray = [self nodesForXPath:nodePath error:nil];
    return [nodeArray count] ? [[nodeArray objectAtIndex:0] XMLString] : nil;
}

- (NSString *)bb_StringFromXPath:(NSString *)nodePath
{
    NSArray *nodeArray = [self nodesForXPath:nodePath error:nil];
    return [nodeArray count] ? [[nodeArray objectAtIndex:0] stringValue] : nil;
}

- (NSString *)bb_NonNilStringFromXPath:(NSString *)nodePath
{
    NSArray *nodeArray = [self nodesForXPath:nodePath error:nil];
    return [nodeArray count] ? [[nodeArray objectAtIndex:0] stringValue] : @"";
}


- (double)bb_DoubleFromXPath:(NSString *)nodePath
{
    NSArray *nodeArray = [self nodesForXPath:nodePath error:nil];
    return [nodeArray count] ? [[[nodeArray objectAtIndex:0] stringValue] doubleValue] : 0.0;
}

- (int)bb_IntFromXPath:(NSString *)nodePath
{
    NSArray *nodeArray = [self nodesForXPath:nodePath error:nil];
    return [nodeArray count] ? [[[nodeArray objectAtIndex:0] stringValue] intValue] : 0;
}

- (BOOL)bb_BOOLFromXPath:(NSString *)nodePath
{
    NSArray *nodeArray = [self nodesForXPath:nodePath error:nil];
    
    // if the path doesn't exist it's false
    if ([nodeArray count] == 0)
        return NO;
    
    NSString *stringValue = [[nodeArray objectAtIndex:0] stringValue];

    // an empty element <element/> or <element></element> is true
    if ([stringValue boolValue] || [stringValue isEqualToString:@""]) 
        return YES;
    
    return NO;
}


@end
