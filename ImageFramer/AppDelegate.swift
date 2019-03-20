//
//  AppDelegate.swift
//  ImageFramer
//
//  Created by Dani on 18/03/2019.
//  Copyright © 2019 icecoffin. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = .white
        window.makeKeyAndVisible()

        window.rootViewController = EditorViewController()

        self.window = window

        return true
    }
}
