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

    // MARK: - Private properties

    private let photoLibrary: PhotoLibrary
    private let screenScaleProvider: ScreenScaleProvider
    private let urlOpener: URLOpener
    private let hudProvider: HUDProvider

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

    // MARK: - Public properties

    var didSelectPhoto: ((Photo) -> Void)?

    // MARK: - Init

    init(photoLibrary: PhotoLibrary = .init(),
         screenScaleProvider: ScreenScaleProvider = UIScreen.main,
         urlOpener: URLOpener = UIApplication.shared,
         hudProvider: HUDProvider = JGProgressHUDProvider()) {
        self.photoLibrary = photoLibrary
        self.screenScaleProvider = screenScaleProvider
        self.urlOpener = urlOpener
        self.hudProvider = hudProvider

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        photoLibrary.setup()
    }

    // MARK: - Setup

    private func setup() {
        addCollectionView()

        photoLibrary.onDidChangeAuthorizationStatus = { [weak self] status in
            self?.handleAuthorizationStatus(status)
        }

        photoLibrary.onDidUpdatePhotos = { [weak self] numberOfPhotos in
            guard let self = self else { return }

            self.collectionView.reloadData()
            if numberOfPhotos > 1 {
                let lastIndexPath = IndexPath(item: numberOfPhotos - 1, section: 0)
                self.collectionView.performBatchUpdates({ }, completion: { _ in
                    self.collectionView.scrollToItem(at: lastIndexPath, at: .bottom, animated: false)
                })
            }
        }

        photoLibrary.onDidUpdatePhotoDownloadingProgress = { [weak self] progress in
            guard let self = self else { return }

            if progress < 1 {
                self.hudProvider.showProgressHUD(withProgress: Float(progress), in: self.view)
            } else {
                self.hudProvider.dismissHUD(afterDelay: 0.1)
            }
        }

        photoLibrary.onDidReceiveError = { [weak self] _ in
            guard let self = self else { return }

            self.hudProvider.dismissHUD()
            self.showPhotoDownloadingError()
        }
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

    // MARK: - Private methods

    private func handleAuthorizationStatus(_ status: PHAuthorizationStatus) {
        switch status {
        case .notDetermined:
            break
        case .authorized:
            photoLibrary.requestPhotos()
        default:
            showPhotosAuthorizationDeniedAlert()
        }
    }

    private func showPhotosAuthorizationDeniedAlert() {
        let alert = UIAlertController(title: nil, message: "Photo Library access is now allowed", preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        let settingsAction = UIAlertAction(title: "Go to Settings", style: .default) { _ in
            self.urlOpener.openURL(UIApplication.openSettingsURLString)
        }
        alert.addAction(settingsAction)

        present(alert, animated: true)
    }

    private func showPhotoDownloadingError() {
        let alert = UIAlertController(title: "Error",
                                      message: "An error occured while downloading the selected image. Please try again later",
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okAction)

        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDataSource

extension PhotoLibraryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoLibrary.numberOfPhotos
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

    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let currentCell = collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell {
            currentCell.showOverlayView()
        }
    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let currentCell = collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell {
            currentCell.hideOverlayView()
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        photoLibrary.requestFullPhoto(at: indexPath.row) { [weak self] photo in
            if let photo = photo {
                self?.didSelectPhoto?(photo)
            }
        }
    }
}
