/*
SBBLKGUIPopUpButton.swift

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

class SBBLKGUIPopUpButton: NSPopUpButton {
    override class func initialize() {
        SBBLKGUIPopUpButton.setCellClass(SBBLKGUIPopUpButtonCell.self)
    }
    
    convenience override init() {
        self.init(frame: NSZeroRect)
    }
    
    override init(frame: NSRect) {
        super.init(frame: frame)
    }
    
    override init(frame: NSRect, pullsDown: Bool) {
        super.init(frame: frame, pullsDown: pullsDown)
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override var alignmentRectInsets: NSEdgeInsets {
        return NSEdgeInsetsMake(0, 0, 0, 0)
    }
}

class SBBLKGUIPopUpButtonCell: NSPopUpButtonCell {
    override func drawWithFrame(cellFrame: NSRect, inView: NSView) {
        let controlView = inView as SBBLKGUIPopUpButton
        
        var leftImage: NSImage?
        var centerImage: NSImage?
        var rightImage: NSImage?
        if bordered {
            var drawRect = NSZeroRect
            let fraction: CGFloat = enabled ? 1.0 : 0.5
            
            leftImage = NSImage(named:   highlighted ? "BLKGUI_PopUp-Highlighted-Left.png" :   "BLKGUI_PopUp-Left.png")
            centerImage = NSImage(named: highlighted ? "BLKGUI_PopUp-Highlighted-Center.png" : "BLKGUI_PopUp-Center.png")
            rightImage = NSImage(named:  highlighted ? "BLKGUI_PopUp-Highlighted-Right.png" :  "BLKGUI_PopUp-Right.png")
            
            // Left
            drawRect.origin = cellFrame.origin
            drawRect.size = leftImage!.size
            drawRect.origin.y = (cellFrame.size.height - drawRect.size.height) / 2
            leftImage!.drawInRect(drawRect, operation: .CompositeSourceOver, fraction: fraction, respectFlipped: true)
            
            // Center
            drawRect.origin.x = leftImage!.size.width
            drawRect.size.width = cellFrame.size.width - (leftImage!.size.width + rightImage!.size.width)
            drawRect.origin.y = (cellFrame.size.height - drawRect.size.height) / 2
            centerImage!.drawInRect(drawRect, operation: .CompositeSourceOver, fraction: fraction, respectFlipped: true)
            
            // Right
            drawRect.size = rightImage!.size
            drawRect.origin.x = cellFrame.size.width - drawRect.size.width
            drawRect.origin.y = (cellFrame.size.height - drawRect.size.height) / 2
            rightImage!.drawInRect(drawRect, operation: .CompositeSourceOver, fraction: fraction, respectFlipped: true)
        }
        
        let image = controlView.selectedItem?.image
        if let image = image {
            var imageRect = NSZeroRect
            imageRect.size = image.size
            imageRect.origin.x = cellFrame.origin.x + 5.0
            imageRect.origin.y = cellFrame.origin.y + ((cellFrame.size.height - imageRect.size.height) / 2)
            SBPreserveGraphicsState {
                let transform = NSAffineTransform()
                transform.translateXBy(0.0, yBy: cellFrame.size.height)
                transform.scaleXBy(1.0, yBy: -1.0)
                transform.concat()
                image.drawInRect(imageRect, fromRect: NSZeroRect, operation: .CompositeSourceOver, fraction: 1.0)
            }
        }
        
        let attributedTitle = NSAttributedString(string: controlView.titleOfSelectedItem ?? "")
        if attributedTitle.length > 0 {
            var titleRect = NSZeroRect
            let mutableTitle = NSMutableAttributedString(attributedString: attributedTitle)
            let range = NSMakeRange(0, attributedTitle.length)
            let style = NSMutableParagraphStyle()
            let font = NSFont(name: self.font!.fontName, size: NSFont.systemFontSizeForControlSize(controlSize))
            let foregroundColor = enabled ? (highlighted ? NSColor.lightGrayColor() : NSColor.whiteColor()) : NSColor.grayColor()
            
            style.alignment = .CenterTextAlignment
            style.lineBreakMode = .ByTruncatingTail
            mutableTitle.beginEditing()
            mutableTitle.addAttribute(NSForegroundColorAttributeName, value: foregroundColor, range:range)
            mutableTitle.addAttribute(NSFontAttributeName, value: font!, range: range)
            mutableTitle.addAttribute(NSParagraphStyleAttributeName, value: style, range: range)
            mutableTitle.endEditing()
            
            titleRect.size.width = mutableTitle.size.width
            titleRect.size.height = mutableTitle.size.height
            titleRect.origin.x = cellFrame.origin.x + (leftImage?.size.width ?? 0.0) + 5.0 + (image?.size.width ?? -5.0) + 5.0
            titleRect.origin.y = cellFrame.origin.y + ((cellFrame.size.height - titleRect.size.height) / 2) - 2
            mutableTitle.drawInRect(titleRect)
        }
    }
}