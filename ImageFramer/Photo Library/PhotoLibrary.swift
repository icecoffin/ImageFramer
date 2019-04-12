//
//  PhotoLibrary.swift
//  ImageFramer
//
//  Created by Dani on 20/03/2019.
//  Copyright © 2019 icecoffin. All rights reserved.
//

import Foundation
import Photos

final class PhotoLibrary: NSObject {
    // MARK: - Private properties

    // Would be nice to use a caching image manager in the future.
    private lazy var imageManager = PHImageManager()
    private lazy var photoLibrary = PHPhotoLibrary.shared()

    private var assets: PHFetchResult<PHAsset>?
    private var activeRequests: [Int: PHImageRequestID] = [:]
    private var fullImageRequestID: PHImageRequestID?
    private var progressTimer: Timer?

    // MARK: - Public properties

    var onDidChangeAuthorizationStatus: ((PHAuthorizationStatus) -> Void)?
    var onDidUpdatePhotos: ((PhotoLibraryChange) -> Void)?
    var onDidUpdatePhotoDownloadingProgress: ((Double) -> Void)?
    var onDidReceiveError: ((Error) -> Void)?

    var numberOfPhotos: Int {
        return assets?.count ?? 0
    }

    // MARK: - Init

    deinit {
        stopProgressTimer()
        onDidUpdatePhotoDownloadingProgress?(1)

        activeRequests.forEach { _, imageRequestID in
            imageManager.cancelImageRequest(imageRequestID)
        }

        if let fullImageRequestID = fullImageRequestID {
            imageManager.cancelImageRequest(fullImageRequestID)
        }

        photoLibrary.unregisterChangeObserver(self)
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
        let collections = PHAssetCollection.fetchAssetCollections(with: .smartAlbum,
                                                                  subtype: .smartAlbumUserLibrary,
                                                                  options: nil)
        if let collection = collections.firstObject {
            let options = PHFetchOptions()
            options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
            assets = PHAsset.fetchAssets(in: collection, options: options)
        } else {
            assets = PHAsset.fetchAssets(with: .image, options: nil)
        }
    }

    // Since PHImageRequestOptions.progressHandler doesn't notify for progress = 0, we'll use a hacky way to ensure
    // that the progress HUD is shown right after selecting an iCloud asset (or, actually, with a small delay).
    // We start a timer after picking an image and stop it if the image is delivered instantly (meaning it was not in iCloud).
    // Otherwise, if the image is not delivered within 0.05 seconds, we assume that it's in iCloud and show a HUD
    // with progress = 0.
    private func startProgressTimer() {
        progressTimer = Timer(timeInterval: 0.05, repeats: false) { [weak self] _ in
            self?.onDidUpdatePhotoDownloadingProgress?(0)
        }
    }

    private func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }

    // MARK: - Public methods

    func setup() {
        requestAuthorization()
        photoLibrary.register(self)
    }

    func requestPhotos() {
        fetchAssets()
    }

    func requestThumbnail(at index: Int, targetSize: CGSize, completion: @escaping ((UIImage?) -> Void)) {
        guard let asset = assets?.object(at: index) else { return }

        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
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

    func requestFullPhoto(at index: Int, completion: @escaping ((Photo?) -> Void)) {
        guard let asset = assets?.object(at: index) else { return }

        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.progressHandler = { [weak self] progress, error, _, _ in
            self?.stopProgressTimer()
            DispatchQueue.main.async {
                if let error = error {
                    self?.onDidReceiveError?(error)
                } else {
                    self?.onDidUpdatePhotoDownloadingProgress?(progress)
                }
            }
        }

        startProgressTimer()
        fullImageRequestID = imageManager.requestImageData(for: asset, options: options) { imageData, _, _, _ in
            let image = UIImage(data: imageData ?? Data())
            let photo = Photo(image: image, location: asset.location)
            completion(photo)
        }
    }

    func savePhoto(_ photo: Photo, completion: ((Bool, Error?) -> Void)?) {
        photoLibrary.performChanges({
            let request = PHAssetCreationRequest.creationRequestForAsset(from: photo.image)
            request.location = photo.location
        }, completionHandler: { success, error in
            DispatchQueue.main.async {
                completion?(success, error)
            }
        })
    }
}

// MARK: - PHPhotoLibraryChangeObserver

extension PhotoLibrary: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let assets = assets, let changeDetails = changeInstance.changeDetails(for: assets) else {
            return
        }

        self.assets = changeDetails.fetchResultAfterChanges
        let photoLibraryChange = PhotoLibraryChange(changeDetails: changeDetails)
        DispatchQueue.main.async {
            self.onDidUpdatePhotos?(photoLibraryChange)
        }
    }
}
