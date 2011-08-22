//
//  BMBClientSortDescriptors.m
//  BOINCMenubar
//
//  Created by BrotherBard on 7/5/09.
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

#import "BMBClientSortDescriptors.h"


@interface BMBClientSortDescriptors()

- (NSArray *)updateSortDescriptors;

@end



@implementation BMBClientSortDescriptors

@synthesize clientSortDescriptors;

static BMBClientSortDescriptors *sharedClientSortDescriptors = nil;

+ (BMBClientSortDescriptors *)sharedClientSortDescriptors
{
    if (sharedClientSortDescriptors == nil)
        sharedClientSortDescriptors = [[self alloc] init];
    
    return sharedClientSortDescriptors;
}



static const void *clientSortDescriptorsContext;

- (id)init
{
    self = [super init];
    if(!self) return nil;
    
    [[NSUserDefaults standardUserDefaults] addObserver:self 
                                            forKeyPath:kClientSortReversedKey 
                                               options:0 
                                               context:&clientSortDescriptorsContext];
    [[NSUserDefaults standardUserDefaults] addObserver:self 
                                            forKeyPath:kClientSortPropertyKey 
                                               options:0 
                                               context:&clientSortDescriptorsContext];
    
    clientSortDescriptors = [[self updateSortDescriptors] retain];
    
    return self;
}


- (void)dealloc
{
    [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:kClientSortReversedKey];
    [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:kClientSortPropertyKey];
    
    [clientSortDescriptors release];
	clientSortDescriptors = nil;
    
    [super dealloc];
}



#pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == &clientSortDescriptorsContext) {
        // the user changed the sort property or reversed the sort order
        self.clientSortDescriptors = [self updateSortDescriptors];
        return;
    }
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}



#pragma mark Private methods

- (NSArray *)updateSortDescriptors
{
    int  clientSortProperty = [[[NSUserDefaults standardUserDefaults] objectForKey:kClientSortPropertyKey] intValue];
    BOOL clientSortReversed = [[NSUserDefaults standardUserDefaults] boolForKey:  kClientSortReversedKey];
    
    // by default:
    //   strings & dates should sort small to large (ex: a-z, first joined to recently joined)
    //   numbers from large to small (ex: largest credit to smallest credit)
    BOOL isAscending = NO;
    if ((clientSortProperty == kClientNameTag) || (clientSortProperty == kDateModifiedTag))
        isAscending = YES;
	
    // the sort order might be reversed
	if (clientSortReversed)
		isAscending = !isAscending;
    
    if (clientSortProperty == kClientNameTag) 
        return [NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"clientName" ascending:isAscending selector:@selector(localizedCaseInsensitiveCompare:)] autorelease]];
    
    if (clientSortProperty == kHostAddressTag)
        return [NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"hostAddress" ascending:isAscending] autorelease]];
    
    if (clientSortProperty == kDateModifiedTag)
        return [NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"modifiedDate" ascending:isAscending] autorelease]];
    
    //if (clientSortProperty == kConnectionStatusTag)
    return [NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"connectionStatus" ascending:isAscending] autorelease]];
}

@end
