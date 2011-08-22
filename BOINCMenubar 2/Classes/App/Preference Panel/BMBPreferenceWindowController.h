//
//  BMBPreferenceWindowController.h
//  BOINCMenubar
//
//  Created by BrotherBard on 4/11/08.
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


//  BB_ViewController_Category
//    a category on NSViewController used in the setPrefViewForToolbarItem method
//    these do nothing, subclasses of NSViewController will override these to provide funcionality

@interface NSViewController (BMB_ViewController_Category)

// allows view controllers to do setup (ex: add observers, set first responder)
- (void)BMB_contentViewWillLoad;

// allows view controllers to remove observers and clean up
- (void)BMB_contentViewDidUnload;

@end



//  pref keys
//    these keys are also stored in the paletteLabel field of the toolbar items in IB
//    when a user clicks on a toolbar item we can look up the view controller for it based on the key
//    in the paletteLabel or if we want to open the window to a particular view send the key
//    to the openPrefWindowWithViewKey: method

extern NSString * const kBMBGeneralPrefKey;
extern NSString * const kBMBAppearancePrefKey;
//extern NSString * const kBMBAdvancedPrefKey;
extern NSString * const kBMBHostsPrefKey;
extern NSString * const kBOINCPrefKey;
extern NSString * const kBOINCProjectsPrefKey;
extern NSString * const kBOINCNetworkPrefKey;




#pragma mark -


@interface BMBPreferenceWindowController : NSWindowController
{
    // prefViewDictionary
    //    this dictionary is used to look up a view controller for a pref key
    //    the setPrefViewForToolbarItem method will find the toolbar's key by looking in it's paletteLabel
    //    then look in this dictionary for the view controller
    NSDictionary *prefViewDictionary;
    
    // prefItemDictionary
    //    this dictionary is used to look up the toolbar item for a pref key
    NSDictionary *prefItemDictionary;
    
    // activePrefViewKey
    //    key for the currently active toolbar view
    NSString *activePrefKey;
    
    NSToolbar *prefToolbar;
}
@property (nonatomic, retain) NSDictionary       *prefViewDictionary;
@property (nonatomic, retain) NSDictionary       *prefItemDictionary;
@property (nonatomic, copy)   NSString           *activePrefKey;
@property (nonatomic, retain) IBOutlet NSToolbar *prefToolbar;


- (id)initWithClientManager:(id)clientManager;


// opens the pref window to a specified view (can be nil for the default/most recent view)
- (void)openPrefWindowWithPrefKey:(NSString *)prefKey;

// IB action for the NSToolbarItems
//    resizes the window to the new view's size and allows the old and new view controllers to do cleanup/setup
- (IBAction)setPrefViewForToolbarItem:(id)prefToolbarItem;

- (id)currentViewController;


@end
