/*
NSImage-SBAdditions.swift

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

extension NSImage {
    convenience init(view: NSView) {
        //!!! change back to optional initializer in Xcode 6.1
        let bitmapImageRep = view.bitmapImageRepForCachingDisplayInRect(view.bounds)!
        view.layout()
        view.cacheDisplayInRect(view.bounds, toBitmapImageRep: bitmapImageRep)
        self.init(size: view.bounds.size)
        addRepresentation(bitmapImageRep)
    }
    
    func stretchableImage(#size: NSSize, sideCapWidth: Int) -> NSImage {
        let image = NSImage(size: size)
        image.lockFocus()
        let cgSideCapWidth = CGFloat(sideCapWidth)
        let imageSize = self.size
        let leftPoint = NSZeroPoint
        let rightPoint = NSMakePoint(size.width - imageSize.width, 0)
        let fillRect = NSMakeRect(cgSideCapWidth, CGFloat(0), size.width - cgSideCapWidth * 2, size.height)
        drawAtPoint(leftPoint, fromRect: NSZeroRect, operation: .CompositeSourceOver, fraction: 1.0)
        drawAtPoint(rightPoint, fromRect: NSZeroRect, operation: .CompositeSourceOver, fraction: 1.0)
        drawInRect(fillRect, fromRect: NSMakeRect(cgSideCapWidth, 0, imageSize.width - cgSideCapWidth * 2, imageSize.height), operation: .CompositeSourceOver, fraction: 1.0)
        image.unlockFocus()
        return image
    }
    
    func inset(#size: NSSize, intersectRect: NSRect, offset: NSPoint) -> NSImage {
        let imageSize = self.size
        let inRect = (intersectRect == NSZeroRect) ? NSMakeRect(0, 0, imageSize.width, imageSize.height) : intersectRect
        var translate = NSZeroPoint
        var flippedPoint = NSZeroPoint
        var resizedSize = NSZeroSize
        var perSize = NSZeroSize
        var offsetSize = NSZeroSize
        var per: CGFloat!
        
        let transform = NSAffineTransform()
        let image = NSImage(size: size)
        
        perSize.width = inRect.size.width / 4
        perSize.height = inRect.size.height / 3
        resizedSize = inRect.size
        if perSize.width > perSize.height {
            resizedSize.width = (inRect.size.height / 3) * 4
            per = size.height / inRect.size.height
        } else {
            resizedSize.height = (inRect.size.width / 4) * 3
            per = size.width / inRect.size.width
        }
        flippedPoint.x = inRect.origin.x
        flippedPoint.y = (imageSize.height - inRect.size.height) - inRect.origin.y
        translate.x = -flippedPoint.x
        translate.y = -(flippedPoint.y + (inRect.size.height - resizedSize.height))
        offsetSize.width = imageSize.width * offset.x
        offsetSize.height = imageSize.height * offset.y
        translate.x -= offsetSize.width
        translate.y += offsetSize.height
        
        // Draw in image
        image.lockFocus()
        transform.scaleBy(per)
        transform.translateXBy(translate.x, yBy: translate.y)
        transform.concat()
        drawAtPoint(NSZeroPoint, fromRect: NSZeroRect, operation: .CompositeSourceOver, fraction: 1.0)
        image.unlockFocus()
        
        return image
    }
    
    class func colorImage(size: NSSize, colorName: String) -> NSImage {
        let image = NSImage(size: size)
        let color: NSColor? = NSColor(labelColorName: colorName)
        image.lockFocus()
        if color != nil {
            color!.set()
            NSRectFill(NSMakeRect(0, 0, size.width, size.height))
        } else {
            NSColor.grayColor().set()
            NSFrameRect(NSMakeRect(0, 0, size.width, size.height))
        }
        image.unlockFocus()
        return image
    }
    
    convenience init(CGImage srcImage: CGImageRef) {
        self.init()
        addRepresentation(NSBitmapImageRep(CGImage: srcImage))
    }
    
    var CGImage: CGImageRef {
        return bitmapImageRep.CGImage
    }
    
    var bitmapImageRep: NSBitmapImageRep {
        //let imageRep = bestRepresentationForDevice(nil)
        let imageRep = bestRepresentationForRect(NSRect(origin: NSZeroPoint, size: size), context: nil, hints: [:])
        if let imageRep = imageRep as? NSBitmapImageRep {
            return imageRep
        }
        return NSBitmapImageRep(data: TIFFRepresentation)
    }
    
    func drawInRect(rect: NSRect, operation op: NSCompositingOperation, fraction requestedAlpha: CGFloat, respectFlipped: Bool) {
        drawInRect(rect, fromRect: NSZeroRect, operation: op, fraction: requestedAlpha, respectFlipped: respectFlipped, hints: [:])
    }
}