//
//  BMBAttributeInfoView.m
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

#import "BMBAttributeInfoView.h"
#import "BMBAttributeInfoStringCell.h"


#define kBMBAttributeLeftGutter   17
#define kBMBAttributeRightGutter  28
#define kBMBAttributeBottomGutter 2
#define kBMBAttributeIndent       17
#define kBMBAttributeRowHeight    17



@implementation BMBAttributeInfoView


@synthesize indentLevel;
@synthesize maxCreditValueWidth;



- (void) dealloc
{
    [cells release];
    
    [super dealloc];
}


// the attributesCells array must be in display order
- (void)setAttributeCells:(NSArray *)attributeCells
{
    [cells release];
    cells = [attributeCells retain];
    
    // find the widest label and credit value string widths (for use in lining up columns)
    for (BMBAttributeInfoStringCell *cell in cells) {
        maxLeftLabelWidth = fmax(maxLeftLabelWidth, cell.labelWidth);
        if ([cell isKindOfClass:[BMBAttributeInfoCreditCell class]])
            maxCreditValueWidth = fmax(maxCreditValueWidth, cell.valueWidth);
    }
}


- (void)calculateCellFrames
{
    // use the max widths to line up the different columns within the cells and find the widest cell width
    double maxCellWidth = 0.0f;
    for (BMBAttributeInfoStringCell *cell in cells) {
        if ([cell isKindOfClass:[BMBAttributeInfoCreditCell class]])
            [(BMBAttributeInfoCreditCell *)cell recalculateForMaxCreditLabelWidth:maxLeftLabelWidth maxCreditValueWidth:maxCreditValueWidth];
        else
            [cell recalculateForMaxLabelWidth:maxLeftLabelWidth];
        maxCellWidth = fmax(maxCellWidth, [cell cellSize].width);
    }
    
    // based on the widest cell, set the size of the view
    double viewHeight = 0.0f;
    if ([cells count] != 0)
        viewHeight = ([cells count] * kBMBAttributeRowHeight) + kBMBAttributeBottomGutter;
    double leftGutter = kBMBAttributeLeftGutter + (indentLevel * kBMBAttributeIndent);
    NSRect viewFrame = [self frame];
    viewFrame.size.width = leftGutter + maxCellWidth + kBMBAttributeRightGutter;
    viewFrame.size.height = viewHeight;
    [self setFrame:viewFrame];
    
    // precalculate frames for each attribute cell 
    NSRect cellFrame = NSMakeRect(leftGutter, viewHeight, maxCellWidth, kBMBAttributeRowHeight);
    for (BMBAttributeInfoStringCell *cell in cells) {
        cellFrame.origin.y -= kBMBAttributeRowHeight;
        cell.frame = cellFrame;
    }  
}


- (void)drawRect:(NSRect)rect
{
    for (BMBAttributeInfoStringCell *cell in cells)
        [cell drawWithFrame:cell.frame inView:self];
}



@end
