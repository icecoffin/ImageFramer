//
//  AppCoordinator.swift
//  ImageFramer
//
//  Created by Dani on 21/03/2019.
//  Copyright © 2019 icecoffin. All rights reserved.
//

import UIKit

final class AppCoordinator {
    private let window: UIWindow

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        let editorViewController = EditorViewController()
        editorViewController.didRequestToSelectPhoto = { [unowned self, unowned editorViewController] in
            self.editorViewControllerDidRequestToSelectPhoto(editorViewController)
        }
        window.rootViewController = editorViewController
    }

    func editorViewControllerDidRequestToSelectPhoto(_ viewController: EditorViewController) {
        let photoLibraryViewController = PhotoLibraryViewController()
        let navigationController = UINavigationController(rootViewController: photoLibraryViewController)

        let closeButton = BlockBarButtonItem(title: "Close", style: .plain) { [unowned viewController] in
            viewController.dismiss(animated: true)
        }

        photoLibraryViewController.navigationItem.leftBarButtonItem = closeButton
        photoLibraryViewController.title = "Select photo"

        photoLibraryViewController.didSelectPhoto = { [unowned viewController] photo in
            viewController.update(with: photo)
            viewController.dismiss(animated: true)
        }

        viewController.present(navigationController, animated: true)
    }
}
