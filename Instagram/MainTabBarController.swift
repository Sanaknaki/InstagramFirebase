//
//  MainTabBarController.swift
//  Instagram
//
//  Created by Ali Sanaknaki on 2020-03-28.
//  Copyright © 2020 Ali Sanaknaki. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    // When overriding, call super so it shows what it's supposed to do
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Takes in an array of VC's
        
        let redVC = UIViewController()
        redVC.view.backgroundColor = .red
        
        let layout = UICollectionViewFlowLayout()
        let userProfileController = UserProfileController(collectionViewLayout: layout)
        let navController = UINavigationController(rootViewController: userProfileController)
        
        navController.tabBarItem.image = #imageLiteral(resourceName: "profile-unselected")
        navController.tabBarItem.selectedImage = #imageLiteral(resourceName: "profile-selected")
        
        // To edit TabBar
        tabBar.tintColor = .black
        
        viewControllers = [navController, UIViewController()]
    }
}
