//
//  EditorViewController.swift
//  ImageFramer
//
//  Created by Dani on 18/03/2019.
//  Copyright © 2019 icecoffin. All rights reserved.
//

import UIKit
import SVProgressHUD

final class EditorViewController: UIViewController {
    // MARK: - Private properties

    private let containerStackView = UIStackView()
    private let previewImageView = UIImageView()
    private let valueSlider = ValueSlider()
    private let selectButton = UIButton(type: .system)
    private let saveButton = UIButton(type: .system)

    private var currentOriginalImage: UIImage?
    private var currentResizedOriginalImage: UIImage?

    private let photoLibrary: PhotoLibrary
    private let imageProcessor: ImageProcessor

    // MARK: - Public properties

    var didRequestToSelectPhoto: (() -> Void)?

    // MARK: - Init

    init(photoLibrary: PhotoLibrary = .init(),
         imageProcessor: ImageProcessor = .init()) {
        self.photoLibrary = photoLibrary
        self.imageProcessor = imageProcessor

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
        guard let originalImage = currentOriginalImage else { return }

        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.show(withStatus: "Saving...")
        imageProcessor.addFrame(withSize: valueSlider.value, to: originalImage) { framedImage in
            if let framedImage = framedImage {
                self.saveImage(framedImage)
            } else {
                SVProgressHUD.dismiss()
            }
        }
    }

    // MARK: - Private methods

    private func updatePreview() {
        guard let image = currentResizedOriginalImage else { return }

        imageProcessor.addFrame(withSize: valueSlider.value, to: image) { [weak self] framedImage in
            self?.previewImageView.image = framedImage
        }
    }

    private func saveImage(_ image: UIImage) {
        photoLibrary.saveImage(image) { [weak self] success, error in
            if success {
                SVProgressHUD.showSuccess(withStatus: "Saved")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    SVProgressHUD.dismiss()
                }
            } else {
                SVProgressHUD.dismiss()
                self?.showAlert(with: error)
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

    func update(with image: UIImage) {
        currentOriginalImage = image
        currentResizedOriginalImage = imageProcessor.resizeImage(image, to: previewImageView.frame.size)
        updatePreview()
    }
}
