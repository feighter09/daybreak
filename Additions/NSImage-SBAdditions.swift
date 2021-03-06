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
    convenience init?(view: NSView) {
        let bitmapImageRep = view.bitmapImageRepForCachingDisplayInRect(view.bounds)
        view.layout()
        if bitmapImageRep == nil {
            self.init()
            return nil
        }
        view.cacheDisplayInRect(view.bounds, toBitmapImageRep: bitmapImageRep!)
        self.init(size: view.bounds.size)
        addRepresentation(bitmapImageRep!)
    }
    
    func stretchableImage(size size: NSSize, sideCapWidth: CGFloat) -> NSImage {
        return NSImage(size: size) {
            let imageSize = self.size
            let leftPoint = NSZeroPoint
            let rightPoint = NSMakePoint(size.width - imageSize.width, 0)
            let fillRect = NSMakeRect(sideCapWidth, CGFloat(0), size.width - sideCapWidth * 2, size.height)
            drawAtPoint(leftPoint, fromRect: .zero, operation: .CompositeSourceOver, fraction: 1.0)
            drawAtPoint(rightPoint, fromRect: .zero, operation: .CompositeSourceOver, fraction: 1.0)
            drawInRect(fillRect, fromRect: NSMakeRect(sideCapWidth, 0, imageSize.width - sideCapWidth * 2, imageSize.height), operation: .CompositeSourceOver, fraction: 1.0)
        }
    }
    
    func inset(size size: NSSize, intersectRect: NSRect, offset: NSPoint) -> NSImage {
        let imageSize = self.size
        let inRect = (intersectRect == .zero) ? NSRect(size: imageSize) : intersectRect
        var translate = NSZeroPoint
        var flippedPoint = NSZeroPoint
        var resizedSize = NSZeroSize
        var perSize = NSZeroSize
        var offsetSize = NSZeroSize
        var per: CGFloat!
        
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
        return NSImage(size: size) {
            let transform = NSAffineTransform()
            transform.scaleBy(per)
            transform.translateXBy(translate.x, yBy: translate.y)
            transform.concat()
            drawAtPoint(.zero, fromRect: .zero, operation: .CompositeSourceOver, fraction: 1.0)
        }
    }
    
    convenience init(size: NSSize, colorLabel: String) {
        self.init(size: size) {
            if let color = NSColor(labelColorName: colorLabel) {
                color.set()
                NSRectFill(NSRect(size: size))
            } else {
                NSColor.grayColor().set()
                NSFrameRect(NSRect(size: size))
            }
        }
    }
    
    convenience init?(CGImage srcImage: CGImageRef) {
        self.init()
        let imageRep: NSBitmapImageRep? = NSBitmapImageRep(CGImage: srcImage)
        if imageRep != nil {
            addRepresentation(imageRep!)
        } else {
            return nil
        }
    }
    
    var CGImage: CGImageRef? {
        return bitmapImageRep?.CGImage
    }
    
    var bitmapImageRep: NSBitmapImageRep? {
        //let imageRep = bestRepresentationForDevice(nil)
        let imageRep = bestRepresentationForRect(NSRect(size: size), context: nil, hints: [:])
        if let imageRep = imageRep as? NSBitmapImageRep {
            return imageRep
        }
        return TIFFRepresentation !! {NSBitmapImageRep(data: $0)}
    }
    
    func drawInRect(rect: NSRect, operation op: NSCompositingOperation, fraction requestedAlpha: CGFloat, respectFlipped: Bool) {
        drawInRect(rect, fromRect: .zero, operation: op, fraction: requestedAlpha, respectFlipped: respectFlipped, hints: [:])
    }
    
    convenience init(size: NSSize, @noescape withFocus block: () -> Void) {
        self.init(size: size)
        withFocus(block)
    }
    
    func withFocus(@noescape block: () -> Void) {
        lockFocus()
        block()
        unlockFocus()
    }
}