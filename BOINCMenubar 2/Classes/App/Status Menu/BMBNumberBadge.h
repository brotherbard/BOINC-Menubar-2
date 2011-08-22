//
//  BMBNumberBadge.h
//  BOINCMenubar
//
//  Created by BrotherBard on 8/3/08.
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

#import <Cocoa/Cocoa.h>

////////////////////////////////////////
// BMBNumberBadge
//
//  the badges are a colored rounded rectangle with one or two numbers in the middle
//  used in the menu to indicate the number of active and total tasks currently running for the project
//

@interface BMBNumberBadge : NSObject 
{
}


// badgeWithNumber:
//  creates a badge icon, a colored rounded rectangle with a number in it
//  the badge expands to fit the size of the number
//
+ (NSImage *)badgeWithNumber:(NSInteger)number;


// badgeWithLeftNumber:rightNumber:
//  creates a badge icon, a colored rounded rectangle with two numbers in it
//  the badge expands to fit the size of the numbers
//  the background is a different color on each side and there is a white line down the middle
//  defaults to the single number badge if the left number is 0
//
+ (NSImage *)badgeWithLeftNumber:(NSInteger)leftNumber rightNumber:(NSInteger)rightNumber;

@end
