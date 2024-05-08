//
//  SceneDelegate.swift
//  Jinmoon'sLibrary
//
//  Created by 최진문 on 2024/05/02.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let tabBarController = UITabBarController()
        
        let searchViewController: SearchViewController = {
            let vc = SearchViewController()
            vc.view.backgroundColor = .white
            vc.tabBarItem = UITabBarItem(title: "책 검색", image: UIImage(systemName: "magnifyingglass"), selectedImage: UIImage(systemName: "magnifyingglass.fill"))
            return vc
        }()
        let homeViewController: ViewController = {
            let vc = ViewController()
            vc.view.backgroundColor = .white
            vc.tabBarItem = UITabBarItem(title: "홈", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))
            return vc
        }()
        let listViewController: WishListViewController = {
            let vc = WishListViewController()
            vc.view.backgroundColor = .white
            vc.tabBarItem = UITabBarItem(title: "담은 책", image: UIImage(systemName: "star"), selectedImage: UIImage(systemName: "star.fill"))
            return vc
        }()
        
        tabBarController.viewControllers = [searchViewController, homeViewController, listViewController]
        tabBarController.selectedIndex = 1
        tabBarController.tabBar.tintColor = UIColor.systemCyan
        tabBarController.tabBar.backgroundColor = UIColor.systemGray5
        tabBarController.tabBar.isUserInteractionEnabled = true
        
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = tabBarController
        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

