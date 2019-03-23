//
//  URLOpener.swift
//  ImageFramer
//
//  Created by Dani on 23/03/2019.
//  Copyright © 2019 icecoffin. All rights reserved.
//

import UIKit

protocol URLOpener {
    func openURL(_ url: URL)
}

extension URLOpener {
    func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }

        openURL(url)
    }
}

extension UIApplication: URLOpener {
    func openURL(_ url: URL) {
        open(url, options: [:], completionHandler: nil)
    }
}
