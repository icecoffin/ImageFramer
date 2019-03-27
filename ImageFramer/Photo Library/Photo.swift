//
//  Photo.swift
//  ImageFramer
//
//  Created by Dani on 27/03/2019.
//  Copyright © 2019 icecoffin. All rights reserved.
//

import UIKit
import CoreLocation

final class Photo {
    let image: UIImage
    let location: CLLocation?

    init?(image: UIImage?, location: CLLocation?) {
        guard let image = image else { return nil }

        self.image = image
        self.location = location
    }
}
