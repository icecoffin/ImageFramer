//
//  ValueSliderViewModel.swift
//  ImageFramer
//
//  Created by Dani on 18/03/2019.
//  Copyright © 2019 icecoffin. All rights reserved.
//

import Foundation

final class ValueSliderViewModel {
    // MARK: - Private properties

    private let minValue: UInt
    private let maxValue: UInt

    // MARK: - Init

    init(minValue: UInt = 0, maxValue: UInt = 30) {
        self.minValue = minValue
        self.maxValue = maxValue
    }

    // MARK: - Public methods

    func normalize(sliderValue: Float) -> UInt {
        guard sliderValue > 0 else { return minValue }

        return minValue + UInt(round(Float(maxValue - minValue)) * min(1, sliderValue))
    }
}
