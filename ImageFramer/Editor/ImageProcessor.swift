//
//  ImageFramer.swift
//  ImageFramer
//
//  Created by Dani on 18/03/2019.
//  Copyright © 2019 icecoffin. All rights reserved.
//

import UIKit
import CoreGraphics

final class ImageProcessor {
    private let frameWidthCalculator: FrameWidthCalculator

    init(frameWidthCalculator: FrameWidthCalculator = FrameWidthCalculatorFactory.makeFrameWidthCalculator()) {
        self.frameWidthCalculator = frameWidthCalculator
    }

    func resizeImage(_ image: UIImage, to targetSize: CGSize) -> UIImage? {
        let widthRatio = targetSize.width / image.size.width
        let heightRatio = targetSize.height / image.size.height

        let newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: round(image.size.width * heightRatio),
                             height: round(image.size.height * heightRatio))
        } else {
            newSize = CGSize(width: round(image.size.width * widthRatio),
                             height: round(image.size.height * widthRatio))
        }

        UIGraphicsBeginImageContextWithOptions(newSize, true, 0.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }

    func addFrame(withSize frameSize: UInt, to image: UIImage, completion: @escaping ((UIImage?) -> Void)) {
        let maxSide = max(image.size.width, image.size.height)
        let frameWidth = self.frameWidthCalculator.frameWidth(forFrameSize: frameSize, imageMaxSide: maxSide)

        let widthToHeightRatio = image.size.width / image.size.height
        let imageSize: CGSize
        if widthToHeightRatio > 1 {
            // Landscape image
            let newWidth = image.size.width - frameWidth * 2
            imageSize = CGSize(width: newWidth, height: newWidth / widthToHeightRatio)
        } else {
            // Portrait or square image
            let newHeight = image.size.height - frameWidth * 2
            imageSize = CGSize(width: newHeight * widthToHeightRatio, height: newHeight)
        }

        let targetSize = CGSize(width: maxSide, height: maxSide)
        let targetRect = CGRect(origin: .zero, size: targetSize)

        DispatchQueue.global().async {
            let format = UIGraphicsImageRendererFormat()
            format.scale = image.scale

            let renderer = UIGraphicsImageRenderer(bounds: targetRect, format: format)

            let image = renderer.image { context in
                UIColor.white.setFill()
                context.fill(targetRect)

                let horizontalFrameWidth = (maxSide - imageSize.width) / 2.0
                let verticalFrameWidth = (maxSide - imageSize.height) / 2.0
                let imageOrigin = CGPoint(x: CGFloat(horizontalFrameWidth), y: CGFloat(verticalFrameWidth))

                image.draw(in: CGRect(origin: imageOrigin, size: imageSize))
            }

            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
}
