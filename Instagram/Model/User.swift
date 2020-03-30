//
//  User.swift
//  Instagram
//
//  Created by Ali Sanaknaki on 2020-03-30.
//  Copyright © 2020 Ali Sanaknaki. All rights reserved.
//

import Foundation

// User object that we will use to manipulate the header components
struct User {
    let uid: String
    let username: String
    let profileImageUrl: String
    
    init(uid: String, dict: [String: Any]) {
        self.uid = uid
        self.username = dict["username"] as? String ?? ""
        self.profileImageUrl = dict["profileImageUrl"] as? String ?? ""
    }
}
