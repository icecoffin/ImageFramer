//
//  EditorViewController.swift
//  ImageFramer
//
//  Created by Dani on 18/03/2019.
//  Copyright © 2019 icecoffin. All rights reserved.
//

import UIKit

final class EditorViewController: UIViewController {
    private let containerStackView = UIStackView()
    private let previewImageView = UIImageView()
    private let valueSlider = ValueSlider()
    private let selectButton = UIButton(type: .system)
    private let saveButton = UIButton(type: .system)

    private var currentOriginalImage: UIImage?
    private var currentResizedOriginalImage: UIImage?

    private let imageProcessor = ImageProcessor()

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    private func setup() {
        view.backgroundColor = UIColor(white: 0.8, alpha: 1)

        addContainerStackView()
        addPreviewImageView()
        addValueSlider()
        addSelectButton()
        addSaveButton()

        setupConstraints()
    }

    private func addContainerStackView() {
        view.addSubview(containerStackView)

        containerStackView.axis = .vertical
        containerStackView.distribution = .equalSpacing
        containerStackView.spacing = 16
    }

    private func addPreviewImageView() {
        containerStackView.addArrangedSubview(previewImageView)
        previewImageView.backgroundColor = .white
        previewImageView.contentMode = .scaleAspectFit
    }

    private func addValueSlider() {
        containerStackView.addArrangedSubview(valueSlider)
        valueSlider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
    }

    private func addSelectButton() {
        containerStackView.addArrangedSubview(selectButton)
        selectButton.setTitle("Select photo", for: .normal)
        selectButton.addTarget(self, action: #selector(selectButtonTapped(_:)), for: .touchUpInside)
    }

    private func addSaveButton() {
        containerStackView.addArrangedSubview(saveButton)
        saveButton.setTitle("Save copy", for: .normal)
        saveButton.addTarget(self, action: #selector(saveButtonTapped(_:)), for: .touchUpInside)
    }

    private func setupConstraints() {
        containerStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }

        previewImageView.snp.makeConstraints { make in
            make.width.equalTo(previewImageView.snp.height)
        }
    }

    @objc private func sliderValueChanged(_ sender: ValueSlider) {
        updatePreview()
    }

    @objc private func selectButtonTapped(_ sender: UIButton) {
        let photoLibraryViewController = PhotoLibraryViewController()
        let navigationController = UINavigationController(rootViewController: photoLibraryViewController)

        let closeButton = UIBarButtonItem(title: "Close",
                                          style: .plain,
                                          target: self,
                                          action: #selector(photoLibraryCloseButtonTapped(_:)))
        photoLibraryViewController.navigationItem.leftBarButtonItem = closeButton
        photoLibraryViewController.title = "Select photo"

        photoLibraryViewController.didSelectImage = { [unowned self] image in
            self.update(with: image)
            self.dismiss(animated: true, completion: nil)
        }

        present(navigationController, animated: true, completion: nil)
    }

    private func update(with image: UIImage) {
        currentOriginalImage = image
        currentResizedOriginalImage = imageProcessor.resizeImage(image, to: previewImageView.frame.size)
        updatePreview()
    }

    @objc private func saveButtonTapped(_ sender: UIButton) {
        guard let originalImage = currentOriginalImage else { return }

        imageProcessor.addFrame(widthPercentage: valueSlider.value, to: originalImage) { framedImage in
            if let framedImage = framedImage {
                UIImageWriteToSavedPhotosAlbum(framedImage, nil, nil, nil)
            }
        }
    }

    @objc private func photoLibraryCloseButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    private func updatePreview() {
        guard let image = currentResizedOriginalImage else { return }

        imageProcessor.addFrame(widthPercentage: valueSlider.value, to: image) { [weak self] framedImage in
            self?.previewImageView.image = framedImage
        }
    }
}
