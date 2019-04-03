//
//  HUDProvider.swift
//  ImageFramer
//
//  Created by Dani on 03/04/2019.
//  Copyright © 2019 icecoffin. All rights reserved.
//

import UIKit
import JGProgressHUD

protocol HUDProvider {
    func showLoadingHUD(withStatus status: String, in view: UIView)
    func showProgressHUD(withProgress progress: Float, in view: UIView)
    func showSuccessHUD(withStatus status: String, in view: UIView, dismissAfter: TimeInterval)
    func dismissHUD(afterDelay delay: TimeInterval)
}

extension HUDProvider {
    func dismissHUD() {
        dismissHUD(afterDelay: 0)
    }
}

final class JGProgressHUDProvider: HUDProvider {
    private let hud = JGProgressHUD(style: .dark)
    private var isShowingHUD = false

    init() {
        hud.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        hud.parallaxMode = .alwaysOff
    }

    func showLoadingHUD(withStatus status: String, in view: UIView) {
        hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        hud.textLabel.text = status
        showHUDIfNeeded(in: view)
    }

    func showProgressHUD(withProgress progress: Float, in view: UIView) {
        hud.indicatorView = JGProgressHUDRingIndicatorView()
        hud.progress = progress
        showHUDIfNeeded(in: view)
    }

    func showSuccessHUD(withStatus status: String, in view: UIView, dismissAfter: TimeInterval) {
        hud.indicatorView = JGProgressHUDSuccessIndicatorView()
        hud.textLabel.text = status
        showHUDIfNeeded(in: view)
        dismissHUD(afterDelay: dismissAfter)
    }

    func dismissHUD(afterDelay delay: TimeInterval = 0) {
        hud.dismiss(afterDelay: delay, animated: true)
        isShowingHUD = false
    }

    private func showHUDIfNeeded(in view: UIView) {
        guard !isShowingHUD else { return }

        hud.show(in: view)
        isShowingHUD = true
    }
}
