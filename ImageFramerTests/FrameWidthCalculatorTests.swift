//
//  FrameWidthCalculatorTests.swift
//  ImageFramerTests
//
//  Created by Dani on 12/04/2019.
//  Copyright © 2019 icecoffin. All rights reserved.
//

import XCTest
import Nimble
@testable import ImageFramer

class FrameWidthCalculatorTests: XCTestCase {
    func test_percentageFrameWidthCalculator_frameWidth_returnsCorrectValue() {
        let calculator = PercentageFrameWidthCalculator()

        let frameWidth1 = calculator.frameWidth(forFrameSize: 10, imageMaxSide: 1024)
        expect(frameWidth1) == 102

        let frameWidth2 = calculator.frameWidth(forFrameSize: 10, imageMaxSide: 1026)
        expect(frameWidth2) == 103
    }

    func test_fixedFrameWidthCalculator_frameWidth_returnsCorrectValue() {
        let calculator = FixedFrameWidthCalculator()

        let frameWidth1 = calculator.frameWidth(forFrameSize: 10, imageMaxSide: 1024)
        expect(frameWidth1) == 54

        let frameWidth2 = calculator.frameWidth(forFrameSize: 10, imageMaxSide: 1030)
        expect(frameWidth2) == 55
    }

    func test_frameWidthCalculatorFactory_makeFrameWidthCalculator_returnsCorrectInstance() {
        let calculator = FrameWidthCalculatorFactory.makeFrameWidthCalculator()
        expect(calculator).to(beAnInstanceOf(FixedFrameWidthCalculator.self))
    }
}
