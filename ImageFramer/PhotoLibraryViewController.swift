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
    private struct Constants {
        static let numberOfCellsPerRow = 4
        static let defaultCellSpacing: CGFloat = 5
    }

    private let photoLibrary: PhotoLibrary
    private let screenScaleProvider: ScreenScaleProvider

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = Constants.defaultCellSpacing
        layout.minimumInteritemSpacing = Constants.defaultCellSpacing
        layout.sectionInset = UIEdgeInsets(top: Constants.defaultCellSpacing,
                                           left: Constants.defaultCellSpacing,
                                           bottom: Constants.defaultCellSpacing,
                                           right: Constants.defaultCellSpacing)
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()

    var didSelectImage: ((UIImage) -> Void)?

    init(photoLibrary: PhotoLibrary = .init(), screenScaleProvider: ScreenScaleProvider = UIScreen.main) {
        self.photoLibrary = photoLibrary
        self.screenScaleProvider = screenScaleProvider

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    private func setup() {
        addCollectionView()

        photoLibrary.setup()
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

// MARK: - UICollectionViewDataSource
extension PhotoLibraryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoLibrary.numberOfImages
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(ofType: PhotoCollectionViewCell.self, for: indexPath)

        let targetSize = CGSize(width: cellSize.width * screenScaleProvider.scale,
                                height: cellSize.height * screenScaleProvider.scale)
        photoLibrary.requestThumbnail(at: indexPath.row, targetSize: targetSize) { [weak cell] image in
            cell?.configure(with: image)
        }

        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension PhotoLibraryViewController: UICollectionViewDelegateFlowLayout {
    private var cellSize: CGSize {
        let contentWidth = collectionView.frame.width - CGFloat(Constants.numberOfCellsPerRow + 1) * Constants.defaultCellSpacing
        let cellWidth = contentWidth / CGFloat(Constants.numberOfCellsPerRow)

        return CGSize(width: cellWidth, height: cellWidth)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        photoLibrary.requestFullImage(at: indexPath.row) { [weak self] image in
            if let image = image {
                self?.didSelectImage?(image)
            } else {
                print("[DEBUG] An error occured")
            }
        }
    }
}
