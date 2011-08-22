//
//  BMBAttributeInfoStringCell.h
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

#import <Cocoa/Cocoa.h>


@interface BMBAttributeInfoStringCell : NSCell
{
    NSAttributedString *label;
    double labelWidth;
    NSRect labelRect;
    
    NSAttributedString *value;
    double valueWidth;
    NSRect valueRect;
    
    NSRect frame;
    
    NSDictionary *labelAttributes;
    NSDictionary *valueAttributes;
}
@property (nonatomic, assign) double labelWidth;
@property (nonatomic, assign) double valueWidth;
@property (nonatomic, assign) NSRect frame;

+ (id)cellWithLabel:(NSString *)labelString value:(NSString *)valueString;

- (id)initWithLabel:(NSString *)labelString value:(NSString *)valueString;
- (void)recalculateForMaxLabelWidth:(double)lWidth;

@end



@interface BMBAttributeInfoNumberCell : BMBAttributeInfoStringCell
{
}

+ (id)cellWithLabel:(NSString *)labelString doubleValue:(double)doubleValue;

- (id)initWithLabel:(NSString *)labelString doubleValue:(double)doubleValue;

@end



@interface BMBAttributeInfoCreditCell : BMBAttributeInfoStringCell
{
    NSAttributedString *racLabel;
    double racLabelWidth;
    NSRect racLabelRect;
    
    NSAttributedString *racValue;
    double racValueWidth;
    NSRect racValueRect;
}

+ (id)cellWithCreditLabel:(NSString *)creditLabelString RACLabel:(NSString *)RACLabelString creditValue:(double)credit RACValue:(double)RAC;

- (id)initWithCreditLabel:(NSString *)creditLabelString RACLabel:(NSString *)RACLabelString creditValue:(double)credit RACValue:(double)RAC;
- (void)recalculateForMaxCreditLabelWidth:(double)maxLeftLabelWidth maxCreditValueWidth:(double)maxCreditValueWidth;

@end
