//
//  ImageTransformer.swift
//  Longinus
//
//  Created by Qitao Yang on 2020/5/13.
//
//  Copyright (c) 2020 KittenYang <kittenyang@icloud.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
    

import CoreImage

public typealias ImageTransformMethod = (UIImage) -> UIImage?
private var shareCIContext: CIContext?

public var lg_shareCIContext: CIContext {
    var localContext = shareCIContext
    if localContext == nil {
        if #available(iOS 9.0, *) {
            localContext = CIContext(options: [CIContextOption.workingColorSpace : lg_shareColorSpace])
        } else {
            // CIContext.init(options:) will crash in iOS 8. So use other init
            localContext = CIContext(eaglContext: EAGLContext(api: .openGLES2)!, options: [CIContextOption.workingColorSpace : lg_shareColorSpace])
        }
        shareCIContext = localContext
    }
    return localContext!
}

public func lg_clearCIContext() { shareCIContext = nil }

public struct ImageTransformer {
    public var key: String
    public var transform: ImageTransformMethod
    
    /// Creates a ImageTransformer variable
    ///
    /// - Parameters:
    ///   - key: identification of transformer
    ///   - transform: an transform image closure
    public init(key: String, transform: @escaping ImageTransformMethod) {
        self.key = key
        self.transform = transform
    }

}

// MARK: ImageTransformer Extension Methods
extension ImageTransformer: LonginusCompatible {}
extension LonginusExtension where Base == ImageTransformer {
    static func imageTransformerCrop(with rect: CGRect)  -> ImageTransformer {
        let transform: ImageTransformMethod = { (image) in
            if let currentImage = image.lg.croppedImage(with: rect) { return currentImage }
            return image
        }
        return ImageTransformer(key: "\(LonginusPrefixID).crop.rect=\(rect)", transform: transform)
    }
    
    static public func imageTransformerResize(with size: CGSize) -> ImageTransformer {
        let transform: ImageTransformMethod = { (image) in
            if let currentImage = image.lg.resizedImage(with: size) { return currentImage }
            return image
        }
        return ImageTransformer(key: "\(LonginusPrefixID).resize.size=\(size)", transform: transform)
    }
    
    static public func imageTransformerResize(with displaySize: CGSize, contentMode: UIView.ContentMode) -> ImageTransformer {
        let transform: ImageTransformMethod = { (image) in
            if let currentImage = image.lg.resizedImage(with: displaySize, contentMode: contentMode) { return currentImage }
            return image
        }
        return ImageTransformer(key: "\(LonginusPrefixID).resize.size=\(displaySize),contentMode=\(contentMode.rawValue)", transform: transform)
    }
    
    static public func imageTransformerResize(with displaySize: CGSize, fillContentMode: LonginusExtension<UIView>.FillContentMode) -> ImageTransformer {
        let transform: ImageTransformMethod = { (image) in
            if let currentImage = image.lg.resizedImage(with: displaySize, fillContentMode: fillContentMode) { return currentImage }
            return image
        }
        return ImageTransformer(key: "\(LonginusPrefixID).resize.size=\(displaySize),fillContentMode=\(fillContentMode)", transform: transform)
    }
    
    static public func imageTransformerRotate(withAngle angle: CGFloat, fitSize: Bool) -> ImageTransformer {
        let transform: ImageTransformMethod = { (image) in
            if let currentImage = image.lg.rotatedImage(withAngle: angle, fitSize: fitSize) { return currentImage }
            return image
        }
        return ImageTransformer(key: "\(LonginusPrefixID).rotate.angle=\(angle),fitSize=\(fitSize)", transform: transform)
    }
    
    static public func imageTransformerFlip(withHorizontal horizontal: Bool, vertical: Bool) -> ImageTransformer {
        let transform: ImageTransformMethod = { (image) in
            if let currentImage = image.lg.flippedImage(withHorizontal: horizontal, vertical: vertical) { return currentImage }
            return image
        }
        return ImageTransformer(key: "\(LonginusPrefixID).flip.horizontal=\(horizontal),vertical=\(vertical)", transform: transform)
    }

    static public func imageTransformerTint(with color: UIColor, blendMode: CGBlendMode = .normal) -> ImageTransformer {
        let transform: ImageTransformMethod = { (image) in
            if let currentImage = image.lg.tintedImage(with: color, blendMode: blendMode) { return currentImage }
            return image
        }
        return ImageTransformer(key: "\(LonginusPrefixID).tint.color=\(color),blendMode=\(blendMode.rawValue)", transform: transform)
    }
    
    static public func imageTransformerGradientlyTint(with colors: [UIColor],
                                             locations: [CGFloat],
                                             start: CGPoint = CGPoint(x: 0.5, y: 0),
                                             end: CGPoint = CGPoint(x: 0.5, y: 1),
                                             blendMode: CGBlendMode = .normal) -> ImageTransformer {
        let transform: ImageTransformMethod = { (image) in
            if let currentImage = image.lg.gradientlyTintedImage(with: colors,
                                                                 locations: locations,
                                                                 start: start,
                                                                 end: end,
                                                                 blendMode: blendMode) {
                return currentImage
            }
            return image
        }
        return ImageTransformer(key: "\(LonginusPrefixID).gradientlyTint.colors=\(colors),locations=\(locations),start=\(start),end=\(end),blendMode=\(blendMode.rawValue)", transform: transform)
    }
    
    static public func imageTransformerOverlay(with overlayImage: UIImage, blendMode: CGBlendMode = .normal, alpha: CGFloat) -> ImageTransformer {
        let transform: ImageTransformMethod = { (image) in
            if let currentImage = image.lg.overlaidImage(with: overlayImage, blendMode: blendMode, alpha: alpha) { return currentImage }
            return image
        }
        return ImageTransformer(key: "\(LonginusPrefixID).overlay.image=\(overlayImage),blendMode=\(blendMode.rawValue),alpha=\(alpha)", transform: transform)
    }
    
    static public func imageTransformerCommon(with displaySize: CGSize,
                                         fillContentMode:LonginusExtension<UIView>.FillContentMode = .center,
                                         maxResolution: Int = 0,
                                         corner: UIRectCorner = UIRectCorner(rawValue: 0),
                                         cornerRadius: CGFloat = 0,
                                         borderWidth: CGFloat = 0,
                                         borderColor: UIColor? = nil,
                                         backgroundColor: UIColor? = nil) -> ImageTransformer {
        let transform: ImageTransformMethod = { (image) in
            if let currentImage = image.lg.commonEditedImage(with: displaySize,
                                                             fillContentMode: fillContentMode,
                                                             maxResolution: maxResolution,
                                                             corner: corner,
                                                             cornerRadius: cornerRadius,
                                                             borderWidth: borderWidth,
                                                             borderColor: borderColor,
                                                             backgroundColor: backgroundColor) {
                return currentImage
            }
            return image
        }
        let key = "\(LonginusPrefixID).common.displaySize=\(displaySize),fillContentMode=\(fillContentMode),maxResolution=\(maxResolution),corner=\(corner),cornerRadius=\(cornerRadius),borderWidth=\(borderWidth),borderColor=\(borderColor?.description ?? "nil"),backgroundColor=\(backgroundColor?.description ?? "nil")"
        return ImageTransformer(key: key, transform: transform)
    }

}

// MARK: UIImage Extension Methods
extension LonginusExtension where Base: UIImage {
    func croppedImage(with originalRect: CGRect) -> UIImage? {
        if originalRect.width <= 0 || originalRect.height <= 0 { return nil }
        var rect = originalRect
        if scale != 1 {
            rect.origin.x *= scale
            rect.origin.y *= scale
            rect.size.width *= scale
            rect.size.height *= scale
        }
        return base.lg._croppedImage(with: rect)
    }
    
    func resizedImage(with size: CGSize) -> UIImage? {
        if size.width <= 0 || size.height <= 0 { return nil }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        base.draw(in: CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func resizedImage(with displaySize: CGSize, contentMode: UIView.ContentMode) -> UIImage? {
        if displaySize.width <= 0 || displaySize.height <= 0 { return nil }
        let rect = rectToDisplay(with: displaySize, contentMode: contentMode)
        return base.lg._croppedImage(with: rect)
    }
    
    func resizedImage(with displaySize: CGSize, fillContentMode: LonginusExtension<UIView>.FillContentMode) -> UIImage? {
        if displaySize.width <= 0 || displaySize.height <= 0 { return nil }
        let rect = rectToDisplay(with: displaySize, fillContentMode: fillContentMode)
        return base.lg._croppedImage(with: rect)
    }
    
    func rotatedImage(withAngle angle: CGFloat, fitSize: Bool) -> UIImage? {
        if angle.truncatingRemainder(dividingBy: 360) == 0 { return base }
        let radian = angle / 180 * CGFloat.pi
        var rect = CGRect(origin: .zero, size: size)
        if fitSize { rect = rect.applying(CGAffineTransform(rotationAngle: radian)) }
        UIGraphicsBeginImageContextWithOptions(rect.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        context.translateBy(x: rect.width / 2, y: rect.height / 2)
        context.rotate(by: radian)
        context.translateBy(x: -size.width / 2, y: -size.height / 2)
        base.draw(at: .zero)
        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return rotatedImage
    }
    
    func flippedImage(withHorizontal horizontal: Bool, vertical: Bool) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        if horizontal {
            context.translateBy(x: size.width, y: 0)
            context.scaleBy(x: -1, y: 1)
        }
        if vertical {
            context.translateBy(x: 0, y: size.height)
            context.scaleBy(x: 1, y: -1)
        }
        base.draw(at: .zero)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func tintedImage(with color: UIColor, blendMode: CGBlendMode = .normal) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        base.draw(at: .zero)
        color.setFill()
        UIRectFillUsingBlendMode(CGRect(origin: .zero, size: size), blendMode)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func gradientlyTintedImage(with colors: [UIColor],
                               locations: [CGFloat],
                               start: CGPoint = CGPoint(x: 0.5, y: 0),
                               end: CGPoint = CGPoint(x: 0.5, y: 1),
                               blendMode: CGBlendMode = .normal) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        base.draw(at: .zero)
        guard let context = UIGraphicsGetCurrentContext(),
            let gradient = CGGradient(colorsSpace: lg_shareColorSpace,
                                      colors: colors.map { $0.cgColor } as CFArray,
                                      locations: locations) else
        {
            UIGraphicsEndImageContext()
            return nil
        }
        context.setBlendMode(blendMode)
        let startLoc = CGPoint(x: start.x * size.width, y: start.y * size.height)
        let endLoc = CGPoint(x: end.x * size.width, y: end.y * size.height)
        context.drawLinearGradient(gradient,
                                   start: startLoc,
                                   end: endLoc,
                                   options: CGGradientDrawingOptions(rawValue: 0))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func overlaidImage(with overlayImage: UIImage, blendMode: CGBlendMode = .normal, alpha: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        base.draw(at: .zero)
        overlayImage.draw(in: CGRect(origin: .zero, size: size), blendMode: blendMode, alpha: alpha)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func commonEditedImage(with displaySize: CGSize,
                           fillContentMode: LonginusExtension<UIView>.FillContentMode = .center,
                           maxResolution: Int = 0,
                           corner: UIRectCorner = UIRectCorner(rawValue: 0),
                           cornerRadius: CGFloat = 0,
                           borderWidth: CGFloat = 0,
                           borderColor: UIColor? = nil,
                           backgroundColor: UIColor? = nil) -> UIImage? {
        return autoreleasepool { () -> UIImage? in
            guard displaySize.width > 0,
                displaySize.height > 0,
                let sourceImage = cgImage?.cropping(to: rectToDisplay(with: displaySize, fillContentMode: fillContentMode)) else { return nil }
            var bitmapInfo = sourceImage.bitmapInfo
            bitmapInfo.remove(.alphaInfoMask)
            if sourceImage.lg.containsAlpha {
                bitmapInfo = CGBitmapInfo(rawValue: bitmapInfo.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)
            } else {
                bitmapInfo = CGBitmapInfo(rawValue: bitmapInfo.rawValue | CGImageAlphaInfo.noneSkipFirst.rawValue)
            }
            // Make sure resolution is not too small
            let currentMaxResolution = max(maxResolution, Int(displaySize.width * displaySize.height * 7))
            let resolutionRatio = sqrt(CGFloat(sourceImage.width * sourceImage.height) / CGFloat(currentMaxResolution))
            let shouldScaleDown = maxResolution > 0 && resolutionRatio > 1
            var width = sourceImage.width
            var height = sourceImage.height
            if shouldScaleDown {
                width = Int(CGFloat(sourceImage.width) / resolutionRatio)
                height = Int(CGFloat(sourceImage.height) / resolutionRatio)
            } else if CGFloat(width) < displaySize.width * lg_ScreenScale {
                width = Int(displaySize.width * lg_ScreenScale)
                height = Int(displaySize.height * lg_ScreenScale)
            }
            guard let context = CGContext(data: nil,
                                          width: width,
                                          height: height,
                                          bitsPerComponent: sourceImage.bitsPerComponent,
                                          bytesPerRow: 0,
                                          space: lg_shareColorSpace,
                                          bitmapInfo: bitmapInfo.rawValue) else { return nil }
            context.scaleBy(x: 1, y: -1)
            context.translateBy(x: 0, y: CGFloat(-height))
            context.interpolationQuality = .high
            context.saveGState()
            
            let ratio = CGFloat(width) / displaySize.width
            let currentCornerRadius = cornerRadius * ratio
            let currentBorderWidth = borderWidth * ratio
            
            if let fillColor = backgroundColor?.cgColor {
                context.setFillColor(fillColor)
                context.fill(CGRect(x: 0, y: 0, width: width, height: height))
            }
            if cornerRadius > 0 && corner.isSubset(of: .allCorners) && !corner.isEmpty {
                let clipPath = borderPath(with: CGSize(width: width, height: height), corner: corner, cornerRadius: currentCornerRadius, borderWidth: currentBorderWidth)
                context.addPath(clipPath.cgPath)
                context.clip()
            }
            context.scaleBy(x: 1, y: -1)
            context.translateBy(x: 0, y: CGFloat(-height))
            if shouldScaleDown {
                drawForScaleDown(context, sourceImage: sourceImage)
            } else {
                context.draw(sourceImage, in: CGRect(x: 0, y: 0, width: width, height: height))
            }
            context.restoreGState()
            if let strokeColor = borderColor?.cgColor,
                borderWidth > 0 {
                let strokePath = borderPath(with: CGSize(width: width, height: height), corner: corner, cornerRadius: currentCornerRadius, borderWidth: currentBorderWidth)
                context.addPath(strokePath.cgPath)
                context.setLineWidth(currentBorderWidth)
                context.setStrokeColor(strokeColor)
                context.strokePath()
            }
            return context.makeImage().flatMap { UIImage(cgImage: $0) }
        }
    }
    
}

// MARK: private methods
extension LonginusExtension where Base: UIImage {
    private func _croppedImage(with rect: CGRect) -> UIImage? {
        if let sourceImage = cgImage?.cropping(to: rect) {
            return UIImage(cgImage: sourceImage, scale: scale, orientation: base.imageOrientation)
        }
        if let ciimage = base.ciImage?.cropped(to: rect),
            let sourceImage = lg_shareCIContext.createCGImage(ciimage, from: ciimage.extent) {
            return UIImage(cgImage: sourceImage, scale: scale, orientation: base.imageOrientation)
        }
        return nil
    }
    
    private func rectToDisplay(with displaySize: CGSize, contentMode: UIView.ContentMode) -> CGRect {
        var rect = CGRect(origin: .zero, size: size)
        switch contentMode {
        case .scaleAspectFill:
            let sourceRatio = size.width / size.height
            let displayRatio = displaySize.width / displaySize.height
            if sourceRatio < displayRatio {
                rect.size.height = size.width / displayRatio
                rect.origin.y = (size.height - rect.height) / 2
            } else {
                rect.size.width = size.height * displayRatio
                rect.origin.x = (size.width - rect.width) / 2
            }
        case .center:
            if size.width > displaySize.width {
                rect.origin.x = (size.width - displaySize.width) / 2
                rect.size.width = displaySize.width
            }
            if size.height > displaySize.height {
                rect.origin.y = (size.height - displaySize.height) / 2
                rect.size.height = displaySize.height
            }
        case .top:
            if size.width > displaySize.width {
                rect.origin.x = (size.width - displaySize.width) / 2
                rect.size.width = displaySize.width
            }
            if size.height > displaySize.height {
                rect.size.height = displaySize.height
            }
        case .bottom:
            if size.width > displaySize.width {
                rect.origin.x = (size.width - displaySize.width) / 2
                rect.size.width = displaySize.width
            }
            if size.height > displaySize.height {
                rect.origin.y = size.height - displaySize.height
                rect.size.height = displaySize.height
            }
        case .left:
            if size.height > displaySize.height {
                rect.origin.y = (size.height - displaySize.height) / 2
                rect.size.height = displaySize.height
            }
            if size.width > displaySize.width {
                rect.size.width = displaySize.width
            }
        case .right:
            if size.height > displaySize.height {
                rect.origin.y = (size.height - displaySize.height) / 2
                rect.size.height = displaySize.height
            }
            if size.width > displaySize.width {
                rect.origin.x = size.width - displaySize.width
                rect.size.width = displaySize.width
            }
        case .topLeft:
            if size.width > displaySize.width {
                rect.size.width = displaySize.width
            }
            if size.height > displaySize.height {
                rect.size.height = displaySize.height
            }
        case .topRight:
            if size.width > displaySize.width {
                rect.origin.x = size.width - displaySize.width
                rect.size.width = displaySize.width
            }
            if size.height > displaySize.height {
                rect.size.height = displaySize.height
            }
        case .bottomLeft:
            if size.width > displaySize.width {
                rect.size.width = displaySize.width
            }
            if size.height > displaySize.height {
                rect.origin.y = size.height - displaySize.height
                rect.size.height = displaySize.height
            }
        case .bottomRight:
            if size.width > displaySize.width {
                rect.origin.x = size.width - displaySize.width
                rect.size.width = displaySize.width
            }
            if size.height > displaySize.height {
                rect.origin.y = size.height - displaySize.height
                rect.size.height = displaySize.height
            }
        default:
            break
        }
        if scale != 1 {
            rect.origin.x *= scale
            rect.origin.y *= scale
            rect.size.width *= scale
            rect.size.height *= scale
        }
        return rect
    }
    
    private func rectToDisplay(with displaySize: CGSize, fillContentMode: LonginusExtension<UIView>.FillContentMode) -> CGRect {
        var rect = CGRect(origin: .zero, size: size)
        let sourceRatio = size.width / size.height
        let displayRatio = displaySize.width / displaySize.height
        switch fillContentMode {
        case .center:
            if sourceRatio < displayRatio {
                rect.size.height = size.width / displayRatio
                rect.origin.y = (size.height - rect.height) / 2
            } else {
                rect.size.width = size.height * displayRatio
                rect.origin.x = (size.width - rect.width) / 2
            }
        case .top:
            if sourceRatio < displayRatio {
                rect.size.height = size.width / displayRatio
            } else {
                rect.size.width = size.height * displayRatio
                rect.origin.x = (size.width - rect.width) / 2
            }
        case .bottom:
            if sourceRatio < displayRatio {
                rect.size.height = size.width / displayRatio
                rect.origin.y = size.height - rect.height
            } else {
                rect.size.width = size.height * displayRatio
                rect.origin.x = (size.width - rect.width) / 2
            }
        case .left:
            if sourceRatio < displayRatio {
                rect.size.height = size.width / displayRatio
                rect.origin.y = (size.height - rect.height) / 2
            } else {
                rect.size.width = size.height * displayRatio
            }
        case .right:
            if sourceRatio < displayRatio {
                rect.size.height = size.width / displayRatio
                rect.origin.y = (size.height - rect.height) / 2
            } else {
                rect.size.width = size.height * displayRatio
                rect.origin.x = size.width - rect.width
            }
        case .topLeft:
            if sourceRatio < displayRatio {
                rect.size.height = size.width / displayRatio
            } else {
                rect.size.width = size.height * displayRatio
            }
        case .topRight:
            if sourceRatio < displayRatio {
                rect.size.height = size.width / displayRatio
            } else {
                rect.size.width = size.height * displayRatio
                rect.origin.x = size.width - rect.width
            }
        case .bottomLeft:
            if sourceRatio < displayRatio {
                rect.size.height = size.width / displayRatio
                rect.origin.y = size.height - rect.height
            } else {
                rect.size.width = size.height * displayRatio
            }
        case .bottomRight:
            if sourceRatio < displayRatio {
                rect.size.height = size.width / displayRatio
                rect.origin.y = size.height - rect.height
            } else {
                rect.size.width = size.height * displayRatio
                rect.origin.x = size.width - rect.width
            }
        }
        if scale != 1 {
            rect.origin.x *= scale
            rect.origin.y *= scale
            rect.size.width *= scale
            rect.size.height *= scale
        }
        return rect
    }
    
    private func borderPath(with size: CGSize, corner: UIRectCorner, cornerRadius: CGFloat, borderWidth: CGFloat) -> UIBezierPath {
        let halfBorderWidth = borderWidth / 2
        let path = UIBezierPath()
        if corner.isSuperset(of: .topLeft) {
            path.move(to: CGPoint(x: halfBorderWidth, y: cornerRadius + halfBorderWidth))
            path.addArc(withCenter: CGPoint(x: cornerRadius + halfBorderWidth, y: cornerRadius + halfBorderWidth),
                        radius: cornerRadius,
                        startAngle: CGFloat.pi,
                        endAngle: CGFloat.pi * 3 / 2,
                        clockwise: true)
        } else {
            path.move(to: CGPoint(x: halfBorderWidth, y: halfBorderWidth))
        }
        if corner.isSuperset(of: .topRight) {
            path.addLine(to: CGPoint(x: size.width - cornerRadius - halfBorderWidth, y: halfBorderWidth))
            path.addArc(withCenter: CGPoint(x: size.width - cornerRadius - halfBorderWidth, y: cornerRadius + halfBorderWidth),
                        radius: cornerRadius,
                        startAngle: CGFloat.pi * 3 / 2,
                        endAngle: 0,
                        clockwise: true)
        } else {
            path.addLine(to: CGPoint(x: size.width - halfBorderWidth, y: halfBorderWidth))
        }
        if corner.isSuperset(of: .bottomRight) {
            path.addLine(to: CGPoint(x: size.width - halfBorderWidth, y: size.height - cornerRadius - halfBorderWidth))
            path.addArc(withCenter: CGPoint(x: size.width - cornerRadius - halfBorderWidth, y: size.height - cornerRadius - halfBorderWidth),
                        radius: cornerRadius,
                        startAngle: 0,
                        endAngle: CGFloat.pi / 2,
                        clockwise: true)
        } else {
            path.addLine(to: CGPoint(x: size.width - halfBorderWidth, y: size.height - halfBorderWidth))
        }
        if corner.isSuperset(of: .bottomLeft) {
            path.addLine(to: CGPoint(x: cornerRadius + halfBorderWidth, y: size.height - halfBorderWidth))
            path.addArc(withCenter: CGPoint(x: cornerRadius + halfBorderWidth, y: size.height - cornerRadius - halfBorderWidth),
                        radius: cornerRadius,
                        startAngle: CGFloat.pi / 2,
                        endAngle: CGFloat.pi,
                        clockwise: true)
        } else {
            path.addLine(to: CGPoint(x: halfBorderWidth, y: size.height - halfBorderWidth))
        }
        path.close()
        return path
    }
    
    private func drawForScaleDown(_ context: CGContext, sourceImage: CGImage) {
        let sourceImageTileSizeMB = 20
        let pixelsPerMB = 1024 * 1024 * 4
        let tileTotalPixels = sourceImageTileSizeMB * pixelsPerMB
        let imageScale = sqrt(CGFloat(context.width * context.height) / CGFloat(sourceImage.width * sourceImage.height))
        var sourceTile = CGRect(x: 0, y: 0, width: sourceImage.width, height: tileTotalPixels / sourceImage.width)
        var destTile = CGRect(x: 0, y: 0, width: CGFloat(context.width), height: ceil(sourceTile.height * imageScale))
        let destSeemOverlap: CGFloat = 2
        let sourceSeemOverlap = trunc(destSeemOverlap / imageScale)
        var iterations = Int(CGFloat(sourceImage.height) / sourceTile.height)
        let remainder = sourceImage.height % Int(sourceTile.height)
        if remainder != 0 { iterations += 1 }
        let sourceTileHeightMinusOverlap = sourceTile.height
        let destTileHeightMinusOverlap = destTile.height
        sourceTile.size.height += sourceSeemOverlap
        destTile.size.height += destSeemOverlap
        for y in 0..<iterations {
            autoreleasepool {
                sourceTile.origin.y = CGFloat(y) * sourceTileHeightMinusOverlap // + sourceSeemOverlap
                destTile.origin.y = CGFloat(context.height) - ceil(CGFloat(y + 1) * destTileHeightMinusOverlap + destSeemOverlap)
                if let sourceTileImage = sourceImage.cropping(to: sourceTile) {
                    if y == iterations - 1 && remainder != 0 {
                        var dify = destTile.height
                        destTile.size.height = ceil(CGFloat(sourceTileImage.height) * imageScale)
                        dify -= destTile.height
                        destTile.origin.y += dify
                    }
                    context.draw(sourceTileImage, in: destTile)
                }
            }
        }
    }
}