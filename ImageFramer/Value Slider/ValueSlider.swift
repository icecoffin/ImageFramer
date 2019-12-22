//
//  ValueSlider.swift
//  ImageFramer
//
//  Created by Dani on 18/03/2019.
//  Copyright © 2019 icecoffin. All rights reserved.
//

import UIKit
import SnapKit

final class ValueSlider: UIControl {
    private struct Constants {
        static let valueSliderContainerViewSide: CGFloat = 32
        static let valueSliderContainerViewBottomOffset: CGFloat = 10
        static let hapticFeedbackGenerationValue = 10
    }

    // MARK: - Private properties

    private let viewModel: ValueSliderViewModel

    private let slider = UISlider()
    private let valueLabelContainerView = UIView()
    private let valueLabel = UILabel()

    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)

    private var sliderThumbRect: CGRect {
        let trackRect = slider.trackRect(forBounds: slider.bounds)
        let thumbRect = slider.thumbRect(forBounds: slider.bounds, trackRect: trackRect, value: slider.value)
        return thumbRect
    }

    private var valueLabelContainerViewLeadingOffset: CGFloat {
        return slider.frame.origin.x + sliderThumbRect.origin.x +
            sliderThumbRect.width / 2 - valueLabelContainerView.frame.width / 2
    }

    private var previousValue: UInt?

    // MARK: - Public properties

    var value: UInt {
        return viewModel.normalize(sliderValue: slider.value)
    }

    // MARK: - Init

    init(viewModel: ValueSliderViewModel = .init()) {
        self.viewModel = viewModel

        super.init(frame: .zero)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        addSlider()
        addValueLabelContainerView()
        addValueLabel()
        setupConstraints()

        updateValueLabel()
    }

    private func addSlider() {
        addSubview(slider)
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        slider.minimumTrackTintColor = .lightGray
        slider.maximumTrackTintColor = .darkGray
    }

    private func addValueLabelContainerView() {
        addSubview(valueLabelContainerView)
        valueLabelContainerView.backgroundColor = .white
        valueLabelContainerView.layer.cornerRadius = Constants.valueSliderContainerViewSide / 2
    }

    private func addValueLabel() {
        valueLabelContainerView.addSubview(valueLabel)
        valueLabel.textColor = .black
        valueLabel.font = UIFont.boldSystemFont(ofSize: 16)
    }

    private func setupConstraints() {
        slider.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().priority(999)
        }

        valueLabelContainerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalTo(slider.snp.top).offset(-Constants.valueSliderContainerViewBottomOffset)
            make.leading.equalToSuperview().offset(valueLabelContainerViewLeadingOffset)
            make.width.height.equalTo(Constants.valueSliderContainerViewSide)
        }

        valueLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    // MARK: - Actions

    @objc private func sliderValueChanged(_ slider: UISlider) {
        updateValueLabel()

        if previousValue != value {
            previousValue = value
            sendActions(for: .valueChanged)

            if value == Constants.hapticFeedbackGenerationValue {
                feedbackGenerator.impactOccurred()
            }
        }
    }

    private func updateValueLabel() {
        valueLabel.text = String(value)
        layoutIfNeeded()

        valueLabelContainerView.snp.updateConstraints { make in
            make.leading.equalToSuperview().offset(valueLabelContainerViewLeadingOffset)
        }
    }
}
