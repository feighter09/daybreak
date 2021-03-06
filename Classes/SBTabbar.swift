/*
SBTabbar.swift

Copyright (c) 2014, Alice Atlas
Copyright (c) 2010, Atsushi Jike
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

@objc protocol SBTabbarDelegate {
    optional func tabbar(_: SBTabbar, didChangeSelection: SBTabbarItem)
    optional func tabbar(_: SBTabbar, didReselection: SBTabbarItem)
    optional func tabbar(_: SBTabbar, shouldAddNewItemForURLs: [NSURL]?)
    optional func tabbar(_: SBTabbar, shouldOpenURLs: [NSURL], startInItem: SBTabbarItem)
    optional func tabbar(_: SBTabbar, shouldReload: SBTabbarItem)
    optional func tabbar(_: SBTabbar, didRemoveItem tag: NSInteger)
}

class SBTabbar: SBView, NSAnimationDelegate {
    var items: [SBTabbarItem] = []
    weak var delegate: SBTabbarDelegate?
    private var downPoint: NSPoint!
    private var draggedItemRect: NSRect!
    private var draggedItem: SBTabbarItem?
    private var shouldReselectItem: SBTabbarItem?
    private var animating = false
    private var autoScrollTimer: NSTimer?
    //private var autoScrollDeltaX: CGFloat
    private var closableTimer: NSTimer?
    private var closableItem: SBTabbarItem?
    
    private var addButton: SBButton? {
        didSet {
            oldValue?.removeFromSuperview()
        }
    }
    
    private lazy var contentView: SBView = {
        return SBView(frame: self.bounds)
    }()
    
    override var toolbarVisible: Bool {
        didSet {
            if toolbarVisible != oldValue {
                needsDisplay = true
                for subview: NSView in subviews {
                    if let subview = subview as? SBView {
                        subview.toolbarVisible = toolbarVisible
                    }
                }
            }
        }
    }
    
    init() {
        super.init(frame: .zero)
        addSubview(contentView)
        registerForDraggedTypes([SBBookmarkPboardType, NSURLPboardType, NSFilenamesPboardType])
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    deinit {
        destructAutoScrollTimer()
        destructClosableTimer()
    }
    
    // MARK: Rects
    
    let itemWidth: CGFloat = kSBTabbarItemMaximumWidth
    let itemMinimumWidth: CGFloat = kSBTabbarItemMinimumWidth
    
    var filled: Bool {
        let width = bounds.size.width - addButtonWidth
        let count = CGFloat(items.count)
        return (count * itemWidth) > width && (width / count) < itemMinimumWidth
    }
    
    var addButtonWidth: CGFloat { return bounds.size.height }
    var innerWidth: CGFloat { return bounds.size.width - addButtonWidth }
    var addButtonRect: NSRect { return addButtonRect(items.count) }
    
    func addButtonRect(count: Int) -> NSRect {
        var r = NSZeroRect
        var itemWidth = self.itemWidth
        let width = innerWidth
        let cgCount = CGFloat(count)
        if (cgCount * itemWidth) > width {
            let w = width / cgCount
            itemWidth = w.constrained(min: itemMinimumWidth)
        }
        r.size.width = addButtonWidth
        r.size.height = bounds.size.height
        r.origin.x = cgCount * itemWidth
        return NSIntegralRect(r)
    }
    
    var newItemRect: NSRect { return itemRectAtIndex(items.count) }
    
    func itemRectAtIndex(index: Int) -> NSRect {
        var r = NSZeroRect
        var itemWidth = self.itemWidth
        let width = innerWidth
        var count = items.count
        if index >= count {
            count += 1
        }
        if (CGFloat(count) * itemWidth) > width {
            let w = width / CGFloat(count)
            itemWidth = w.constrained(min: itemMinimumWidth)
        }
        r.size.width = itemWidth
        r.size.height = bounds.size.height
        r.origin.x = CGFloat(index) * itemWidth
        return NSIntegralRect(r)
    }
    
    func indexForPoint(point: NSPoint) -> (Int, NSRect) {
        for index in 0..<items.count {
            let r = itemRectAtIndex(index)
            if point.x >= r.origin.x && point.x <= r.maxX {
                return (index, r)
            }
        }
        return (items.count, .zero)
    }
    
    func itemAtPoint(point: NSPoint) -> SBTabbarItem? {
        return items.first{$0.frame.contains(point)}
    }
    
    var selectedTabbarItem: SBTabbarItem? {
        return items.first{$0.selected}
    }
    
    var selectedTabbarItemIndex: Int? {
        return items.firstIndex{$0.selected}
    }
    
    // MARK: NSAnimation Delegate
    
    func animationShouldStart(animation: NSAnimation) -> Bool {
        let should = !animating
        animating = true
        return should
    }
    
    func animation(animation: NSAnimation, valueForProgress progress: NSAnimationProgress) -> Float {
        // Needs display dragged item
        draggedItem?.needsDisplay = true
        return progress
    }
    
    func animationDidEnd(animation: NSAnimation) {
        if draggedItem != nil {
            updateItems()
        }
        animating = false
    }
    
    func animationDidStop(animation: NSAnimation) {
        animating = false
    }
    
    // MARK: Destruction
    
    func destructAutoScrollTimer() {
        autoScrollTimer?.invalidate()
        autoScrollTimer = nil
    }
    
    func destructClosableTimer() {
        closableTimer?.invalidate()
        closableTimer = nil
    }
    
    // MARK: Construction
    
    func constructAddButton() {
        let r = addButtonRect
        addButton = SBButton(frame: r)
        addButton!.image = SBAddIconImage(r.size, false)
        addButton!.backImage = SBAddIconImage(r.size, true)
        addButton!.target = self
        addButton!.action = #selector(addNewItem(_:))
        contentView.addSubview(addButton!)
    }
    
    // MARK: Exec
    
    func executeShouldAddNewItemForURLs(URLs: [NSURL]?) {
        delegate?.tabbar?(self, shouldAddNewItemForURLs: URLs)
    }
    
    func executeShouldOpenURLs(URLs: [NSURL], startInItem item: SBTabbarItem) {
        delegate?.tabbar?(self, shouldOpenURLs: URLs, startInItem: item)
    }
    
    func executeShouldReloadItem(item: SBTabbarItem) {
        delegate?.tabbar?(self, shouldReload: item)
    }
    
    func executeShouldReselect(item: SBTabbarItem) {
        shouldReselectItem = item
    }
    
    func executeDidChangeSelection(item: SBTabbarItem) {
        delegate?.tabbar?(self, didChangeSelection: item)
    }

    func executeDidReselectItem(item: SBTabbarItem) {
        delegate?.tabbar?(self, didReselection: item)
    }
    
    func executeDidRemoveItem(tag: Int) {
        delegate?.tabbar?(self, didRemoveItem: tag)
    }
    
    // MARK: Actions
    
    func addItemWithTag(tag: NSInteger) -> SBTabbarItem {
        let newItem = SBTabbarItem(frame: newItemRect, tabbar: self)
        newItem.tag = tag
        newItem.target = self
        newItem.closeSelector = #selector(closeItem(_:))
        newItem.selectSelector = #selector(selectItem(_:))
        newItem.keyView = keyView
        addItem(newItem)
        updateItems()
        return newItem
    }
    
    func addItem(item: SBTabbarItem) {
        items.append(item)
        contentView.addSubview(item)
    }
    
    func removeItem(item: SBTabbarItem) -> Bool {
        if contains(items, item) {
            item.removeFromSuperview()
            Daybreak.removeItem(&items, item)
            return true
        }
        return false
    }
    
    func selectItem(item: SBTabbarItem) {
        if !items.isEmpty {
            if selectedTabbarItem != item {
                items.map { $0.selected = false }
                item.selected = true
                executeDidChangeSelection(item)
            }
        } else {
            NSBeep()
        }
    }
    
    func selectItemForIndex(index: Int) {
        var item: SBTabbarItem?
        let count = items.count
        if index == 0 {
            item = items.get(index)
        } else if index == count {
            item = items[index - 1]
        } else {
            item = items[index]
        }
        if item != nil {
            selectItem(item!)
        }
    }
    
    func selectLastItem() {
        guard !items.isEmpty else {
            NSBeep()
            return
        }
        selectItem(items.last!)
    }
    
    func selectPreviousItem() {
        guard !items.isEmpty else {
            NSBeep()
            return
        }
        let prevItem = selectedTabbarItemIndex !! {items.get($0 - 1)} ?? items.last!
        selectItem(prevItem)
    }
    
    func selectNextItem() {
        guard !items.isEmpty else {
            NSBeep()
            return
        }
        let nextItem = selectedTabbarItemIndex !! {items.get($0 + 1)} ?? items.first!
        selectItem(nextItem)
    }
    
    func closeItem(item: SBTabbarItem) {
        guard !items.isEmpty else {
            NSBeep()
            return
        }
        let shouldSelect = item.selected
        let tag = item.tag
        let index = items.indexOf(item)
        if removeItem(item) {
            updateItems()
            if shouldSelect {
                selectItemForIndex(index!)
            }
            executeDidRemoveItem(tag)
        }
    }
    
    func closeSelectedItem() {
        guard !items.isEmpty else {
            NSBeep()
            return
        }
        selectedTabbarItem !! closeItem
    }
    
    func addNewItem(sender: AnyObject?) {
        executeShouldAddNewItemForURLs(nil)
    }
    
    func closeItemFromMenu(menuItem: NSMenuItem) {
        items.get(menuItem.tag) !! closeItem
    }
    
    func closeOtherItemsFromMenu(menuItem: NSMenuItem) {
        items.reverse().filter{items.indexOf($0) != menuItem.tag}.forEach(closeItem)
    }
    
    func reloadItemFromMenu(menuItem: NSMenuItem) {
        items.get(menuItem.tag) !! executeShouldReloadItem
    }
    
    override func layout() {
        var size = bounds.size
        if filled {
            let count = CGFloat(items.count)
            size.width = itemMinimumWidth * count + addButtonWidth
            contentView.autoresizingMask = .ViewMinYMargin
        } else {
            contentView.frame.origin = .zero
            contentView.autoresizingMask = [.ViewWidthSizable, .ViewMinYMargin]
        }
        contentView.frame.size = size
    }
    
    func scroll(deltaX: CGFloat) {
        if filled {
            var contentRect = contentView.frame
            let x = contentRect.origin.x + deltaX
            if x > 0 {
                contentRect.origin.x = 0
            } else if x < (bounds.size.width - contentRect.size.width) {
                contentRect.origin.x = bounds.size.width - contentRect.size.width
            } else {
                contentRect.origin.x = x
            }
            contentView.frame = contentRect
        }
    }
    
    func autoScrollWithPoint(point: NSPoint) -> Bool {
        var deltaX: CGFloat = 0.0
        let width: CGFloat = 20.0
        var leftRect = bounds
        var rightRect = bounds
        leftRect.size.width = width
        rightRect.size.width = width
        rightRect.origin.x = bounds.size.width - width
        if leftRect.origin.x < point.x && leftRect.maxX > point.x {
            deltaX = 10.0
        } else if rightRect.origin.x < point.x && rightRect.maxX > point.x {
            deltaX = -10.0
        }
        if deltaX != 0 {
            scroll(deltaX)
            return true
        }
        return false
    }
    
    func autoScroll(event: NSEvent) {
        destructAutoScrollTimer()
        if filled {
            let userInfo: [NSObject: AnyObject] = ["Event": event]
            let point = convertPoint(event.locationInWindow, fromView: nil)
            if autoScrollWithPoint(point) {
                autoScrollTimer = .scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(mouseDragged(timer:)), userInfo: userInfo, repeats: true)
            }
        }
    }
    
    @objc(mouseDraggedWithTimer:)
    func mouseDragged(#timer: NSTimer) {
        let event = timer.userInfo!["Event"] as! NSEvent
        mouseDragged(event)
    }
    
    var canClosable: Bool {
        return items.count > 1
    }
    
    func constructClosableTimerForItem(item: SBTabbarItem) {
        if closableItem != item {
            closableItem = item
            destructClosableTimer()
            closableTimer = .scheduledTimerWithTimeInterval(kSBTabbarItemClosableInterval, target: self, selector: #selector(applyClosableItem), userInfo: nil, repeats: false)
        }
    }
    
    func applyClosableItem() {
        destructClosableTimer()
        closableItem?.closable = true
    }
    
    func applyDisclosableAllItem() {
        destructClosableTimer()
        items.forEach { $0.closable = false }
        closableItem = nil
    }
    
    // MARK: Update
    
    func updateItems() {
        let currentEvent = NSApp.currentEvent
        let location = currentEvent?.locationInWindow
        for (index, item) in enumerate(items) {
            // Update frame of item
            let r = itemRectAtIndex(index)
            if item.frame != r {
                item.frame = r
            } else {
                item.needsDisplay = true
            }
            if draggedItem != nil {
                // Ignore while dragging
            } else if location != nil {
                if canClosable {
                    // If the mouse is entered in the closable rect, make a tabbar item closable
                    let point = item.convertPoint(location!, fromView: nil)
                    if item.closableRect.contains(point) {
                        constructClosableTimerForItem(item)
                    }
                }
            }
        }
        addButton?.frame = addButtonRect
        addButton?.pressed = false
        layout()
    }
    
    func dragItemAtPoint(point: NSPoint) {
        var r = NSZeroRect
        var index = 0
        var animations: [[String: AnyObject]] = []
        
        for item in items {
            r = itemRectAtIndex(index)
            if point.x >= r.origin.x && point.x <= r.maxX {
                index++
                r = itemRectAtIndex(index)
            }
            if item.frame != r && !animating {
                animations.append([
                    NSViewAnimationTargetKey: item,
                    NSViewAnimationStartFrameKey: NSValue(rect: item.frame),
                    NSViewAnimationEndFrameKey: NSValue(rect: r)])
            } else {
                item.needsDisplay = true
            }
            index++
        }
        r = addButtonRect(index)
        if addButton!.frame != r && !animating {
            animations.append([
                NSViewAnimationTargetKey: addButton!,
                NSViewAnimationStartFrameKey: NSValue(rect: addButton!.frame),
                NSViewAnimationEndFrameKey: NSValue(rect: r)])
        }
        
        if !animations.isEmpty && !animating {
            let animation = NSViewAnimation(viewAnimations: animations)
            animation.duration = 0.25
            animation.delegate = self
            animation.startAnimation()
        }
    }
    
    // MARK: Dragging DataSource
    
    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        return .Copy
    }
    
    override func draggingUpdated(sender: NSDraggingInfo) -> NSDragOperation {
        return .Copy
    }
    
    override func performDragOperation(sender: NSDraggingInfo) -> Bool {
        var r = true
        let pasteboard = sender.draggingPasteboard()
        let types = pasteboard.types!
        let point = contentView.convertPoint(sender.draggingLocation(), fromView: nil)
        if contains(types, SBBookmarkPboardType) {
            let pbItems = pasteboard.propertyListForType(SBBookmarkPboardType) as! [NSDictionary]
            let URLStrings = pbItems.map {$0[kSBBookmarkURL] as! String}.filter {!$0.isEmpty}
            if let URLs = URLStrings.optionalMap({NSURL(string: $0)}).ifNotEmpty {
                if URLs.count == 1, let item = itemAtPoint(point) {
                    executeShouldOpenURLs([URLs[0]], startInItem: item)
                } else {
                    executeShouldAddNewItemForURLs(URLs)
                }
            }
        } else if contains(types, NSURLPboardType) {
            let URL = NSURL(fromPasteboard: pasteboard)!
            if let item = itemAtPoint(point) {
                executeShouldOpenURLs([URL], startInItem: item)
            } else {
                executeShouldAddNewItemForURLs([URL])
            }
        }
        return r
    }
    
    // MARK: Event
    
    override func mouseDown(event: NSEvent) {
        if items.count > 1 {
            let location = event.locationInWindow
            draggedItem = nil
            shouldReselectItem = nil
            draggedItemRect = .zero
            downPoint = contentView.convertPoint(location, fromView: nil)
        }
    }
    
    override func mouseDragged(event: NSEvent) {
        if items.count > 1 || draggedItem != nil {
            let location = event.locationInWindow
            let point = contentView.convertPoint(location, fromView: nil)
            if SBAllowsDrag(downPoint, point) {
                if draggedItem == nil, let item = itemAtPoint(downPoint) {
                    // Get dragging item
                    draggedItem = item
                    shouldReselectItem = nil
                    draggedItemRect = item.frame
                    Daybreak.removeItem(&items, item)
                    contentView.addSubview(item)  // Bring to front
                }
                if draggedItem != nil {
                    // Move dragged item
                    var r = draggedItemRect
                    if (r.maxX + (point.x - downPoint.x)) >= contentView.bounds.size.width {
                        // Max
                        r.origin.x = contentView.bounds.size.width - r.size.width
                    } else if (r.origin.x + (point.x - downPoint.x)) <= 0 {
                        // Min
                        r.origin.x = 0
                    } else {
                        r.origin.x += point.x - downPoint.x
                    }
                    draggedItem!.frame = r
                    dragItemAtPoint(point)
                    needsDisplay = true
                    autoScroll(event)
                }
            }
        }
    }
    
    override func mouseMoved(event: NSEvent) {
    }
    
    override func mouseEntered(event: NSEvent) {
    }
    
    override func mouseExited(event: NSEvent) {
        destructAutoScrollTimer()
    }
    
    override func mouseUp(event: NSEvent) {
        if draggedItem != nil {
            let location = event.locationInWindow
            let point = contentView.convertPoint(location, fromView: nil)
            let (index, r) = indexForPoint(point)
            // Add dragged item
            draggedItem!.frame = r
            items.insert(draggedItem!, atIndex: index)
            updateItems()
            if draggedItem!.selected {
                selectItem(draggedItem!)
            }
            draggedItem = nil
            destructAutoScrollTimer()
        }
        if shouldReselectItem != nil {
            executeDidReselectItem(shouldReselectItem!)
            shouldReselectItem = nil
        }
    }
    
    override func scrollWheel(event: NSEvent) {
        scroll(event.deltaX)
    }
    
    func menuForItem(item: SBTabbarItem) -> NSMenu {
        let single = items.count == 1
        let index = indexOfItem(items, item)!
        let menu = NSMenu()
        menu.addItemWithTitle(NSLocalizedString("New Tab", comment: ""), action: #selector(addNewItem(_:)), keyEquivalent: "")
        if single {
        } else {
            menu.addItem(title: NSLocalizedString("Close", comment: ""), target: self, action: #selector(closeItemFromMenu(_:)), tag: index)
            menu.addItem(title: NSLocalizedString("Close Others", comment: ""), target: self, action: #selector(closeOtherItemsFromMenu(_:)), tag: index)
        }
        menu.addItem(.separatorItem())
        menu.addItem(title: NSLocalizedString("Reload", comment: ""), target: self, action: #selector(reloadItemFromMenu(_:)), tag: index)
        return menu
    }
    
    override func menuForEvent(event: NSEvent) -> NSMenu {
        let menu = NSMenu()
        menu.addItemWithTitle(NSLocalizedString("New Tab", comment: ""), action: #selector(addNewItem(_:)), keyEquivalent: "")
        return menu
    }
    
    // MARK: Drawing
    
    override func drawRect(rect: NSRect) {
        var color0: NSColor!
        var color1: NSColor!
        if keyView {
            color0 = NSColor(deviceWhite: 150.0/255.0, alpha: 1.0)
            color1 = NSColor(deviceWhite: 135.0/255.0, alpha: 1.0)
        } else {
            color0 = NSColor(deviceWhite: 207.0/255.0, alpha: 1.0)
            color1 = color0
        }
        let gradient = NSGradient(colors: [color0, color1], atLocations: [0.7, 1.0], colorSpace: NSColorSpace.deviceGrayColorSpace())!
        gradient.drawInRect(rect, angle: 90)
        
        let strokeColor = NSColor(deviceWhite: 0.3, alpha: 1.0)
        strokeColor.set()
        
        var path = NSBezierPath()
        path.moveToPoint(rect.origin)
        path.lineToPoint(NSMakePoint(rect.maxX, rect.origin.y))
        path.lineWidth = 0.5
        path.stroke()
        
        path = NSBezierPath()
        path.moveToPoint(NSMakePoint(rect.origin.x, rect.maxY))
        path.lineToPoint(NSMakePoint(rect.maxX, rect.maxY - 0.5))
        path.lineWidth = 0.5
        path.stroke()
    }
}