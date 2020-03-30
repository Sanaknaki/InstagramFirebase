//
//  Post.swift
//  Instagram
//
//  Created by Ali Sanaknaki on 2020-03-29.
//  Copyright © 2020 Ali Sanaknaki. All rights reserved.
//

import Foundation

struct Post {
    let imageUrl: String
    
    init(dictionary: [String: Any]) {
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
    }
}
