//
//  BOINCAccountManager.m
//  BOINCMenubar
//
//  Created by BrotherBard on 4/25/09.
//  Copyright 2009 BrotherBard. All rights reserved.
//

#import "BOINCAccountManager.h"


@implementation BOINCAccountManager

@synthesize name;
@synthesize url;
@synthesize hasCredentials;



- (void)dealloc
{
    [name release];
    [url  release];
    
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
    [parseDescription addStringSelector:@selector(setName:)           forElement:@"acct_mgr_name"];
    [parseDescription addStringSelector:@selector(setUrl:)            forElement:@"acct_mgr_url"];
    [parseDescription addBoolSelector:  @selector(setHasCredentials:) forElement:@"have_credentials"];
    
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
    [theDescription appendFormat:@"%@    name           = %@\n", indentString, self.name];
    [theDescription appendFormat:@"%@    URL            = %@\n", indentString, self.url];
    [theDescription appendFormat:@"%@    hasCredentials = %@\n", indentString, self.hasCredentials ? @"YES" : @"NO"];    
    
    return theDescription;
}





@end
