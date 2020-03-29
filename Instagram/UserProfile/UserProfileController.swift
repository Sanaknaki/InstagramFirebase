//
//  userProfileController.swift
//  Instagram
//
//  Created by Ali Sanaknaki on 2020-03-28.
//  Copyright © 2020 Ali Sanaknaki. All rights reserved.
//

import UIKit
import Firebase

class UserProfileController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = .white
        
        fetchUser()
        
        // Have to register the header/footer in the collection view giving it the Id
        collectionView.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerId")
    }
    
    // Build the header, give it an Id to be altered
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        // Downcast to be the UserProfileHeader
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerId", for: indexPath) as! UserProfileHeader
        
        //
        header.user = self.user
        
        return header
    }
    
    // Render out the size of the header section
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    
    // To be called in fetchUser() and header
    var user: User?
    
    // Only accessible in this view with 'fileprivate'
    fileprivate func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // Observe Single Event : Get me this 1 thing then stop watching this child
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (DataSnapshot) in
        
            guard let dict = DataSnapshot.value as? [String: Any] else { return }
            
            self.user = User(dict: dict)
            
            self.navigationItem.title = self.user?.username
            
            self.collectionView?.reloadData()
            
        }) { (err) in
            print("Failed to fetch user:", err)
        }
    }
}

// User object that we will use to manipulate the header components
struct User {
    let username: String
    let profileImageUrl: String
    
    init(dict: [String: Any]) {
        self.username = dict["username"] as? String ?? ""
        self.profileImageUrl = dict["profileImageUrl"] as? String ?? ""
    }
}
