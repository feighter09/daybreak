/*

SBDocument.h
 
Authoring by Atsushi Jike

Copyright 2010 Atsushi Jike. All rights reserved.

Redistribution and use in source and binary forms, with or without modification, 
are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer 
in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/


#import "SBDefinitions.h"

@class SBBookmarkView;
@class SBBookmarksView;
@class SBDocumentWindow;
@class SBDownloaderView;
@class SBDownloadsView;
@class SBEditBookmarkView;
@class SBHistoryView;
@class SBLoadButton;
@class SBMessageView;
@class SBTextInputView;
@class SBPopUpButton;
@class SBReportView;
@class SBSegmentedButton;
@class SBSidebar;
@class SBSnapshotView;
@class SBTabbar;
@class SBTabView;
@class SBTabbarItem;
@class SBTabViewItem;
@class SBUserAgentView;
@class SBURLField;
@class SBWebView;
@class SBToolbar;
@class SBPopUpButton;
@class SBWebResourcesView;
@class SBSplitView;
@protocol SBBookmarksViewDelegate;
@protocol SBSplitViewDelegate;
@protocol SBTabbarDelegate;
@protocol SBToolbarDelegate;
@protocol SBWebResourcesViewDelegate;
@protocol SBWebResourcesViewDataSource;
@protocol SBTabViewDelegate;
@protocol SBDocumentWindowDelegate;
@protocol SBDownloaderDelegate;
@protocol SBURLFieldDatasource;
@protocol SBURLFieldDelegate;
@interface SBDocument : NSDocument <SBTabbarDelegate, SBDownloaderDelegate, SBURLFieldDatasource, SBURLFieldDelegate, SBSplitViewDelegate, SBTabViewDelegate, SBBookmarksViewDelegate, SBWebResourcesViewDataSource, SBWebResourcesViewDelegate, SBToolbarDelegate, SBSplitViewDelegate, SBDocumentWindowDelegate>
{
	SBDocumentWindow *__unsafe_unretained window;
	NSWindowController *__unsafe_unretained windowController;
	SBToolbar *toolbar;
	NSView *urlView;
	SBURLField *urlField;
	NSView *loadView;
	NSView *encodingView;
	NSView *zoomView;
	SBLoadButton *loadButton;
	SBPopUpButton *encodingButton;
	SBSegmentedButton *zoomButton;
	SBTabbar *tabbar;
	SBSplitView *splitView;
	SBTabView *tabView;
	SBSidebar *sidebar;
	SBBookmarkView *bookmarkView;
	SBEditBookmarkView *editBookmarkView;
	SBDownloaderView *downloaderView;
	SBSnapshotView *snapshotView;
	SBReportView *reportView;
	SBUserAgentView *userAgentView;
	SBHistoryView *historyView;
	SBMessageView *messageView;
	SBTextInputView *textInputView;
	NSURL *initialURL;
	BOOL sidebarVisibility;
	NSInteger _identifier;
	NSInteger confirmed;
}
@property (unsafe_unretained) SBDocumentWindow *window;
@property (unsafe_unretained) NSWindowController *windowController;
@property (strong) NSToolbar *toolbar;
@property (strong) SBURLField *urlField;
@property (strong) SBTabbar *tabbar;
@property (strong) SBSplitView *splitView;
@property (strong) NSURL *initialURL;
@property BOOL sidebarVisibility;
@property (readonly) SBTabViewItem *selectedTabViewItem;
@property (readonly) SBWebView *selectedWebView;
@property (readonly) NSView *selectedWebDocumentView;
@property (readonly) WebDataSource *selectedWebDataSource;
@property (readonly) NSImage *selectedWebViewImageForBookmark;
@property (readonly) NSData *selectedWebViewImageDataForBookmark;
@property (readonly) SBWebResourcesView *resourcesView;
@property (readonly) NSInteger createdTag;
@property (readonly) NSInteger tabCount;
@property (readonly) NSRect visibleRectOfSelectedWebDocumentView;
@property (readonly) NSImage *selectedWebViewImage;
@property (readonly) CGFloat minimumDownloadsDrawerHeight;
@property (readonly) BOOL shouldCloseDocument;

// Getter
- (NSImage *)selectedWebViewImage:(NSSize)size;
- (CGFloat)adjustedSplitPositon:(CGFloat)proposedPosition;
// Destruction
- (void)destructWindow;
- (void)destructWindowController;
- (void)destructToolbar;
- (void)destructURLField;
- (void)destructLoadButton;
- (void)destructEncodingButton;
- (void)destructZoomButton;
- (void)destructTabbar;
- (void)destructSplitView;
- (void)destructTabView;
- (void)destructSidebar;
- (SBBookmarksView *)constructBookmarksView;
- (void)destructBookmarkView;
- (void)destructEditBookmarkView;
- (void)destructDownloaderView;
- (void)destructSnapshotView;
- (void)destructReportView;
- (void)destructUserAgentView;
- (void)destructHistoryView;
- (void)destructMessageView;
- (void)destructTextInputView;
// Construction
- (SBDocumentWindow *)constructWindow;
- (NSWindowController *)constructWindowController:(SBDocumentWindow *)newWindow;
- (void)constructToolbar;
- (void)constructURLField;
- (void)constructLoadButton;
- (void)constructEncodingButton;
- (void)constructZoomButton;
- (void)constructTabbar;
- (void)constructSplitView;
- (void)constructTabView;
- (void)constructSidebar;
- (void)constructNewTabWithString:(NSString *)string selection:(BOOL)selection;
- (void)constructNewTabWithURL:(NSURL *)URL selection:(BOOL)selection;
- (SBTabbarItem *)constructTabbarItemWithTag:(NSInteger)tag;
- (SBTabViewItem *)constructTabViewItemWithIdentifier:(NSNumber *)identifier tabbarItem:(SBTabbarItem *)tabbarItem;
- (SBDownloadsView *)constructDownloadsViewInSidebar;
- (void)addObserverNotifications;
- (void)removeObserverNotifications;
// // Update
- (void)updateMenuWithTag:(NSInteger)tag;
- (void)updateResourcesViewIfNeeded;
- (void)updateURLFieldGoogleSuggest;
- (void)updateURLFieldGoogleSuggestDidEnd:(NSData *)data;
- (void)updateURLFieldCompletionList;
// Actions
- (void)performCloseFromButton:(id)sender;
- (void)performClose:(id)sender;
- (void)openAndConstructTabWithURLs:(NSArray *)urls startInTabbarItem:(SBTabbarItem *)aTabbarItem;
- (void)openAndConstructTabWithBookmarkItems:(NSArray *)items;
- (void)adjustSplitViewIfNeeded;
// Menu Actions
// Application menu
- (void)about:(id)sender;
// File menu
- (void)createNewTab:(id)sender;
- (void)openLocation:(id)sender;
- (void)saveDocumentAs:(id)sender;
- (void)downloadFromURL:(id)sender;
- (void)doneDownloader;
- (void)cancelDownloader;
- (void)snapshot:(id)sender;
- (void)doneSnapshot;
- (void)cancelSnapshot;
// View menu
- (void)toggleAllbars:(id)sender;
- (void)toggleTabbar:(id)sender;
- (void)sidebarPositionToLeft:(id)sender;
- (void)sidebarPositionToRight:(id)sender;
- (void)reload:(id)sender;
- (void)stopLoading:(id)sender;
- (void)scaleToActualSizeForView:(id)sender;
- (void)zoomInView:(id)sender;
- (void)zoomOutView:(id)sender;
- (void)scaleToActualSizeForText:(id)sender;
- (void)zoomInText:(id)sender;
- (void)zoomOutText:(id)sender;
- (void)source:(id)sender;
- (void)resources:(id)sender;
- (void)showWebInspector:(id)sender;
- (void)showConsole:(id)sender;
// History menu
- (void)backward:(id)sender;
- (void)forward:(id)sender;
- (void)showHistory:(id)sender;
- (void)doneHistory:(NSArray *)urls;
- (void)cancelHistory;
- (void)openHome:(id)sender;
// Bookmarks menu
- (void)bookmarks:(id)sender;
- (void)bookmark:(id)sender;
- (void)doneBookmark;
- (void)cancelBookmark;
- (void)editBookmarkItemAtIndex:(NSUInteger)index;
- (void)doneEditBookmark;
- (void)cancelEditBookmark;
- (void)searchInBookmarks:(id)sender;
- (void)switchToIconMode:(id)sender;
- (void)switchToListMode:(id)sender;
- (void)switchToTileMode:(id)sender;
// Window menu
- (void)selectPreviousTab:(id)sender;
- (void)selectNextTab:(id)sender;
- (void)downloads:(id)sender;
// Toolbar Actions
- (void)openURLStringInSelectedTabViewItem:(NSString *)stringValue;
- (void)openURLFromField:(id)sender;
- (void)openURLInNewTabFromField:(id)sender;
- (void)openString:(NSString *)stringValue newTab:(BOOL)newer;
- (void)searchString:(NSString *)stringValue newTab:(BOOL)newer;
- (void)changeEncodingFromMenuItem:(id)sender;
- (void)load:(id)sender;
- (void)bugReport:(id)sender;
- (void)doneReport;
- (void)cancelReport;
- (void)selectUserAgent:(id)sender;
- (void)doneUserAgent;
- (void)cancelUserAgent;
- (void)snapshot:(id)sender;
// Actions
- (void)selectURLField;
- (void)startDownloadingForURL:(NSURL *)URL;
- (void)toggleAllbarsAndSidebar;
- (void)hideAllbars;
- (void)showAllbars;
- (void)hideToolbar;
- (void)showToolbar;
- (void)toggleTabbar;
- (void)hideTabbar;
- (void)showTabbar;
- (void)hideSidebar;
- (void)showSidebar;
- (void)hideDrawer;
- (void)showDrawer;
- (void)showMessage:(NSString *)message;
- (void)doneShowMessageView;
- (BOOL)confirmMessage:(NSString *)message;
- (void)doneConfirmMessageView;
- (void)cancelConfirmMessageView;
- (NSString *)textInput:(NSString *)prompt;
- (void)doneTextInputView;
- (void)cancelTextInputView;
- (void)toggleEditableForSelectedWebView;
- (void)toggleFlip;
// Debug
- (void)debug:(NSNumber *)value;
- (void)debugAddDummyDownloads:(id)sender;

@end
