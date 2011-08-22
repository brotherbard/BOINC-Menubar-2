//
//  BOINCURL.m
//  BOINCMenubar
//
//  Created by BrotherBard on 3/30/08.
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

#import "BOINCURL.h"


@implementation BOINCURL

@synthesize urlName;
@synthesize url;
@synthesize urlDescription;

///////////////////////////////////////////////////////////

- (id)initWithName:(NSString *)projectName url:(NSString *)masterURL
{
    self = [super init];
    if (!self) return nil;
    
    urlName        = [projectName copy];
    url            = [masterURL copy];
    urlDescription = [[NSString alloc] initWithFormat:@"The %@ website", projectName];
    
    return self;
}

- (void)dealloc
{
    [urlName        release];
    [url            release];
    [urlDescription release];
    
    [super dealloc];
}



///////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSObject methods

// Equal objects must hash the same, so test the same data that is used to create the hash

- (BOOL)isEqual:(id)object
{
    if (![object isMemberOfClass:[BOINCURL class]])
        return NO;
    
    return [self.url isEqualToString:((BOINCURL *)object).url];
}

- (NSUInteger)hash
{
    return [self.url hash];
}



#pragma mark <NSCopying>
- (id)copyWithZone:(NSZone *)zone
{
    BOINCURL *copiedURL = [[BOINCURL allocWithZone:zone] initWithName:self.urlName url:self.url];
    
    return copiedURL;
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
    [parseDescription addStringSelector:@selector(setUrlName:)        forElement:@"name"];
    [parseDescription addStringSelector:@selector(setUrl:)            forElement:@"url"];
    [parseDescription addStringSelector:@selector(setUrlDescription:) forElement:@"description"];
    
    return parseDescription;
}



///////////////////////////////////////////////////////////
#pragma mark -
#pragma mark debug

// for debugging
- (NSString *) debugDescription
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
    [theDescription appendFormat:@"%@    urlName        = %@\n", indentString, self.urlName];
    [theDescription appendFormat:@"%@    url            = %@\n", indentString, self.url];
    [theDescription appendFormat:@"%@    urlDescription = %@\n", indentString, self.urlDescription];
    
    return theDescription;
}

@end
