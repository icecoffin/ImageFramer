//
//  FrameWidthCalculating.swift
//  ImageFramer
//
//  Created by Dani on 24/03/2019.
//  Copyright © 2019 icecoffin. All rights reserved.
//

import UIKit

protocol FrameWidthCalculating {
    func frameWidth(forFrameSize frameSize: UInt, imageMaxSide: CGFloat) -> CGFloat
}

final class PercentageFrameWidthCalculator: FrameWidthCalculating {
    func frameWidth(forFrameSize frameSize: UInt, imageMaxSide: CGFloat) -> CGFloat {
        return round(imageMaxSide * CGFloat(frameSize) / 100.0)
    }
}

final class FixedFrameWidthCalculator: FrameWidthCalculating {
    func frameWidth(forFrameSize frameSize: UInt, imageMaxSide: CGFloat) -> CGFloat {
        return round(imageMaxSide * CGFloat(frameSize) * 0.0053)
    }
}

final class FrameWidthCalculatorFactory {
    class func makeFrameWidthCalculator() -> FrameWidthCalculating {
        return FixedFrameWidthCalculator()
    }
}
