//
//  BOINCAccountManagerSummary.m
//  BOINCMenubar
//
//  Created by BrotherBard on 4/25/09.
//  Copyright 2009 BrotherBard. All rights reserved.
//

#import "BOINCAccountManagerSummary.h"
#import "BOINCAccountManager.h"


@implementation BOINCAccountManagerSummary

@synthesize managerName;
@synthesize managerURL;
@synthesize managerDescription;
@synthesize managerImageURL;

@synthesize isAttached;

@synthesize htmlDescription;
@synthesize sortID;



+ (NSString *)accountManagerDescriptionHTMLString
{
    static NSString *accountManagerDescriptionHTML = nil;
    
    if (!accountManagerDescriptionHTML) 
        accountManagerDescriptionHTML = [[NSString stringWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"AccountManagerDescription" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil] retain];
    
    return accountManagerDescriptionHTML;
}


+ (NSString *)accountManagerWithoutDescriptionHTMLString
{
    static NSString *accountManagerWithoutDescriptionHTML = nil;
    
    if (!accountManagerWithoutDescriptionHTML) 
        accountManagerWithoutDescriptionHTML = [[NSString stringWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"AccountManagerWithoutDescription" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil] retain];
    
    return accountManagerWithoutDescriptionHTML;
}



- (id)initWithManager:(BOINCAccountManager *)existingManager
{
    self = [super init];
    if (!self) return nil;
    
    isAttached = YES;
    managerName       = [existingManager.name copy];
    managerURL        = [existingManager.url  copy];
    
    return self;
}
    

- (void)dealloc
{
    [managerName        release];
    [managerURL         release];
    [managerDescription release];
    [managerImageURL    release];
    [htmlDescription    release];
    
    [super dealloc];
}


- (NSString *)htmlDescription
{
    if (htmlDescription)
        return htmlDescription;
    
    NSMutableString *tempString = nil;
    
    if (managerDescription) 
        tempString = [[BOINCAccountManagerSummary accountManagerDescriptionHTMLString] mutableCopy];
    else 
        tempString = [[BOINCAccountManagerSummary accountManagerWithoutDescriptionHTMLString] mutableCopy];
    
    [tempString replaceOccurrencesOfString:@"FontSize" 
                                withString:[[NSNumber numberWithDouble:[NSFont systemFontSize] - 1] stringValue] 
                                   options:0 
                                     range:NSMakeRange(0, [tempString length])];
    
    [tempString replaceOccurrencesOfString:@"FontFamilyName" 
                                withString:[[NSFont systemFontOfSize:0] familyName] 
                                   options:0 
                                     range:NSMakeRange(0, [tempString length])];
    
    if (managerURL)
        [tempString replaceOccurrencesOfString:@"<ManagerURL/>" 
                                    withString:managerURL 
                                       options:0 
                                         range:NSMakeRange(0, [tempString length])];
    
    if (managerImageURL)
        [tempString replaceOccurrencesOfString:@"<ManagerImageURL/>" 
                                    withString:[NSString stringWithFormat:@"<a href='%@'><img src='%@'></a>", managerURL, managerImageURL] 
                                       options:0 
                                         range:NSMakeRange(0, [tempString length])];
    
    if (managerName)
        [tempString replaceOccurrencesOfString:@"<ManagerName/>" 
                                    withString:managerName 
                                       options:0 
                                         range:NSMakeRange(0, [tempString length])];
    
    if (managerDescription)
        [tempString replaceOccurrencesOfString:@"<ManagerDescription/>" 
                                    withString:managerDescription 
                                       options:0 
                                         range:NSMakeRange(0, [tempString length])];
    
    self.htmlDescription = tempString;
    [tempString release];
    return htmlDescription;
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
    [parseDescription addStringSelector:   @selector(setManagerName:)        forElement:@"name"];
    [parseDescription addStringSelector:   @selector(setManagerURL:)         forElement:@"url"];
    [parseDescription addStringSelector:   @selector(setManagerImageURL:)    forElement:@"image"];
    [parseDescription addXMLStringSelector:@selector(setManagerDescription:) forElement:@"description"];
    
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
    [theDescription appendFormat:@"%@    name        = %@\n", indentString, self.managerName];
    [theDescription appendFormat:@"%@    isAttached  = %@\n", indentString, self.isAttached ? @"YES" : @"NO"];
    [theDescription appendFormat:@"%@    URL         = %@\n", indentString, self.managerURL];
    [theDescription appendFormat:@"%@    imageURL    = %@\n", indentString, self.managerImageURL];
    [theDescription appendFormat:@"%@    description = %@\n", indentString, self.managerDescription];
    
    return theDescription;
}




@end
