//
//  BMBNumbersOnlyFormatter.m
//  BOINCMenubar
//
//  Created by BrotherBard on 12/23/08.
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

#import "BMBNumbersOnlyFormatter.h"



//////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BMBNumbersOnlyFormatter


- (void)dealloc
{
    [validCharacters release];
    
    [super dealloc];
}


- (void)awakeFromNib
{
    NSMutableCharacterSet *charSet = [[NSCharacterSet decimalDigitCharacterSet] mutableCopy];    
    [charSet addCharactersInString:[NSString stringWithFormat:@"%@%@", [self groupingSeparator], [self decimalSeparator]]];
    
    validCharacters = [charSet copy];
    [charSet release];
}


- (BOOL)isPartialStringValid:(NSString **)partialStringPtr 
       proposedSelectedRange:(NSRangePointer)proposedSelRangePtr 
              originalString:(NSString *)origString 
       originalSelectedRange:(NSRange)origSelRange 
            errorDescription:(NSString **)error
{
    // the user may have:
    // -- deleted the left most character
    // -- deleted the last character and we have an empty string
    // in both cases location == 0 and both are valid
    if (proposedSelRangePtr->location == 0)
        return YES;
    
    unichar theChar = [*partialStringPtr characterAtIndex:proposedSelRangePtr->location - 1];
    
    // only allow numbers or numeric seperators ("," ".") 
    // Note that this does not validate the number (there may be too many "." or in the wrong places)
    if (![validCharacters characterIsMember:theChar]) {
        *error = nil;
        NSBeep();
        return NO;
    }
    
    return YES;
}


@end
