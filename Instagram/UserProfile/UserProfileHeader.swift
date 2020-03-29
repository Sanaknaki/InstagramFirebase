//
//  UserProfileHeader.swift
//  Instagram
//
//  Created by Ali Sanaknaki on 2020-03-28.
//  Copyright © 2020 Ali Sanaknaki. All rights reserved.
//

import UIKit
import Firebase

class UserProfileHeader: UICollectionViewCell {
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        
        iv.backgroundColor = .red
        
        iv.layer.cornerRadius = 80 / 2
        
        iv.clipsToBounds = true
        
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .blue
        
        addSubview(profileImageView)
        
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)
    }
    
    var user: User? {
        didSet {
            setupProfileImage()
        }
    }
    
    // Grab profile image for this user
    fileprivate func setupProfileImage() {
        guard let profileImageUrl = user?.profileImageUrl else { return }
        guard let url = URL(string: profileImageUrl) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            // Check for err, then build image using data
            if let err = err {
                print("Failed to fetch user profile: ", err)
                return
            }
            
            // Perhaps check for response that's 200 (HTTP OK)
            
            guard let data = data else { return }
            
            let image = UIImage(data: data)
            
            // Async call to to get back on main thread to update profile pic
            DispatchQueue.main.async {
                self.profileImageView.image = image
            }
            
            }.resume()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
