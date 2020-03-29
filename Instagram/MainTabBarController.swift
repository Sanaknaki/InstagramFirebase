//
//  MainTabBarController.swift
//  Instagram
//
//  Created by Ali Sanaknaki on 2020-03-28.
//  Copyright © 2020 Ali Sanaknaki. All rights reserved.
//

import UIKit
import Firebase

class MainTabBarController: UITabBarController {
    
    // When overriding, call super so it shows what it's supposed to do
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // If there's no user, show login screen
        if Auth.auth().currentUser == nil {
            
            DispatchQueue.main.async {
                let loginController = LoginController()
                let navController = UINavigationController(rootViewController: loginController)
                self.present(navController, animated:true, completion: nil)
            }
            return
        }
        
        setupViewControllers()
    }
    
    func setupViewControllers() {
        let layout = UICollectionViewFlowLayout()
        let userProfileController = UserProfileController(collectionViewLayout: layout)
        let navController = UINavigationController(rootViewController: userProfileController)
        
        navController.tabBarItem.image = #imageLiteral(resourceName: "profile-unselected")
        navController.tabBarItem.selectedImage = #imageLiteral(resourceName: "profile-selected")
        
        // To edit TabBar
        tabBar.tintColor = .black
        
        // Takes in an array of VC's
        viewControllers = [navController, UIViewController()]
    }
}
