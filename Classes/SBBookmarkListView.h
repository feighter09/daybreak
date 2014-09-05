/*

SBBookmarkListView.h
 
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
#import "SBCircleProgressIndicator.h"
#import "SBView.h"

@class SBBookmarkListView;
@protocol SBBookmarkListViewDelegate <NSObject>
- (void)bookmarkListViewShouldOpenSearchbar:(SBBookmarkListView *)bookmarkListView;
- (BOOL)bookmarkListViewShouldCloseSearchbar:(SBBookmarkListView *)bookmarkListView;
@end

@class SBBookmarkListItemView;
@class SBBookmarksView;
@class SBButton;
@interface SBBookmarkListView : SBView <NSAnimationDelegate>
{
	SBBookmarksView *__unsafe_unretained wrapperView;
	SBBookmarkMode mode;
	NSSize cellSize;
	CGFloat cellWidth;
	NSMutableArray *itemViews;
	SBView *selectionView;
	SBView *draggingLineView;
	NSArray *draggedItems;
	SBButton *removeButton;
	SBButton *editButton;
	SBButton *updateButton;
	SBBookmarkListItemView *draggedItemView;
	SBBookmarkListItemView *toolsItemView;
	NSTimer *toolsTimer;
	NSPoint _block;
	NSPoint _point;
	NSSize _offset;
	id<SBBookmarkListViewDelegate> __unsafe_unretained delegate;
	NSUInteger _animationIndex;
	NSViewAnimation *searchAnimations;
}
@property (unsafe_unretained) SBBookmarksView *wrapperView;
@property SBBookmarkMode mode;
@property NSSize cellSize;
@property (readonly) CGFloat width;
@property CGFloat cellWidth;
@property (readonly) NSPoint block;
@property (readonly) NSMutableArray *items;
@property (strong) NSArray *draggedItems;
@property (unsafe_unretained) id<SBBookmarkListViewDelegate> delegate;
@property (readonly) CGFloat minimumHeight;
@property (readonly) NSPoint spacing;
@property (readonly) NSIndexSet *selectedIndexes;
@property (getter=getSelectedItems, readonly) NSArray *selectedItems;
@property (readonly) BOOL canScrollToNext;
@property (readonly) BOOL canScrollToPrevious;

// Getter
- (CGFloat)splitWidth:(CGFloat)proposedWidth;
- (NSRect)itemRectAtIndex:(NSInteger)index;
- (SBBookmarkListItemView *)itemViewAtPoint:(NSPoint)point;
- (NSUInteger)indexAtPoint:(NSPoint)point;
- (NSRect)dragginLineRectAtPoint:(NSPoint)point;
- (NSRect)removeButtonRect:(SBBookmarkListItemView *)itemView;
- (NSRect)editButtonRect:(SBBookmarkListItemView *)itemView;
- (NSRect)updateButtonRect:(SBBookmarkListItemView *)itemView;
// Destruction
- (void)destructControls;
// Construction
- (void)constructControls;
// Destruction
- (void)destructSelectionView;
- (void)destructDraggingLineView;
- (void)destructToolsTimer;
- (void)destructSearchAnimations;
// Setter
- (void)setCellSizeForMode:(SBBookmarkMode)inMode;
// Actions
- (void)addForItem:(NSDictionary *)item;
- (void)addForItems:(NSArray *)inItems toIndex:(NSInteger)toIndex;
- (void)createItemViews;
- (void)addItemViewAtIndex:(NSInteger)index item:(NSDictionary *)item;
- (void)addItemViewsToIndex:(NSInteger)toIndex items:(NSArray *)inItems;
- (void)moveItemViewsAtIndexes:(NSIndexSet *)indexes toIndex:(NSUInteger)toIndex;
- (void)removeItemView:(SBBookmarkListItemView *)itemView;
- (void)removeItemViewsAtIndexes:(NSIndexSet *)indexes;
- (void)editItemView:(SBBookmarkListItemView *)itemView;
- (void)editItemViewsAtIndex:(NSUInteger)index;
- (void)openItemsAtIndexes:(NSIndexSet *)indexes;
- (void)selectPoint:(NSPoint)point toPoint:(NSPoint)toPoint exclusive:(BOOL)exclusive;
- (void)layout:(NSTimeInterval)animationTime;
- (void)layoutFrame;
- (void)layoutItemViews;
- (void)layoutItemViewsWithAnimationFromIndex:(NSInteger)fromIndex;
- (void)layoutItemViewsWithAnimationFromIndex:(NSInteger)fromIndex duration:(NSTimeInterval)duration;
- (void)layoutSelectionView:(NSPoint)point;
- (void)layoutToolsForItem:(SBBookmarkListItemView *)itemView;
- (void)layoutTools;
- (void)layoutToolsHidden;
- (void)layoutDraggingLineView:(NSPoint)point;
- (void)updateItems;
- (void)scrollToNext;
- (void)scrollToPrevious;
- (void)needsDisplaySelectedItemViews;
- (void)executeShouldOpenSearchbar;
- (BOOL)executeShouldCloseSearchbar;
- (void)searchWithText:(NSString *)text;
- (void)showIndexes:(NSIndexSet *)indexes;
- (void)startAnimations:(NSArray *)infos;
// Menu Actions
- (void)delete:(id)sender;
- (void)selectAll:(id)sender;
- (void)openSelectedItems:(id)sender;

@end
