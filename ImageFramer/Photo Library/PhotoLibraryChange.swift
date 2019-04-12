//
//  PhotoLibraryChange.swift
//  ImageFramer
//
//  Created by Dani on 11/04/2019.
//  Copyright © 2019 icecoffin. All rights reserved.
//

import Foundation
import Photos

final class PhotoLibraryChange {
    let isIncremental: Bool

    let removedIndexPaths: [IndexPath]
    let insertedIndexPaths: [IndexPath]
    let changedIndexPaths: [IndexPath]

    let moves: [(IndexPath, IndexPath)]

    init(changeDetails: PHFetchResultChangeDetails<PHAsset>) {
        self.isIncremental = changeDetails.hasIncrementalChanges

        self.removedIndexPaths = changeDetails.removedIndexes?.indexPathsFromIndexesWithSection(section: 0) ?? []
        self.insertedIndexPaths = changeDetails.insertedIndexes?.indexPathsFromIndexesWithSection(section: 0) ?? []
        self.changedIndexPaths = changeDetails.changedIndexes?.indexPathsFromIndexesWithSection(section: 0) ?? []

        var moves = [(IndexPath, IndexPath)]()
        changeDetails.enumerateMoves { fromIndex, toIndex in
            moves.append((IndexPath(item: fromIndex, section: 0), IndexPath(item: toIndex, section: 0)))
        }
        self.moves = moves
    }
}

private extension IndexSet {
    func indexPathsFromIndexesWithSection(section: Int) -> [IndexPath] {
        return self.map { return IndexPath(item: $0, section: section) }
    }
}
