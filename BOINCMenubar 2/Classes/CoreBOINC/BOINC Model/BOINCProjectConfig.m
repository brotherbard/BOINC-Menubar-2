//
//  BOINCProjectConfig.m
//  BOINCMenubar
//
//  Created by BrotherBard on 3/22/09.
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

#import "BOINCProjectConfig.h"
#import "BOINCPlatform.h"


@implementation BOINCProjectConfig

@synthesize projectName;
@synthesize masterURL;
@synthesize rpcPrefix;
@synthesize minPasswordLength;

@synthesize clientAccountCreationDisabled;
@synthesize accountCreationDisabled;
@synthesize webStopped;
@synthesize schedulerStopped;
@synthesize usesUsername;
@synthesize accountManager;

@synthesize termsOfUse;
@synthesize platforms;

@synthesize errorNumber;
@synthesize errorMessage;


- (void) dealloc
{
    [projectName  release];
    [masterURL    release];
    [rpcPrefix    release];
    [termsOfUse   release];
    [platforms    release];
    [errorMessage release];
    
    [super dealloc];
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
    [parseDescription addStringSelector:   @selector(setProjectName:)                   forElement:@"name"];
    [parseDescription addStringSelector:   @selector(setMasterURL:)                     forElement:@"master_url"];
    [parseDescription addStringSelector:   @selector(setRpcPrefix:)                     forElement:@"rpc_prefix"];
    [parseDescription addIntSelector:      @selector(setMinPasswordLength:)             forElement:@"min_passwd_length"];
    
    [parseDescription addBoolSelector:     @selector(setClientAccountCreationDisabled:) forElement:@"client_account_creation_disabled"];
    [parseDescription addBoolSelector:     @selector(setAccountCreationDisabled:)       forElement:@"account_creation_disabled"];
    [parseDescription addBoolSelector:     @selector(setWebStopped:)                    forElement:@"web_stopped"];
    [parseDescription addBoolSelector:     @selector(setSchedulerStopped:)              forElement:@"sched_stopped"];
    [parseDescription addBoolSelector:     @selector(setUsesUsername:)                  forElement:@"uses_username"];
    [parseDescription addBoolSelector:     @selector(setAccountManager:)                forElement:@"account_manager"];
    
    [parseDescription addIntSelector:      @selector(setErrorNumber:)                   forElement:@"error_num"];
    [parseDescription addStringSelector:   @selector(setErrorMessage:)                  forElement:@"message"];// need to fix this
    
    [parseDescription addXMLStringSelector:@selector(setTermsOfUse:)                    forElement:@"terms_of_use"];
    NSDictionary *platformDictionary = [NSDictionary dictionaryWithObject:[BOINCPlatform class] forKey:@"platform"];
    [parseDescription addArraySelector:@selector(setPlatforms:) withClassDictionary:platformDictionary forElement:@"platforms"];
    
    //[parseDescription addParsingCompletionSelector:@selector(finishedXMLParsing)];
    
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
    [theDescription appendFormat:@"%@    projectName                   = %@\n", indentString, self.projectName];
    [theDescription appendFormat:@"%@    masterURL                     = %@\n", indentString, self.masterURL];
    [theDescription appendFormat:@"%@    rpcPrefix                     = %@\n", indentString, self.rpcPrefix];
    [theDescription appendFormat:@"%@    minPasswordLength             = %d\n", indentString, self.minPasswordLength];
    
    [theDescription appendFormat:@"%@    clientAccountCreationDisabled = %@\n", indentString, self.clientAccountCreationDisabled ? @"YES" : @"NO"];
    [theDescription appendFormat:@"%@    accountCreationDisabled       = %@\n", indentString, self.accountCreationDisabled       ? @"YES" : @"NO"];
    [theDescription appendFormat:@"%@    webStopped                    = %@\n", indentString, self.webStopped                    ? @"YES" : @"NO"];
    [theDescription appendFormat:@"%@    schedulerStopped              = %@\n", indentString, self.schedulerStopped              ? @"YES" : @"NO"];
    [theDescription appendFormat:@"%@    usesUsername                  = %@\n", indentString, self.usesUsername                  ? @"YES" : @"NO"];
    [theDescription appendFormat:@"%@    accountManager                = %@\n", indentString, self.accountManager                ? @"YES" : @"NO"];
    
    [theDescription appendFormat:@"%@    errorNumber                   = %d\n", indentString, self.errorNumber];
    [theDescription appendFormat:@"%@    errorMessage                  = %@\n", indentString, self.errorMessage];
    
    [theDescription appendFormat:@"%@    termsOfUse                    = %@\n", indentString, self.termsOfUse];
    if (self.platforms)
        for (BOINCPlatform *platform in self.platforms)
            [theDescription appendString:[platform debugDescriptionWithIndent:indent + 1]];
    
    
    return theDescription;
}


@end
