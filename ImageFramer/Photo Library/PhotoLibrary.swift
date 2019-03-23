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
    // MARK: - Private properties

    private lazy var imageManager = PHImageManager.default()
    private lazy var cachingImageManager = PHCachingImageManager()

    private var assets: [PHAsset] = []
    private var activeRequests: [Int: PHImageRequestID] = [:]
    private var fullImageRequestID: PHImageRequestID?
    private var progressTimer: Timer?

    // MARK: - Public properties

    var onDidChangeAuthorizationStatus: ((PHAuthorizationStatus) -> Void)?
    var onDidUpdateImages: (() -> Void)?
    var onDidUpdateImageDownloadingProgress: ((Double) -> Void)?
    var onDidReceiveError: ((Error) -> Void)?

    var numberOfImages: Int {
        return assets.count
    }

    // MARK: - Init

    deinit {
        stopProgressTimer()
        onDidUpdateImageDownloadingProgress?(1)

        activeRequests.forEach { _, imageRequestID in
            imageManager.cancelImageRequest(imageRequestID)
        }

        if let fullImageRequestID = fullImageRequestID {
            imageManager.cancelImageRequest(fullImageRequestID)
        }
    }

    // MARK: - Private methods

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

    // Since PHImageRequestOptions.progressHandler doesn't notify for progress = 0, we'll use a hacky way to ensure
    // that the progress HUD is shown right after selecting an iCloud asset (or, actually, with a small delay).
    // We start a timer after picking an image and stop it if the image is delivered instantly (meaning it was not in iCloud).
    // Otherwise, if the image is not delivered within 0.05 seconds, we assume that it's in iCloud and show a HUD
    // with progress = 0.
    private func startProgressTimer() {
        progressTimer = Timer(timeInterval: 0.05, repeats: false) { [weak self] _ in
            self?.onDidUpdateImageDownloadingProgress?(0)
        }
    }

    private func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }

    // MARK: - Public methods

    func setup() {
        requestAuthorization()
    }

    func requestImages() {
        fetchAssets()
        startCachingAssets()
        onDidUpdateImages?()
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
        options.progressHandler = { [weak self] progress, error, _, _ in
            self?.stopProgressTimer()
            DispatchQueue.main.async {
                if let error = error {
                    self?.onDidReceiveError?(error)
                } else {
                    self?.onDidUpdateImageDownloadingProgress?(progress)
                }
            }
        }
        options.resizeMode = .exact
        options.deliveryMode = .highQualityFormat

        startProgressTimer()
        fullImageRequestID = imageManager.requestImage(for: asset,
                                                       targetSize: PHImageManagerMaximumSize,
                                                       contentMode: .default,
                                                       options: options) { image, _ in
                                                        completion(image)
        }
    }
}
