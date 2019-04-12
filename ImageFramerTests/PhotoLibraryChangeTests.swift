//
//  PhotoLibraryChangeTests.swift
//  ImageFramerTests
//
//  Created by Dani on 12/04/2019.
//  Copyright © 2019 icecoffin. All rights reserved.
//

import XCTest
import Nimble
@testable import ImageFramer

private class MockFetchResultChangeDetails: FetchResultChangeDetails {
    var hasIncrementalChanges = false

    var removedIndexes: IndexSet?
    var insertedIndexes: IndexSet?
    var changedIndexes: IndexSet?

    var moveIndexProvider: (() -> (Int, Int))?
    func enumerateMoves(_ handler: @escaping (Int, Int) -> Void) {
        if let moveIndexProvider = moveIndexProvider {
            let (fromIndex, toIndex) = moveIndexProvider()
            handler(fromIndex, toIndex)
        }
    }
}

class PhotoLibraryChangeTests: XCTestCase {
    fileprivate var changeDetails: MockFetchResultChangeDetails!

    override func setUp() {
        super.setUp()

        changeDetails = MockFetchResultChangeDetails()
    }

    func test_initWithChangeDetails_setsCorrectPropertyValues() {
        changeDetails.hasIncrementalChanges = true

        changeDetails.removedIndexes = IndexSet(integersIn: 3..<6)
        changeDetails.insertedIndexes = IndexSet(integersIn: 1..<3)
        changeDetails.changedIndexes = IndexSet(integer: 0)

        changeDetails.moveIndexProvider = { return (7, 8) }

        let photoLibraryChange = PhotoLibraryChange(changeDetails: changeDetails)

        expect(photoLibraryChange.isIncremental) == true

        expect(photoLibraryChange.removedIndexPaths) == [IndexPath(item: 3, section: 0),
                                                         IndexPath(item: 4, section: 0),
                                                         IndexPath(item: 5, section: 0)]
        expect(photoLibraryChange.insertedIndexPaths) == [IndexPath(item: 1, section: 0),
                                                         IndexPath(item: 2, section: 0)]
        expect(photoLibraryChange.changedIndexPaths) == [IndexPath(item: 0, section: 0)]

        expect(photoLibraryChange.moves.count) == 1
        expect(photoLibraryChange.moves.first?.0) == IndexPath(item: 7, section: 0)
        expect(photoLibraryChange.moves.first?.1) == IndexPath(item: 8, section: 0)
    }

    func test_initWithChangeDetails_setsEmptyArraysForMissingIndexesProperties() {
        let photoLibraryChange = PhotoLibraryChange(changeDetails: changeDetails)

        expect(photoLibraryChange.removedIndexPaths).to(beEmpty())
        expect(photoLibraryChange.insertedIndexPaths).to(beEmpty())
        expect(photoLibraryChange.changedIndexPaths).to(beEmpty())
    }
}
