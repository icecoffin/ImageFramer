//
//  ValueSliderViewModelTests.swift
//  ImageFramerTests
//
//  Created by Dani on 18/03/2019.
//  Copyright © 2019 icecoffin. All rights reserved.
//

import XCTest
import Nimble
@testable import ImageFramer

class ValueSliderViewModelTests: XCTestCase {
    func test_normalize_returnsMinValue_forNegativeSliderValue() {
        let viewModel = ValueSliderViewModel(minValue: 0, maxValue: 100)

        expect(viewModel.normalize(sliderValue: -1)) == 0
    }

    func test_normalize_returnsMaxValue_forSliderValueGreaterThanOne() {
        let viewModel = ValueSliderViewModel(minValue: 0, maxValue: 100)

        expect(viewModel.normalize(sliderValue: 2)) == 100
    }

    func test_normalize_returnsMinAndMaxValues_forBoundaries() {
        let viewModel = ValueSliderViewModel(minValue: 10, maxValue: 110)

        expect(viewModel.normalize(sliderValue: 0)) == 10
        expect(viewModel.normalize(sliderValue: 1)) == 110
    }

    func test_normalize_performsRounding_whenNeeded() {
        let viewModel = ValueSliderViewModel(minValue: 50, maxValue: 100)

        expect(viewModel.normalize(sliderValue: 0.22)) == 61
        expect(viewModel.normalize(sliderValue: 0.23)) == 61
        expect(viewModel.normalize(sliderValue: 0.24)) == 62
    }

    func test_normalize_returnsCorrectValues_whenRoundingIsNotNeeded() {
        let viewModel = ValueSliderViewModel(minValue: 50, maxValue: 100)

        expect(viewModel.normalize(sliderValue: 0.5)) == 75
        expect(viewModel.normalize(sliderValue: 0.6)) == 80
    }
}
