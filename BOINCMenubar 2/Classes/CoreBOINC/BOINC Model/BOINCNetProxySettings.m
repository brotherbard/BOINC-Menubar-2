//
//  BOINCNetProxySettings.m
//  BOINCMenubar
//
//  Created by BrotherBard on 9/23/08.
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

#import "BOINCNetProxySettings.h"


@implementation BOINCNetProxySettings

@synthesize socksVersion;
@synthesize socksServerName;
@synthesize socksServerPort;
@synthesize socks5UserName;
@synthesize socks5UserPassword;
@synthesize useSocksProxy;

@synthesize httpServerName;
@synthesize httpServerPort;
@synthesize httpUserName;
@synthesize httpUserPassword;
@synthesize useHTTPProxy;
@synthesize useHTTPAuthorization;



- (void)dealloc
{
    [socksServerName    release];
    [socks5UserName     release];
    [socks5UserPassword release];
    [httpServerName     release];
    [httpUserName       release];
    [httpUserPassword   release];
    
    [super dealloc];
}


- (id)copyWithZone:(NSZone *)zone
{
    BOINCNetProxySettings *copiedProxy = [[BOINCNetProxySettings allocWithZone:zone] init];
    
    copiedProxy.socksVersion         = self.socksVersion;
    copiedProxy.socksServerName      = self.socksServerName;
    copiedProxy.socksServerPort      = self.socksServerPort;
    copiedProxy.socks5UserName       = self.socks5UserName;
    copiedProxy.socks5UserPassword   = self.socks5UserPassword;
    copiedProxy.useSocksProxy        = self.useSocksProxy;
    
    copiedProxy.httpServerName       = self.httpServerName;
    copiedProxy.httpServerPort       = self.httpServerPort;
    copiedProxy.httpUserName         = self.httpUserName;
    copiedProxy.httpUserPassword     = self.httpUserPassword;
    copiedProxy.useHTTPProxy         = self.useHTTPProxy;
    copiedProxy.useHTTPAuthorization = self.useHTTPAuthorization;
    
    return copiedProxy;
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
    [parseDescription addNSIntegerSelector:@selector(setSocksVersion:)         forElement:@"socks_version"];
    [parseDescription addStringSelector:   @selector(setSocksServerName:)      forElement:@"socks_server_name"];
    [parseDescription addNSIntegerSelector:@selector(setSocksServerPort:)      forElement:@"socks_server_port"];
    [parseDescription addStringSelector:   @selector(setSocks5UserName:)       forElement:@"socks5_user_name"];
    [parseDescription addStringSelector:   @selector(setSocks5UserPassword:)   forElement:@"socks5_user_passwd"];
    [parseDescription addBoolSelector:     @selector(setUseSocksProxy:)        forElement:@"use_socks_proxy"];
    
    [parseDescription addStringSelector:   @selector(setHttpServerName:)       forElement:@"http_server_name"];
    [parseDescription addNSIntegerSelector:@selector(setHttpServerPort:)       forElement:@"http_server_port"];
    [parseDescription addStringSelector:   @selector(setHttpUserName:)         forElement:@"http_user_name"];
    [parseDescription addStringSelector:   @selector(setHttpUserPassword:)     forElement:@"http_user_passwd"];
    [parseDescription addBoolSelector:     @selector(setUseHTTPProxy:)         forElement:@"use_http_proxy"];
    [parseDescription addBoolSelector:     @selector(setUseHTTPAuthorization:) forElement:@"use_http_auth"];
    
    return parseDescription;
}



///////////////////////////////////////////////////////////
#pragma mark -
#pragma mark XML Representation

NSString *xmlEscapedString(NSString *string)
{
    NSString *returnString = @"";
    
    if (string)
        returnString = (id)CFXMLCreateStringByEscapingEntities(kCFAllocatorDefault,(CFStringRef)string, NULL);
    
    return returnString;
}


- (NSString *)xmlRepresentation
{
    NSMutableString *xmlString = [NSMutableString string];
    
    [xmlString appendString:@"<set_proxy_settings>\n"];
    [xmlString appendFormat:@"   <socks_version>%d</socks_version>\n", self.socksVersion];
    [xmlString appendFormat:@"   <socks_server_name>%@</socks_server_name>\n", xmlEscapedString(self.socksServerName)];
    [xmlString appendFormat:@"   <socks_server_port>%d</socks_server_port>\n", self.socksServerPort];
    [xmlString appendFormat:@"   <socks5_user_name>%@</socks5_user_name>\n", xmlEscapedString(self.socks5UserName)];
    [xmlString appendFormat:@"   <socks5_user_passwd>%@</socks5_user_passwd>\n", xmlEscapedString(self.socks5UserPassword)];
    if (self.useSocksProxy) 
        [xmlString appendFormat:@"   <use_socks_proxy/>\n"];
    
    [xmlString appendFormat:@"   <http_server_name>%@</http_server_name>\n", xmlEscapedString(self.httpServerName)];
    [xmlString appendFormat:@"   <http_server_port>%d</http_server_port>\n", self.httpServerPort];
    [xmlString appendFormat:@"   <http_user_name>%@</http_user_name>\n", xmlEscapedString(self.httpUserName)];
    [xmlString appendFormat:@"   <http_user_passwd>%@</http_user_passwd>\n", xmlEscapedString(self.httpUserPassword)];
    if (self.useHTTPProxy)
        [xmlString appendFormat:@"   <use_http_proxy/>\n"];
    if (self.httpUserPassword)
        [xmlString appendFormat:@"   <use_http_auth/>\n"];
    
    [xmlString appendString:@"</set_proxy_settings>\n"];
    
    return xmlString;
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
    [theDescription appendFormat:@"%@    useSocksProxy          = %@\n", indentString, self.useSocksProxy ? @"YES" : @"NO"];
    [theDescription appendFormat:@"%@      socksVersion         = %d\n", indentString, self.socksVersion];
    [theDescription appendFormat:@"%@      socksServerName      = %@\n", indentString, self.socksServerName];
    [theDescription appendFormat:@"%@      socksServerPort      = %d\n", indentString, self.socksServerPort];
    [theDescription appendFormat:@"%@      socks5UserName       = %@\n", indentString, self.socks5UserName];
    [theDescription appendFormat:@"%@      socks5UserPassword   = %@\n", indentString, self.socks5UserPassword];
    [theDescription appendFormat:@"%@    useHTTPProxy           = %@\n", indentString, self.useHTTPProxy ? @"YES" : @"NO"];
    [theDescription appendFormat:@"%@      httpServerName       = %@\n", indentString, self.httpServerName];
    [theDescription appendFormat:@"%@      httpServerPort       = %d\n", indentString, self.httpServerPort];
    [theDescription appendFormat:@"%@      httpUserName         = %@\n", indentString, self.httpUserName];
    [theDescription appendFormat:@"%@      httpUserPassword     = %@\n", indentString, self.httpUserPassword];
    [theDescription appendFormat:@"%@      useHTTPAuthorization = %@\n", indentString, self.useHTTPAuthorization ? @"YES" : @"NO"]; 
    
    return theDescription;
}


@end
