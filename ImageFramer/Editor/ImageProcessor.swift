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

    func addFrame(widthPercentage: UInt, to image: UIImage, completion: @escaping ((UIImage?) -> Void)) {
        DispatchQueue.global().async {
            let maxSide = max(image.size.width, image.size.height)
            let frameWidth = maxSide * CGFloat(widthPercentage) / 100.0

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

            let horizontalFrameWidth = (maxSide - imageSize.width) / 2.0
            let verticalFrameWidth = (maxSide - imageSize.height) / 2.0

            let imageOrigin = CGPoint(x: CGFloat(horizontalFrameWidth), y: CGFloat(verticalFrameWidth))

            UIGraphicsBeginImageContextWithOptions(targetSize, true, image.scale)
            UIColor.white.setFill()
            UIGraphicsGetCurrentContext()?.fill(CGRect(origin: .zero, size: targetSize))
            image.draw(in: CGRect(origin: imageOrigin, size: imageSize))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            DispatchQueue.main.async {
                completion(newImage)
            }
        }
    }
}
