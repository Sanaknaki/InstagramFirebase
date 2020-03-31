//
//  Comment.swift
//  Instagram
//
//  Created by Ali Sanaknaki on 2020-03-31.
//  Copyright © 2020 Ali Sanaknaki. All rights reserved.
//

import Foundation

struct Comment {
    let text: String
    let uid: String
    
    init(dictionary: [String: Any]) {
        self.text = dictionary["text"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
    }
}
