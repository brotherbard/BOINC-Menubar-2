//
//  BMBNumberBadge.m
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

#import "BMBNumberBadge.h"


// Private Methods
@interface BMBNumberBadge()

- (NSImage *)badgeForNumber:(NSNumber *)number;
- (NSImage *)badgeForLeftNumber:firstNumber rightNumber:secondNumber;

- (NSAttributedString *)attributedStringForNumber:(NSNumber *)number;
- (NSColor *)defaultColorForBadge;
- (NSColor *)leftColorForBadge;
- (NSColor *)textColorForBadge;

@end


static BMBNumberBadge *_sharedNumberBadgeInstance = nil;

NSString * const kDefaultBadgeColorKey = @"Right Badge Color";
NSString * const kLeftBadgeColorKey    = @"Left Badge Color";
NSString * const kTextBadgeColorKey    = @"Text Badge Color";



#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BMBNumberBadge


#pragma mark Class methods

// Set up factory defaults for preferences
+ (void)initialize 
{
    if (self != [BMBNumberBadge class])
        return;
    
    NSData *rightBadgeColorData = [NSArchiver archivedDataWithRootObject:[NSColor headerColor]];
    NSData *leftBadgeColorData  = [NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedHue:0.3694f 
                                                                                              saturation:0.75f 
                                                                                              brightness:0.75f 
                                                                                                   alpha:1.0f]];
    NSData *textBadgeColorData  = [NSArchiver archivedDataWithRootObject:[NSColor whiteColor]];
    
    NSDictionary *defaults = [NSDictionary dictionaryWithObjectsAndKeys:
                              rightBadgeColorData, kDefaultBadgeColorKey,
                              leftBadgeColorData, kLeftBadgeColorKey,
                              textBadgeColorData, kLeftBadgeColorKey,
                              nil];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults: defaults];
}



#pragma mark -
#pragma mark Public factory methods

+ (NSImage *)badgeWithNumber:(NSInteger)number
{
    if (!_sharedNumberBadgeInstance) 
        _sharedNumberBadgeInstance = [[BMBNumberBadge alloc] init];
    
    return [_sharedNumberBadgeInstance badgeForNumber:[NSNumber numberWithInteger:number]];
}


+ (NSImage *)badgeWithLeftNumber:(NSInteger)leftNumber rightNumber:(NSInteger)rightNumber
{
    if (!_sharedNumberBadgeInstance) 
        _sharedNumberBadgeInstance = [[BMBNumberBadge alloc] init];
    
    NSNumber *left = [NSNumber numberWithInteger:leftNumber];
    NSNumber *right = [NSNumber numberWithInteger:rightNumber];
    
    if (leftNumber == 0)
        return [_sharedNumberBadgeInstance badgeForNumber:right];
    else
        return [_sharedNumberBadgeInstance badgeForLeftNumber:left rightNumber:right];
}



#pragma mark -
#pragma mark Private Methods

- (NSImage *)badgeForNumber:(NSNumber *)number
{
    NSAttributedString *badgeString = [self attributedStringForNumber:number];
    
    double imageHeight = ceil([badgeString size].height);
    double halfHeight = ceil(imageHeight / 2);
    
    double imageWidth = ceil([badgeString size].width) + (halfHeight * 2);
    NSRect badgeRect = NSMakeRect(0.0f, 0.0f, imageWidth, imageHeight);
    
    NSBezierPath *badgePath = [NSBezierPath bezierPathWithRoundedRect:badgeRect xRadius:halfHeight yRadius:halfHeight];
    NSColor *badgeColor = [self defaultColorForBadge];
    
    //=======================================================================================
    NSImage *badgeImage = [[NSImage alloc] initWithSize:badgeRect.size];
    [badgeImage lockFocus];  //  start drawing in image
    
    [badgeColor set];
    [badgePath fill];
    
    [badgeString drawInRect:badgeRect];
    
    [badgeImage unlockFocus];  //  finished drawing in image
    //=======================================================================================
    
    return [badgeImage autorelease];
}


- (NSImage *)badgeForLeftNumber:leftNumber rightNumber:rightNumber
{
    NSAttributedString *leftNumberString = [self attributedStringForNumber:leftNumber];
    NSAttributedString *rightNumberString = [self attributedStringForNumber:rightNumber];
    
    double imageHeight = ceil([leftNumberString size].height / 2.0f) * 2;// try to make this close to even
    double halfHeight  = ceil(imageHeight / 2.0f);
    double sideSpace   = ceil(halfHeight / 2.0f) * 2; // try to make this close to even
    
    double leftStringWidth = ceil([leftNumberString size].width) + sideSpace;
    if (leftStringWidth < imageHeight)
        leftStringWidth = imageHeight;
    
    double rightStringWidth = ceil([rightNumberString size].width) + sideSpace;
    if (rightStringWidth < imageHeight)
        rightStringWidth = imageHeight;
    
    // add 0.5 so the line draws between points to look better with antialiasing
    double dividerLine = ceil(leftStringWidth + (halfHeight / 2.0f)) + 0.5f;
    
    double imageWidth = ceil(leftStringWidth + rightStringWidth + halfHeight + 1.0f);
    
    // the two rects that the number strings will center into
    NSRect leftStringRect  = NSMakeRect(1.0f, 0.0f, dividerLine, imageHeight);
    NSRect rightStringRect = NSMakeRect(dividerLine + 0.5f, 0.0f, imageWidth - dividerLine - 1.5f, imageHeight);
    
    // the right side is drawn first and is a rounded rect
    NSRect badgeRect = NSMakeRect(0.0f, 0.0f, imageWidth, imageHeight);
    NSBezierPath *rightBadgePath = [NSBezierPath bezierPathWithRoundedRect:badgeRect xRadius:halfHeight yRadius:halfHeight];
    
    // the left side is the drawn on top of the above path but is only half the rounded rect
    NSPoint leftArcCenterPoint = NSMakePoint(halfHeight, halfHeight);
    NSBezierPath* leftBadgePath = [NSBezierPath bezierPath];
    [leftBadgePath moveToPoint:NSMakePoint(dividerLine, 0.0f)];
    [leftBadgePath lineToPoint:NSMakePoint(dividerLine, imageHeight)];
    [leftBadgePath lineToPoint:NSMakePoint(halfHeight, imageHeight)];
    [leftBadgePath appendBezierPathWithArcWithCenter:leftArcCenterPoint radius:halfHeight startAngle:90.0f endAngle:270.0f clockwise:NO];
    [leftBadgePath closePath];
    
    NSBezierPath* dividerLinePath = [NSBezierPath bezierPath];
    [dividerLinePath moveToPoint:NSMakePoint(dividerLine, 0.0f)];
    [dividerLinePath lineToPoint:NSMakePoint(dividerLine, imageHeight)];
    
    NSColor *rightBadgeColor = [self defaultColorForBadge];
    NSColor *leftBadgeColor  = [self leftColorForBadge];
    
    //=======================================================================================
    NSImage *badgeImage = [[NSImage alloc] initWithSize:badgeRect.size];
    [badgeImage lockFocus];  //  start drawing in image
    
    [rightBadgeColor set];
    [rightBadgePath fill];
    
    [leftBadgeColor set];
    [leftBadgePath fill];
    
    [[NSColor colorWithCalibratedWhite:0.90f alpha:1.0f] set];
    [dividerLinePath stroke];
    
    [[self textColorForBadge] set];
    [leftNumberString drawInRect:leftStringRect];
    [rightNumberString drawInRect:rightStringRect];
    
    [badgeImage unlockFocus];  //  finished drawing in image
    //=======================================================================================
    
    return [badgeImage autorelease];
}


- (NSAttributedString *)attributedStringForNumber:(NSNumber *)number 
{
    NSMutableParagraphStyle *centerStyle = [[[NSMutableParagraphStyle alloc] init] autorelease];
    [centerStyle setAlignment:NSCenterTextAlignment];
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSFont fontWithName:@"Helvetica-Bold" size:[NSFont systemFontSize] - 2.0f], NSFontAttributeName,
                                      [self textColorForBadge], NSForegroundColorAttributeName, 
                                      centerStyle, NSParagraphStyleAttributeName,
                                      nil];
    
    return [[[NSAttributedString alloc] initWithString:[number stringValue] attributes:attrsDictionary] autorelease];
}


- (NSColor *)defaultColorForBadge
{
    NSColor *badgeColor = [NSColor headerColor];
    NSData *badgeColorData = [[NSUserDefaults standardUserDefaults] dataForKey:kDefaultBadgeColorKey];
    if (badgeColorData != nil)
        badgeColor = (NSColor *)[NSUnarchiver unarchiveObjectWithData:badgeColorData];
    
    return badgeColor;
}


- (NSColor *)leftColorForBadge
{
    NSColor *badgeColor = [NSColor colorWithCalibratedHue:0.3694f saturation:0.75f brightness:0.75f alpha:1.0f];
    NSData *badgeColorData = [[NSUserDefaults standardUserDefaults] dataForKey:kLeftBadgeColorKey];
    if (badgeColorData != nil)
        badgeColor = (NSColor *)[NSUnarchiver unarchiveObjectWithData:badgeColorData];
    
    return badgeColor;
}


- (NSColor *)textColorForBadge
{
    NSColor *badgeColor = [NSColor whiteColor];
    NSData *badgeColorData = [[NSUserDefaults standardUserDefaults] dataForKey:kTextBadgeColorKey];
    if (badgeColorData != nil)
        badgeColor = (NSColor *)[NSUnarchiver unarchiveObjectWithData:badgeColorData];
    
    return badgeColor;
}



@end
