//
//  ScreenScaleProvider.swift
//  ImageFramer
//
//  Created by Dani on 21/03/2019.
//  Copyright © 2019 icecoffin. All rights reserved.
//

import UIKit

protocol ScreenScaleProvider {
    var scale: CGFloat { get }
}

extension UIScreen: ScreenScaleProvider { }
