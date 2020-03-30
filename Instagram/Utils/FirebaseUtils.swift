//
//  FirebaseUtils.swift
//  Instagram
//
//  Created by Ali Sanaknaki on 2020-03-30.
//  Copyright © 2020 Ali Sanaknaki. All rights reserved.
//

import Foundation
import Firebase

extension Database {
    static func fetchUserWithUID(uid: String, completion: @escaping (User) -> ()) {
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let userDict = snapshot.value as? [String: Any] else { return }
            
            let user = User(uid: uid, dict: userDict)
            
            // Completion block gets called with user returned
            completion(user)
            
        }) { (err) in
            print("Failed to fetch user for posts: ", err)
        }
    }
}
