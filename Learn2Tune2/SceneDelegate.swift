//
//  SceneDelegate.swift
//  Learn2Tune
//
//  Created by gam on 6/9/20.
//  Copyright © 2020 gam. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    let dataController = DataController(modelName: "Learn2Tune")

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // light mode only
        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .light
        }
        guard let _ = (scene as? UIWindowScene) else { return }
        dataController.load()
        let tabBarController = window?.rootViewController as! UITabBarController
        var navigationController = tabBarController.viewControllers?.first as! UINavigationController
        let mapViewController = navigationController.topViewController as! MapViewController
        //navigationController
        mapViewController.dataController = dataController
        // second tab
        navigationController = tabBarController.viewControllers?[1] as! UINavigationController
        let tableViewController =  navigationController.topViewController as! ImagesTableViewController
        tableViewController.dataController = dataController
        //
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        print("sceneDidDisconnect")
            saveViewContext()    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
        print("sceneWillResignActive")
        saveViewContext()

    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        print("sceneDidEnterBackground")
         saveViewContext()
    }

    func saveViewContext() {
        try? dataController.viewContext.save()
    }

}

