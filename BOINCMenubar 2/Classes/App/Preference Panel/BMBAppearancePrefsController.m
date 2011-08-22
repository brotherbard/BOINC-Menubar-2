//
//  BMBAppearancePrefsController.m
//  BOINCMenubar
//
//  Created by BrotherBard on 2/14/09.
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

#import "BMBAppearancePrefsController.h"
#import "BMBProjectMenuController.h"
#import "BMBStatusMenuController.h"


// this is for drag-n-drop, just needs to be something unique
#define kBMBAppearancePrivateTableViewDataType @"BMBAppearancePrefsController Private TableView Drag Data Type"

#define kBMBAppearanceTabViewIndexKey @"Appearance Preference TabView Index"



// Private
@interface BMBAppearancePrefsController()

- (void)reorderAttributes:(NSMutableDictionary *)attributes toArray:(NSMutableArray *)array;
- (void)updateAttributeKeys:(NSMutableArray *)orderedAttributeKeys withAttributes:(NSMutableDictionary *)attributes;

@end



#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BMBAppearancePrefsController


@synthesize appearanceTab;
@synthesize projectTable;
@synthesize accountTable;


+ (void)initialize
{
    if (self != [BMBAppearancePrefsController class])
        return;
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObject:@"1" forKey:kBMBAppearanceTabViewIndexKey]];
}


- (id)init
{
    self = [super initWithNibName:@"BMBAppearancePreferences" bundle:nil];
    if (!self) return nil;
    
    titles = [[NSDictionary alloc] initWithObjectsAndKeys:
              NSLocalizedString(@"Account Name", @""),            kMenuAccountName,
              NSLocalizedString(@"Total Credit and RAC", @""),    kMenuTotalCredit,
              NSLocalizedString(@"Host Credit and RAC", @""),     kMenuHostCredit,
              NSLocalizedString(@"Team Name", @""),               kMenuTeamName,
              NSLocalizedString(@"Resource Share", @""),          kMenuResourceShare,
              NSLocalizedString(@"Host Venue", @""),              kMenuHostVenue,
              NSLocalizedString(@"Total and Running Tasks", @""), kMenuTaskCount,
              NSLocalizedString(@"Tasks to Report", @""),         kMenuTasksToReport,
              NSLocalizedString(@"Total Time Estimate", @""),     kMenuTimeEstimate,
              nil];
    
    // the attributes in the main menu
    projectOrderedAttributeKeys = [[NSMutableArray alloc] initWithCapacity:[titles count]];
    projectAttributes      = [[[NSUserDefaults standardUserDefaults] objectForKey:kProjectMenuAttributes] mutableCopy];
    [self updateAttributeKeys:projectOrderedAttributeKeys withAttributes:projectAttributes];
    
    // the attributes in the submenu
    accountOrderedAttributeKeys = [[NSMutableArray alloc] initWithCapacity:[titles count]];
    accountAttributes  = [[[NSUserDefaults standardUserDefaults] objectForKey:kAccountMenuAttributes] mutableCopy];
    [self updateAttributeKeys:accountOrderedAttributeKeys withAttributes:accountAttributes];
    
    return self;
}


- (void) dealloc
{
    [appearanceTab          release];
    [projectTable           release];
    [accountTable           release];
    
    [projectOrderedAttributeKeys release];
    [projectAttributes      release];
    [accountOrderedAttributeKeys release];
    [accountAttributes      release];
    [titles                 release];
    
    [super dealloc];
}



#pragma mark BMB_ViewController_Category methods

- (void)BMB_contentViewWillLoad
{
    
}


- (void)BMB_contentViewDidUnload
{
    
}



#pragma mark Public methods

- (void)awakeFromNib
{
    [projectTable registerForDraggedTypes:[NSArray arrayWithObject:kBMBAppearancePrivateTableViewDataType]];
    [accountTable registerForDraggedTypes:[NSArray arrayWithObject:kBMBAppearancePrivateTableViewDataType]];
    
    [appearanceTab selectTabViewItemWithIdentifier:[[NSUserDefaults standardUserDefaults] stringForKey:kBMBAppearanceTabViewIndexKey]];
}



#pragma mark NSTabView delegate methods

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
    [[NSUserDefaults standardUserDefaults] setObject:[tabViewItem identifier] forKey:kBMBAppearanceTabViewIndexKey];
}



#pragma mark TableView Delegate Methods

//- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
//{
// maybe show an example of the output???
// or a description of the attribute
//}



#pragma mark TableView DataSource Methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)table
{
    if (table == projectTable)
        return [projectOrderedAttributeKeys count];
    
    return [accountOrderedAttributeKeys count];
}


- (id)tableView:(NSTableView *)table objectValueForTableColumn:(NSTableColumn *)column row:(NSInteger)rowIndex
{
    if (table == projectTable) {
        if ([[column identifier] isEqualToString:@"Title"])
            return [titles objectForKey:[projectOrderedAttributeKeys objectAtIndex:rowIndex]];
        return [[projectAttributes objectForKey:[projectOrderedAttributeKeys objectAtIndex:rowIndex]] objectForKey:kAttributeIsVisible];
    }
    
    if (table == accountTable) {
        if ([[column identifier] isEqualToString:@"Title"])
            return [titles objectForKey:[accountOrderedAttributeKeys objectAtIndex:rowIndex]];
        return [[accountAttributes objectForKey:[accountOrderedAttributeKeys objectAtIndex:rowIndex]] objectForKey:kAttributeIsVisible];
    }
    
    return nil;
}



#pragma mark NSTableView Drag and Drop Delegate Methods

- (BOOL)tableView:(NSTableView *)table writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard
{
    // copy the row number to the pasteboard with a custom data type
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
    [pboard declareTypes:[NSArray arrayWithObject:kBMBAppearancePrivateTableViewDataType] owner:self];
    [pboard setData:data forType:kBMBAppearancePrivateTableViewDataType];
    return YES;
}


- (NSDragOperation)tableView:(NSTableView*)table validateDrop:(id <NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation
{
    // only allow dropping between items, not on items
    [table setDropRow:row dropOperation:NSTableViewDropAbove];
    return NSDragOperationMove;
}


- (BOOL)tableView:(NSTableView *)table acceptDrop:(id <NSDraggingInfo>)info row:(NSInteger)newRow dropOperation:(NSTableViewDropOperation)operation
{
    // copy the row number (of the item's original position) from the pasteboard
    NSPasteboard* pboard = [info draggingPasteboard];
    NSData* rowData = [pboard dataForType:kBMBAppearancePrivateTableViewDataType];
    NSIndexSet* rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];
    NSInteger initialRow = [rowIndexes firstIndex];
    if (initialRow < newRow)
        --newRow;
    
    // there are two tables, one for the Project tab and one for the Project Submenu tab (called account here)
    NSMutableArray *information;
    NSMutableDictionary *attributes;
    NSString *key;
    if (table == projectTable) {
        information = projectOrderedAttributeKeys;
        attributes = projectAttributes;
        key = kProjectMenuAttributes;
    } 
    else if (table == accountTable) {
        information = accountOrderedAttributeKeys;
        attributes = accountAttributes;
        key = kAccountMenuAttributes;
    } else
        return NO;
    
    // Move the specified row to its new location...
    NSString *object = [information objectAtIndex:initialRow];
    if (object) {
        [information removeObjectAtIndex:initialRow];
        [information insertObject:object atIndex:newRow];
    }
    
    [self reorderAttributes:attributes toArray:information];
    
    [[NSUserDefaults standardUserDefaults] setObject:attributes forKey:key];
    [table reloadData];
    
    return YES;
}



#pragma mark IBActions

// the two toggle... actions are sent by a single click in the checkmark or by a double click anywhere in the tableview
- (IBAction)toggleProjectAttributeVisibility:(id)sender
{
    if ([projectTable selectedRow] == -1)
        return;
    
    NSString *key = [projectOrderedAttributeKeys objectAtIndex:[projectTable selectedRow]];
    
    // use mutableCopy because original NSUserDefaults dictionary is inmutable
    NSMutableDictionary *attribute = [[projectAttributes objectForKey:key] mutableCopy];
    if (attribute == nil)
        return;
    
    BOOL isVisible = [[attribute objectForKey:kAttributeIsVisible] boolValue];
    [attribute setObject:(isVisible ? [NSNumber numberWithBool:NO] : [NSNumber numberWithBool:YES])
                  forKey:kAttributeIsVisible];
    
    [projectAttributes setObject:attribute forKey:key];
    [attribute release];
    
    [[NSUserDefaults standardUserDefaults] setObject:projectAttributes forKey:kProjectMenuAttributes];
    
    [projectTable reloadData];
}


- (IBAction)toggleAccountAttributeVisibility:(id)sender
{
    if ([accountTable selectedRow] == -1)
        return;
    
    NSString *key = [accountOrderedAttributeKeys objectAtIndex:[accountTable selectedRow]];
    
    // use mutableCopy because original NSUserDefaults dictionary is inmutable
    NSMutableDictionary *attribute = [[accountAttributes objectForKey:key] mutableCopy];
    if (attribute == nil)
        return;
    
    BOOL isVisible = [[attribute objectForKey:kAttributeIsVisible] boolValue];
    [attribute setObject:(isVisible ? [NSNumber numberWithBool:NO] : [NSNumber numberWithBool:YES])
                  forKey:kAttributeIsVisible];
    
    [accountAttributes setObject:attribute forKey:key];
    [attribute release];
    
    [[NSUserDefaults standardUserDefaults] setObject:accountAttributes forKey:kAccountMenuAttributes];
    
    [accountTable reloadData];
}


// the four move... actions are sent by the up/down arrows below each of the two attribute configuration tables
- (IBAction)moveProjectAttributeUp:(id)sender
{
    if ([projectTable selectedRow] == 0)
        return;
    
    [projectOrderedAttributeKeys exchangeObjectAtIndex:([projectTable selectedRow] - 1) withObjectAtIndex:[projectTable selectedRow]];
    [self reorderAttributes:projectAttributes toArray:projectOrderedAttributeKeys];
    
    [projectTable selectRowIndexes:[NSIndexSet indexSetWithIndex:([projectTable selectedRow] - 1)] byExtendingSelection:NO];
    
    [[NSUserDefaults standardUserDefaults] setObject:projectAttributes forKey:kProjectMenuAttributes];
    [projectTable reloadData];
}


- (IBAction)moveProjectAttributeDown:(id)sender
{
    if ((NSUInteger)[projectTable selectedRow] > ([projectOrderedAttributeKeys count] - 2))
        return;
    
    [projectOrderedAttributeKeys exchangeObjectAtIndex:([projectTable selectedRow] + 1) withObjectAtIndex:[projectTable selectedRow]];
    [self reorderAttributes:projectAttributes toArray:projectOrderedAttributeKeys];
    
    [projectTable selectRowIndexes:[NSIndexSet indexSetWithIndex:([projectTable selectedRow] + 1)] byExtendingSelection:NO];
    
    [[NSUserDefaults standardUserDefaults] setObject:projectAttributes forKey:kProjectMenuAttributes];
    [projectTable reloadData];
}


- (IBAction)moveAccountAttributeUp:(id)sender
{
    if ([accountTable selectedRow] == 0)
        return;
    
    [accountOrderedAttributeKeys exchangeObjectAtIndex:([accountTable selectedRow] - 1) withObjectAtIndex:[accountTable selectedRow]];
    [self reorderAttributes:accountAttributes toArray:accountOrderedAttributeKeys];
    
    [accountTable selectRowIndexes:[NSIndexSet indexSetWithIndex:([accountTable selectedRow] - 1)] byExtendingSelection:NO];
    
    [[NSUserDefaults standardUserDefaults] setObject:accountAttributes forKey:kAccountMenuAttributes];
    [accountTable reloadData];
}


- (IBAction)moveAccountAttributeDown:(id)sender
{
    if ((NSUInteger)[accountTable selectedRow] > ([accountOrderedAttributeKeys count] - 2))
        return;
    
    [accountOrderedAttributeKeys exchangeObjectAtIndex:([accountTable selectedRow] + 1) withObjectAtIndex:[accountTable selectedRow]];
    [self reorderAttributes:accountAttributes toArray:accountOrderedAttributeKeys];
    
    [accountTable selectRowIndexes:[NSIndexSet indexSetWithIndex:([accountTable selectedRow] + 1)] byExtendingSelection:NO];
    
    [[NSUserDefaults standardUserDefaults] setObject:accountAttributes forKey:kAccountMenuAttributes];
    [accountTable reloadData];
}



#pragma mark Private Methods

- (void)reorderAttributes:(NSMutableDictionary *)attributes toArray:(NSMutableArray *)array
{
    NSInteger position = 0;
    for (NSString *key in array) {
        // use mutableCopy because original NSUserDefaults dictionary is inmutable
        NSMutableDictionary *attribute = [[attributes objectForKey:key] mutableCopy];
        if (attribute == nil)
            continue;
        [attribute setObject:[NSNumber numberWithInteger:position++] forKey:kAttributePosition];
        [attributes setObject:attribute forKey:key];
        [attribute release];
    }
}


- (void)updateAttributeKeys:(NSMutableArray *)orderedAttributeKeys withAttributes:(NSMutableDictionary *)attributes
{
    for (NSString *string in titles)
        [orderedAttributeKeys addObject:[NSNull null]];
    
    for (NSString *key in titles) {
        NSDictionary *attribute = [attributes objectForKey:key];
        if (attribute) {
            NSUInteger position = [[attribute objectForKey:kAttributePosition] intValue];
            if ((position < [orderedAttributeKeys count] ) && ([orderedAttributeKeys objectAtIndex:position] == [NSNull null]))
                [orderedAttributeKeys replaceObjectAtIndex:position
                                           withObject:key];
            else
                [orderedAttributeKeys addObject:key];
        } else {
            [orderedAttributeKeys addObject:key];
            NSDictionary *attributeDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                                 [NSNumber numberWithBool:NO], kAttributeIsVisible,
                                                 [NSNumber numberWithInt:999], kAttributePosition,
                                                 nil];
            [attributes setObject:attributeDictionary forKey:key];
        }
    }
    
    [orderedAttributeKeys removeObject:[NSNull null]];
    BBLog(@"%@", orderedAttributeKeys);
    [self reorderAttributes:attributes toArray:orderedAttributeKeys];
    
    [[NSUserDefaults standardUserDefaults] setObject:projectAttributes forKey:kProjectMenuAttributes];
    BBLog(@"%@", attributes);
    BBLog(@"%@", orderedAttributeKeys);
}


@end
