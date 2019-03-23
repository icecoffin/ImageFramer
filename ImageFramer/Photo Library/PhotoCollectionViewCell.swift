//
//  PhotoCollectionViewCell.swift
//  ImageFramer
//
//  Created by Dani on 20/03/2019.
//  Copyright © 2019 icecoffin. All rights reserved.
//

import UIKit

final class PhotoCollectionViewCell: UICollectionViewCell {
    private let imageView = UIImageView()
    private let overlayView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        imageView.image = nil
        overlayView.isHidden = true
    }

    private func setup() {
        addImageView()
        addOverlayView()
        setupConstraints()
    }

    private func addImageView() {
        contentView.addSubview(imageView)

        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
    }

    private func addOverlayView() {
        contentView.addSubview(overlayView)

        overlayView.backgroundColor = .black
        overlayView.alpha = 0.4
        overlayView.isHidden = true
    }

    private func setupConstraints() {
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        overlayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func configure(with image: UIImage?) {
        imageView.image = image
    }

    func showOverlayView() {
        overlayView.isHidden = false
    }

    func hideOverlayView() {
        overlayView.isHidden = true
    }
}
