//
//  EditorViewController.swift
//  ImageFramer
//
//  Created by Dani on 18/03/2019.
//  Copyright © 2019 icecoffin. All rights reserved.
//

import UIKit

final class EditorViewController: UIViewController {
    // MARK: - Private properties

    private let containerStackView = UIStackView()
    private let previewImageView = UIImageView()
    private let valueSlider = ValueSlider()
    private let selectButton = UIButton(type: .system)
    private let saveButton = UIButton(type: .system)

    private var originalPhoto: Photo?
    private var resizedOriginalImage: UIImage?

    private let photoLibrary: PhotoLibrary
    private let imageProcessor: ImageProcessor
    private let hudProvider: HUDProvider

    // MARK: - Public properties

    var didRequestToSelectPhoto: (() -> Void)?

    // MARK: - Init

    init(photoLibrary: PhotoLibrary = .init(),
         imageProcessor: ImageProcessor = .init(),
         hudProvider: HUDProvider = JGProgressHUDProvider()) {
        self.photoLibrary = photoLibrary
        self.imageProcessor = imageProcessor
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

    // MARK: - Setup

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    private func setup() {
        view.backgroundColor = .black

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

        configureButton(selectButton)
        selectButton.setTitle("Select photo", for: .normal)
        selectButton.addTarget(self, action: #selector(selectButtonTapped(_:)), for: .touchUpInside)
    }

    private func addSaveButton() {
        containerStackView.addArrangedSubview(saveButton)

        configureButton(saveButton)
        saveButton.setTitle("Save copy", for: .normal)
        saveButton.addTarget(self, action: #selector(saveButtonTapped(_:)), for: .touchUpInside)
    }

    private func configureButton(_ button: UIButton) {
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 6
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
    }

    private func setupConstraints() {
        containerStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.centerY.equalToSuperview()
        }

        previewImageView.snp.makeConstraints { make in
            make.width.equalTo(previewImageView.snp.height)
        }

        selectButton.snp.makeConstraints { make in
            make.height.equalTo(44)
        }

        saveButton.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
    }

    // MARK: - Actions

    @objc private func sliderValueChanged(_ sender: ValueSlider) {
        updatePreview()
    }

    @objc private func selectButtonTapped(_ sender: UIButton) {
        didRequestToSelectPhoto?()
    }

    @objc private func saveButtonTapped(_ sender: UIButton) {
        guard let originalPhoto = originalPhoto else { return }

        hudProvider.showLoadingHUD(withStatus: "Saving...", in: view)
        imageProcessor.addFrame(withSize: valueSlider.value, to: originalPhoto.image) { framedImage in
            if let framedImage = framedImage, let newPhoto = Photo(image: framedImage, location: originalPhoto.location) {
                self.savePhoto(newPhoto)
            } else {
                self.hudProvider.dismissHUD()
            }
        }
    }

    // MARK: - Private methods

    private func updatePreview() {
        guard let image = resizedOriginalImage else { return }

        imageProcessor.addFrame(withSize: valueSlider.value, to: image) { [weak self] framedImage in
            self?.previewImageView.image = framedImage
        }
    }

    private func savePhoto(_ photo: Photo) {
        photoLibrary.savePhoto(photo) { [weak self] success, error in
            guard let self = self else { return }

            if success {
                self.hudProvider.showSuccessHUD(withStatus: "Saved", in: self.view, dismissAfter: 1.0)
            } else {
                self.hudProvider.dismissHUD()
                self.showAlert(with: error)
            }
        }
    }

    private func showAlert(with error: Error?) {
        guard let error = error else { return }

        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okAction)

        present(alert, animated: true)
    }

    // MARK: - Public methods

    func update(with photo: Photo) {
        originalPhoto = photo
        resizedOriginalImage = imageProcessor.resizeImage(photo.image, to: previewImageView.frame.size)
        updatePreview()
    }
}
