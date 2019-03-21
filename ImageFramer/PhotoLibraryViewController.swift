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
    private let photoLibrary: PhotoLibrary
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    var didSelectImage: ((UIImage) -> Void)?

    init(photoLibrary: PhotoLibrary = .init()) {
        self.photoLibrary = photoLibrary
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

extension PhotoLibraryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoLibrary.numberOfImages
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(ofType: PhotoCollectionViewCell.self, for: indexPath)

        let targetSize = CGSize(width: cellSize.width * UIScreen.main.scale, height: cellSize.height * UIScreen.main.scale)
        photoLibrary.requestThumbnail(at: indexPath.row, targetSize: targetSize) { [weak cell] image in
            cell?.configure(with: image)
        }

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
        photoLibrary.requestFullImage(at: indexPath.row) { [weak self] image in
            if let image = image {
                self?.didSelectImage?(image)
            } else {
                print("[DEBUG] An error occured")
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
