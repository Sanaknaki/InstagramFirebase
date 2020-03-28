//
//  userProfileController.swift
//  Instagram
//
//  Created by Ali Sanaknaki on 2020-03-28.
//  Copyright © 2020 Ali Sanaknaki. All rights reserved.
//

import UIKit
import Firebase

class UserProfileController: UICollectionViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = .white
        
        fetchUser()
    }
    
    // Only accessible in this view with 'fileprivate'
    fileprivate func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // Observe Single Event : Get me this 1 thing then stop watching this child
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (DataSnapshot) in
//            print(DataSnapshot.value)
            
            guard let dict = DataSnapshot.value as? [String: Any] else { return }
            
            let username = dict["username"] as? String
            
            self.navigationItem.title = username
            
        }) { (err) in
            print("Failed to fetch user:", err)
        }
    }
}
