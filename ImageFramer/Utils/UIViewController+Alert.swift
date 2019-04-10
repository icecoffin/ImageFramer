//
//  UIViewController+Alert.swift
//  ImageFramer
//
//  Created by Dani on 10/04/2019.
//  Copyright © 2019 icecoffin. All rights reserved.
//

import UIKit

extension UIViewController {
    func showAlert(title: String? = nil,
                   message: String,
                   cancelActionTitle: String,
                   otherActions actions: [UIAlertAction] = []) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: cancelActionTitle, style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        for action in actions {
            alert.addAction(action)
        }

        present(alert, animated: true)
    }
}
