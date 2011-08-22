//
//  BOINCPlatform.m
//  BOINCMenubar
//
//  Created by BrotherBard on 1/13/09.
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

#import "BOINCPlatform.h"
#import "BBXMLReader.h"
#import "BBXMLParsingDescription.h"


@interface BOINCPlatform()

- (void)updateFriendlyNames;

@end



@implementation BOINCPlatform


@synthesize name;
@synthesize userFriendlyName;
@synthesize operatingSystemName;
@synthesize architectureName;
@synthesize supportedPlatforms;

@synthesize isCurrentPlatform;
@synthesize checkmark;



///////////////////////////////////////////////////////////


+ (NSDictionary *)userFriendlyPlatformNames
{
    static NSDictionary *platformNames = nil;
    
    if (platformNames)
        return platformNames;
    
    NSDictionary *classDictionary = [NSDictionary dictionaryWithObject:[BOINCPlatform class] forKey:@"platform"];
    NSString *platformsXML = [NSString stringWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"Platform Names" ofType:@"xml"] encoding:NSUTF8StringEncoding error:nil];
    
    NSArray *replyObjects = [BBXMLReader objectsInClassDictionary:classDictionary fromXMLString:platformsXML];
    
    NSMutableDictionary* platforms = [NSMutableDictionary dictionary];
    for (BOINCPlatform *platform in replyObjects)
        [platforms setObject:platform forKey:platform.name];
    
    platformNames = [platforms copy];
    
    return platformNames;
}


+ (id)platformWithName:(NSString *)platformName
{
    return [[[self alloc] initWithName:platformName] autorelease];
}


- (id)init
{
    self = [super init];
    if (!self) return nil;
    
    return self;
}


- (id)initWithName:(NSString *)platformName
{
    self = [self init];
    if (!self) return nil;
    
    name = [platformName copy];
    checkmark = @"";
    [self updateFriendlyNames];
    
    return self;
}


- (void)dealloc
{
    [name                release];
    [userFriendlyName    release];
    [operatingSystemName release];
    [architectureName    release];
    [supportedPlatforms  release];
    [checkmark           release];
    
    [super dealloc];
}


#pragma mark <NSCopying>
- (id)copyWithZone:(NSZone *)zone
{
    BOINCPlatform *copiedPlatform    = [[BOINCPlatform alloc] initWithName:self.name];
    copiedPlatform.isCurrentPlatform = self.isCurrentPlatform;
    copiedPlatform.checkmark         = self.checkmark;
    
    return copiedPlatform;
}



#pragma mark BOINCPlatform methods
- (void)addSupportedPlatform:(NSString *)platformName
{
    if (supportedPlatforms == nil)
        self.supportedPlatforms = [NSMutableArray array];
    
    if (platformName)
        [supportedPlatforms addObject:platformName];
}


- (void)updateFriendlyNames
{
    BOINCPlatform *friendlyPlatform = [[BOINCPlatform userFriendlyPlatformNames] objectForKey:self.name];
    
    if (friendlyPlatform) {
        self.userFriendlyName    = friendlyPlatform.userFriendlyName;
        self.operatingSystemName = friendlyPlatform.operatingSystemName;
        self.architectureName    = friendlyPlatform.architectureName;
        self.supportedPlatforms  = [[friendlyPlatform.supportedPlatforms mutableCopy] autorelease];
    } 
    else {
        self.operatingSystemName = NSLocalizedString(@"Unknown", @"Unknown platform name");
        self.architectureName    = self.name;
    }
}


- (void)finishedXMLParsing
{
    if (!self.userFriendlyName)
        [self updateFriendlyNames];
    
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
    [parseDescription addStringSelector:@selector(setName:)                forElement:@"name"];
    
    [parseDescription addStringSelector:@selector(setName:)                forElement:@"platform_name"];
    [parseDescription addStringSelector:@selector(setUserFriendlyName:)    forElement:@"user_friendly_name"];
    
    [parseDescription addStringSelector:@selector(setOperatingSystemName:) forElement:@"operating_system_name"];
    [parseDescription addStringSelector:@selector(setArchitectureName:)    forElement:@"architecture_name"];
    [parseDescription addStringSelector:@selector(addSupportedPlatform:)   forElement:@"supported_platform"];
    
    [parseDescription addParsingCompletionSelector:@selector(finishedXMLParsing)];
    
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
    
    [theDescription appendFormat:@"%@   name                = %@\n", indentString, self.name];
    [theDescription appendFormat:@"%@   userFriendlyName    = %@\n", indentString, self.userFriendlyName];
    [theDescription appendFormat:@"%@   operatingSystemName = %@\n", indentString, self.operatingSystemName];
    [theDescription appendFormat:@"%@   architectureName    = %@\n", indentString, self.architectureName];
    [theDescription appendFormat:@"%@   isCurrentPlatform   = %@\n", indentString, self.isCurrentPlatform ? @"YES" : @"NO"];
    [theDescription appendFormat:@"%@   checkmark           = %@\n", indentString, self.checkmark];
    
    if ([supportedPlatforms count] == 0)
    	[theDescription appendFormat:@"%@    supportedPlatforms = <none>\n", indentString];
    else {
        int i = 0;
        for (NSString *platformName in supportedPlatforms)
            [theDescription appendFormat:@"%@    supportedPlatform[%d] = %@\n", indentString, i++, platformName];
    }
    
    return theDescription;
}



@end
