//
//  BMBAttributeInfoStringCell.m
//  BOINCMenubar
//
//  Created by BrotherBard on 2/22/09.
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

#import "BMBAttributeInfoStringCell.h"


@implementation BMBAttributeInfoStringCell


@synthesize labelWidth;
@synthesize valueWidth;
@synthesize frame;


+ (NSDictionary *)labelAttributes
{
    static NSDictionary * labelAttributes = nil;
    if (labelAttributes == nil)
        labelAttributes =[[NSDictionary alloc] initWithObjectsAndKeys:
                          [NSFont menuFontOfSize:[NSFont systemFontSize]-1], NSFontAttributeName,
                          [NSColor colorWithCalibratedWhite:0.4f alpha:1.0f], NSForegroundColorAttributeName, 
                          nil];
    return labelAttributes;
}


+ (NSDictionary *)valueAttributes
{
    static NSDictionary * valueAttributes = nil;
    if (valueAttributes == nil)
        valueAttributes =[[NSDictionary alloc] initWithObjectsAndKeys:
                          [NSFont menuFontOfSize:[NSFont systemFontSize]-1], NSFontAttributeName,
                          [NSColor blackColor], NSForegroundColorAttributeName, 
                          nil];
    return valueAttributes;
}


+ (id)cellWithLabel:(NSString *)labelString value:(NSString *)valueString
{
    return [[[self alloc] initWithLabel:labelString value:valueString] autorelease];
}


- (id)initWithLabel:(NSString *)labelString value:(NSString *)valueString
{
    self = [super initTextCell:@""];
    if (self == nil)
        return nil;
    
    if (labelString == nil)
        labelString = @"";
    if (valueString == nil)
        valueString = @"--";
    
    label = [[NSAttributedString alloc] initWithString:labelString 
                                            attributes:[BMBAttributeInfoStringCell labelAttributes]];
    
    if ([valueString isEqualToString:@"--"])
        value = [[NSAttributedString alloc] initWithString:valueString 
                                                attributes:[BMBAttributeInfoStringCell labelAttributes]];
    else
        value = [[NSAttributedString alloc] initWithString:valueString 
                                                attributes:[BMBAttributeInfoStringCell valueAttributes]];
    
    labelWidth = label.size.width;
    valueWidth = value.size.width;
    
    return self;
}


- (void) dealloc
{
    [label release];
    [value release];
    
    [super dealloc];
}


- (void)recalculateForMaxLabelWidth:(double)maxLabelWidth
{
    double location = maxLabelWidth;
    labelRect = NSMakeRect(location - labelWidth, 0, labelWidth, label.size.height);
    location += 6.0f;
    valueRect = NSMakeRect(location, 0, valueWidth, value.size.height);
}


- (NSSize)cellSize
{
    return NSMakeSize(valueRect.origin.x + valueWidth, valueRect.size.height);
}


- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{    
    [label drawInRect:NSOffsetRect(labelRect, cellFrame.origin.x, cellFrame.origin.y)];
    [value drawInRect:NSOffsetRect(valueRect, cellFrame.origin.x, cellFrame.origin.y)];
}

@end



@implementation BMBAttributeInfoNumberCell


+ (NSString *)formattedDoubleValue:(double)doubleValue
{
    static NSNumberFormatter *formatter = nil;
    if (formatter == nil) {
        formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setMaximumFractionDigits:0];
        [formatter setRoundingMode:NSNumberFormatterRoundHalfUp];
    }
    return [formatter stringFromNumber:[NSNumber numberWithDouble:doubleValue]];
}


+ (id)cellWithLabel:(NSString *)labelString doubleValue:(double)doubleValue
{
    return [[[self alloc] initWithLabel:labelString doubleValue:doubleValue] autorelease];
}


- (id)initWithLabel:(NSString *)labelString doubleValue:(double)doubleValue
{
    self = [super initWithLabel:labelString value:[BMBAttributeInfoNumberCell formattedDoubleValue:doubleValue]];
    if (self == nil)
        return nil;
    
    return self;
}


- (void) dealloc
{
    [super dealloc];
}


@end



@implementation BMBAttributeInfoCreditCell


+ (NSString *)formattedCreditNumber:(double)credit
{
    static NSNumberFormatter *creditNumberFormatter = nil;
    if (creditNumberFormatter == nil) {
        // the credit number format with no decimal places (whole numbers only)
        creditNumberFormatter = [[NSNumberFormatter alloc] init];
        [creditNumberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [creditNumberFormatter setMaximumFractionDigits:0];
        [creditNumberFormatter setRoundingMode:NSNumberFormatterRoundHalfUp];
    }
    return [creditNumberFormatter stringFromNumber:[NSNumber numberWithDouble:credit]];
}


+ (NSString *)formattedRACNumber:(double)rac
{
    static NSNumberFormatter *RACNumberFormatter = nil;
    if (RACNumberFormatter == nil) {
        // the RAC will show zero to two places after the decimal
        RACNumberFormatter = [[NSNumberFormatter alloc] init];
        [RACNumberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [RACNumberFormatter setMaximumFractionDigits:2];
        [RACNumberFormatter setMinimumFractionDigits:0]; 
        [RACNumberFormatter setRoundingMode:NSNumberFormatterRoundHalfUp];
    }
    return [RACNumberFormatter stringFromNumber:[NSNumber numberWithDouble:rac]];
}


+ (id)cellWithCreditLabel:(NSString *)creditLabelString RACLabel:(NSString *)RACLabelString creditValue:(double)credit RACValue:(double)RAC
{
    return [[[self alloc] initWithCreditLabel:creditLabelString 
                                     RACLabel:RACLabelString 
                                  creditValue:credit 
                                     RACValue:RAC] autorelease];
}


- (id)initWithCreditLabel:(NSString *)creditLabelString RACLabel:(NSString *)RACLabelString creditValue:(double)credit RACValue:(double)RAC
{
    self = [super initWithLabel:creditLabelString value:[BMBAttributeInfoCreditCell formattedCreditNumber:credit]];
    if (self == nil)
        return nil;
    
    if (RACLabelString == nil)
        RACLabelString = @"";
    
    racLabel = [[NSAttributedString alloc] initWithString:RACLabelString 
                                               attributes:[BMBAttributeInfoStringCell labelAttributes]];
    racLabelWidth = racLabel.size.width;
    
    racValue = [[NSAttributedString alloc] initWithString:[BMBAttributeInfoCreditCell formattedRACNumber:RAC]
                                               attributes:[BMBAttributeInfoStringCell valueAttributes]];
    racValueWidth = racValue.size.width;
    
    return self;
}


- (void) dealloc
{
    [racValue release];
    [racLabel release];
    
    [super dealloc];
}



- (void)recalculateForMaxCreditLabelWidth:(double)maxLeftLabelWidth maxCreditValueWidth:(double)maxCreditValueWidth
{
    double location = maxLeftLabelWidth;
    labelRect = NSMakeRect(location - labelWidth, 0, labelWidth, label.size.height);
    location += 6.0f;
    valueRect = NSMakeRect(location, 0, valueWidth, value.size.height);
    
    location += maxCreditValueWidth + 10.0f + racLabelWidth;
    racLabelRect = NSMakeRect(location - racLabelWidth, 0, racLabelWidth, racLabel.size.height);
    location += 6.0f;
    racValueRect = NSMakeRect(location, 0, racValueWidth, value.size.height);
}


- (NSSize)cellSize
{
    return NSMakeSize(racValueRect.origin.x + racValueWidth, racValueRect.size.height);
}


- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{    
    [label    drawInRect:NSOffsetRect(labelRect,    cellFrame.origin.x, cellFrame.origin.y)];
    [value    drawInRect:NSOffsetRect(valueRect,    cellFrame.origin.x, cellFrame.origin.y)];
    [racLabel drawInRect:NSOffsetRect(racLabelRect, cellFrame.origin.x, cellFrame.origin.y)];
    [racValue drawInRect:NSOffsetRect(racValueRect, cellFrame.origin.x, cellFrame.origin.y)];
}


@end

