//
//  BOINCCreditMilestone.m
//  BOINCMenubar
//
//  Created by BrotherBard on 5/24/09.
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

#import "BOINCCreditMilestone.h"


@implementation BOINCCreditMilestone


@synthesize currentValue;
@synthesize cachedMilestone;
@dynamic    nextMilestone;
@dynamic    previousMilestone;




+ (NSString *)formattedStringFromMilestone:(double)milestone
{
    static NSNumberFormatter *milestoneFormatter = nil;
    if (milestoneFormatter == nil) {
        milestoneFormatter = [[NSNumberFormatter alloc] init];
        [milestoneFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [milestoneFormatter setRoundingMode:NSNumberFormatterRoundHalfUp];
        [milestoneFormatter setHasThousandSeparators:YES];
        [milestoneFormatter setMaximumFractionDigits:2];
        [milestoneFormatter setMinimumFractionDigits:0];
        [milestoneFormatter setNotANumberSymbol:@"0"];
    }
    
    return [milestoneFormatter stringFromNumber:[NSNumber numberWithDouble:milestone]];
}


+ (BOINCCreditMilestone *)milestoneForValue:(double)value
{
    return [[[BOINCCreditMilestone alloc] initWithValue:value] autorelease];
}


- (id)initWithValue:(double)value
{
    self = [super init];
    if (!self) return nil;
    
    currentValue = value;
    cachedMilestone = self.nextMilestone;
    
    return self;
}



#pragma mark <NSCopying>
- (id)copyWithZone:(NSZone *)zone
{
    BOINCCreditMilestone *copiedMilestone = [[BOINCCreditMilestone allocWithZone:zone] initWithValue:self.currentValue];
    copiedMilestone.cachedMilestone = self.cachedMilestone;
    
    return copiedMilestone;
}



#pragma mark BOINCCreditMilestone methods
- (BOOL)hasPassedMilestoneWithUpdatedValue:(double)newValue
{
    if (newValue == currentValue)
        return NO;
    
    BBLog(@"newValue = %f%@", newValue, [self debugDescription]);
    
    if (newValue < currentValue) {
        BBMark;
        currentValue = newValue;
        cachedMilestone = self.nextMilestone;
        return NO;
    }
    
    currentValue = newValue;
    
    if (currentValue > cachedMilestone) {
        cachedMilestone = self.nextMilestone;
        BBMark;
        return YES;
    }
    
    BBMark;
    return NO;
}


// milestones
//  every   1,000 up to   25,000
//  every   5,000 up to   50,000
//  every  10,000 up to   250,000
//  every  50,000 up to 1,000,000
//  every 100,000 after that

- (double)nextMilestone
{
    if (currentValue > 999999.9)
        return (((long)currentValue / 100000) + 1) * 100000.0;
    
    if (currentValue > 249999.9)
        return (((long)currentValue / 50000) + 1) * 50000.0;
    
    if (currentValue > 49999.9)
        return (((long)currentValue / 10000) + 1) * 10000.0;
    
    if (currentValue > 24999.9)
        return (((long)currentValue / 5000) + 1) * 5000.0;
    
    return (((long)currentValue / 1000) + 1) * 1000.0;
}


- (NSString *)formattedNextMilestone
{
    return [BOINCCreditMilestone formattedStringFromMilestone:self.nextMilestone];
}


- (double)previousMilestone
{
    if (currentValue > 1000000.1)
        return ((long)currentValue / 100000) * 100000.0;
    
    if (currentValue > 250000.1)
        return ((long)currentValue / 50000) * 50000.0;
    
    if (currentValue > 50000.1)
        return ((long)currentValue / 10000) * 10000.0;
    
    if (currentValue > 25000.1)
        return ((long)currentValue / 5000) * 5000.0;
    
    return ((long)currentValue / 1000) * 1000.0;
}


- (NSString *)formattedPreviousMilestone
{
    return [BOINCCreditMilestone formattedStringFromMilestone:self.previousMilestone];
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
    [theDescription appendFormat:@"%@    currentValue      = %@\n", indentString, [BOINCCreditMilestone formattedStringFromMilestone:currentValue]];
    [theDescription appendFormat:@"%@    nextMilestone     = %@\n", indentString, self.formattedNextMilestone];
    [theDescription appendFormat:@"%@    previousMilestone = %@\n", indentString, self.formattedPreviousMilestone];
    [theDescription appendFormat:@"%@    cachedMilestone   = %@\n", indentString, [BOINCCreditMilestone formattedStringFromMilestone:cachedMilestone]];
    
    return theDescription;
}


@end
