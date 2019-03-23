//
//  PhotoLibrary.swift
//  ImageFramer
//
//  Created by Dani on 20/03/2019.
//  Copyright © 2019 icecoffin. All rights reserved.
//

import Foundation
import Photos

final class PhotoLibrary {
    private lazy var imageManager = PHImageManager.default()
    private lazy var cachingImageManager = PHCachingImageManager()

    private var assets: [PHAsset] = []
    private var activeRequests: [Int: PHImageRequestID] = [:]

    var onDidChangeAuthorizationStatus: ((PHAuthorizationStatus) -> Void)?
    var onDidUpdateImages: (() -> Void)?

    var numberOfImages: Int {
        return assets.count
    }

    func setup() {
        requestAuthorization()
    }

    func requestImages() {
        fetchAssets()
        startCachingAssets()
        onDidUpdateImages?()
    }

    private func requestAuthorization() {
        let status = PHPhotoLibrary.authorizationStatus()

        onDidChangeAuthorizationStatus?(status)

        guard status != .authorized else {
            return
        }

        PHPhotoLibrary.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                self?.onDidChangeAuthorizationStatus?(status)
            }
        }
    }

    private func fetchAssets() {
        let options = PHFetchOptions()
        let sortOrder = NSSortDescriptor(key: "creationDate", ascending: false)
        options.sortDescriptors = [sortOrder]
        let fetchedAssets = PHAsset.fetchAssets(with: .image, options: options)
        fetchedAssets.enumerateObjects { asset, _, _ in
            self.assets.append(asset)
        }
    }

    private func startCachingAssets() {
        cachingImageManager.startCachingImages(for: assets,
                                               targetSize: PHImageManagerMaximumSize,
                                               contentMode: .aspectFit,
                                               options: nil)
    }

    func requestThumbnail(at index: Int, targetSize: CGSize, completion: @escaping ((UIImage?) -> Void)) {
        let asset = assets[index]

        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat

        if let requestID = activeRequests[index] {
            imageManager.cancelImageRequest(requestID)
        }

        let requestID = imageManager.requestImage(for: asset,
                                                  targetSize: targetSize,
                                                  contentMode: .aspectFill,
                                                  options: options,
                                                  resultHandler: { image, _ in
                                                    completion(image)
        })

        activeRequests[index] = requestID
    }

    func requestFullImage(at index: Int, completion: @escaping ((UIImage?) -> Void)) {
        let asset = assets[index]

        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.resizeMode = .exact
        options.deliveryMode = .highQualityFormat

        imageManager.requestImage(for: asset,
                                  targetSize: PHImageManagerMaximumSize,
                                  contentMode: .default,
                                  options: options) { image, _ in
                                    completion(image)
        }
    }
}
