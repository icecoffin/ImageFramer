//
//  BlockBarButtonItem.swift
//  ImageFramer
//
//  Created by Dani on 21/03/2019.
//  Copyright © 2019 icecoffin. All rights reserved.
//

import UIKit

class BlockBarButtonItem: UIBarButtonItem {
    private let actionHandler: (() -> Void)

    init(image: UIImage?, style: UIBarButtonItem.Style, actionHandler: @escaping (() -> Void)) {
        self.actionHandler = actionHandler
        super.init()

        self.image = image
        self.style = style
        self.target = self
        self.action = #selector(barButtonItemTapped(_:))
    }

    init(title: String?, style: UIBarButtonItem.Style, actionHandler: @escaping (() -> Void)) {
        self.actionHandler = actionHandler
        super.init()

        self.title = title
        self.style = style
        self.target = self
        self.action = #selector(barButtonItemTapped(_:))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func barButtonItemTapped(_ sender: UIButton) {
        actionHandler()
    }
}
