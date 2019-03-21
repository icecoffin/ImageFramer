//
//  PhotoLibraryViewController.swift
//  ImageFramer
//
//  Created by Dani on 20/03/2019.
//  Copyright © 2019 icecoffin. All rights reserved.
//

import UIKit
import Photos

final class PhotoLibraryViewController: UIViewController {
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    private let imageManager = PHImageManager.default()
    private let cachingImageManager = PHCachingImageManager()
    private var assets: [PHAsset] = []

    var didSelectImage: ((UIImage) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    private func setup() {
        addCollectionView()

        let options = PHFetchOptions()
        let sortOrder = NSSortDescriptor(key: "creationDate", ascending: false)
        options.sortDescriptors = [sortOrder]
        let fetchedAssets = PHAsset.fetchAssets(with: .image, options: options)
        fetchedAssets.enumerateObjects { asset, _, _ in
            self.assets.append(asset)
        }

        cachingImageManager.startCachingImages(for: assets,
                                               targetSize: PHImageManagerMaximumSize,
                                               contentMode: .aspectFit,
                                               options: nil)

        collectionView.reloadData()
    }

    private func addCollectionView() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.register(PhotoCollectionViewCell.self)
    }
}

extension PhotoLibraryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(ofType: PhotoCollectionViewCell.self, for: indexPath)

        if cell.tag != 0 {
            imageManager.cancelImageRequest(PHImageRequestID(cell.tag))
        }

        let asset = assets[indexPath.row]
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        let targetSize = CGSize(width: cellSize.width * UIScreen.main.scale, height: cellSize.height * UIScreen.main.scale)
        let requestID = imageManager.requestImage(for: asset,
                                                  targetSize: targetSize,
                                                  contentMode: .aspectFill,
                                                  options: options,
                                                  resultHandler: { image, _ in
                                                    if let image = image {
                                                        print("[DEBUG] image.size = \(image.size)")
                                                    }
                                                    cell.configure(with: image)
        })
        cell.tag = Int(requestID)

        return cell
    }
}

extension PhotoLibraryViewController: UICollectionViewDelegateFlowLayout {
    private var cellSize: CGSize {
        let contentWidth = collectionView.frame.width - CGFloat(numberOfCellsPerRow + 1) * defaultCellSpacing
        let cellWidth = contentWidth / CGFloat(numberOfCellsPerRow)

        return CGSize(width: cellWidth, height: cellWidth)
    }

    private var numberOfCellsPerRow: Int {
        return 4
    }

    private var defaultCellSpacing: CGFloat {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = assets[indexPath.row]

        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.resizeMode = .exact
        options.deliveryMode = .highQualityFormat
        imageManager.requestImage(for: asset,
                                  targetSize: PHImageManagerMaximumSize,
                                  contentMode: .default,
                                  options: options) { image, _ in
            if let image = image {
                self.didSelectImage?(image)
            } else {
                print("[DEBUG] no image for asset \(asset)")
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return defaultCellSpacing
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return defaultCellSpacing
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: defaultCellSpacing,
                            left: defaultCellSpacing,
                            bottom: defaultCellSpacing,
                            right: defaultCellSpacing)
    }
}
