//
//  FetchResultChangeDetails.swift
//  ImageFramer
//
//  Created by Dani on 12/04/2019.
//  Copyright © 2019 icecoffin. All rights reserved.
//

import Foundation
import Photos

protocol FetchResultChangeDetails {
    var hasIncrementalChanges: Bool { get }
    var removedIndexes: IndexSet? { get }
    var insertedIndexes: IndexSet? { get }
    var changedIndexes: IndexSet? { get }

    func enumerateMoves(_ handler: @escaping (Int, Int) -> Void)
}

extension PHFetchResultChangeDetails: FetchResultChangeDetails { }
