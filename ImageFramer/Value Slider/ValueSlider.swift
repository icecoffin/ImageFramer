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
    // MARK: - Private properties
    private let viewModel: ValueSliderViewModel

    private let slider = UISlider()
    private let valueLabel = UILabel()

    private var sliderThumbRect: CGRect {
        let trackRect = slider.trackRect(forBounds: slider.bounds)
        let thumbRect = slider.thumbRect(forBounds: slider.bounds, trackRect: trackRect, value: slider.value)
        return thumbRect
    }

    private var valueLabelLeadingOffset: CGFloat {
        return slider.frame.origin.x + sliderThumbRect.origin.x + sliderThumbRect.width / 2 - valueLabel.frame.width / 2
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
        addValueLabel()
        setupConstraints()

        updateValueLabel()
    }

    private func addSlider() {
        addSubview(slider)
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
    }

    private func addValueLabel() {
        addSubview(valueLabel)
        valueLabel.textColor = .white
        valueLabel.font = UIFont.boldSystemFont(ofSize: 16)
    }

    private func setupConstraints() {
        slider.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().priority(999)
        }

        valueLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalTo(slider.snp.top).offset(-4)
            make.leading.equalToSuperview().offset(valueLabelLeadingOffset)
        }
    }

    // MARK: - Actions
    @objc private func sliderValueChanged(_ slider: UISlider) {
        updateValueLabel()

        if previousValue != value {
            previousValue = value
            sendActions(for: .valueChanged)
        }
    }

    private func updateValueLabel() {
        valueLabel.text = String(value)
        layoutIfNeeded()

        valueLabel.snp.updateConstraints { make in
            make.leading.equalToSuperview().offset(valueLabelLeadingOffset)
        }
    }
}
