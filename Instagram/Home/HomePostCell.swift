//
//  HomePostCell.swift
//  Instagram
//
//  Created by Ali Sanaknaki on 2020-03-29.
//  Copyright © 2020 Ali Sanaknaki. All rights reserved.
//

import UIKit

class HomePostCell: UICollectionViewCell {
    
    var post: Post? {
        didSet {
            guard let postImageUrl = post?.imageUrl else { return }
            photoImageView.loadImage(urlString: postImageUrl)
            
            usernameLabel.text = post?.user.username
            
            guard let profileImageUrl = post?.user.profileImageUrl else { return }
            
            userProfileImageView.loadImage(urlString: profileImageUrl)
                        
            setupAttributedCaption()
        }
    }
    
    fileprivate func setupAttributedCaption() {
        
        guard let post = self.post else { return }
        
        let attributedText = NSMutableAttributedString(string: post.user.username, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: " \(post.caption)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
        
        attributedText.append(NSAttributedString(string: "\n\n", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 4)]))
        
        attributedText.append(NSAttributedString(string: "1 week ago", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        
        captionLabel.attributedText = attributedText
    }
    
    let userProfileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 40/2
        iv.clipsToBounds = true
        return iv
    }()
    
    let usernameLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Username"
        lbl.font = UIFont.boldSystemFont(ofSize: 14)
        
        return lbl
    }()
    
    let optionsButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.setTitle("•••", for: .normal)
        button.setTitleColor(.black, for: .normal)
        
        return button
    }()
    
    let photoImageView: CustomImageView = {
        let iv = CustomImageView()
        
        iv.backgroundColor = UIColor.lightGray
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        
        return iv
    }()
    
    let likeButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.setImage(#imageLiteral(resourceName: "like_unselected").withRenderingMode(.alwaysOriginal), for: .normal)
        
        return button
    }()
    
    let commentButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.setImage(#imageLiteral(resourceName: "comment").withRenderingMode(.alwaysOriginal), for: .normal)
        
        return button
    }()
    
    let sendButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.setImage(#imageLiteral(resourceName: "send2").withRenderingMode(.alwaysOriginal), for: .normal)
        
        return button
    }()
    
    let bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.setImage(#imageLiteral(resourceName: "ribbon").withRenderingMode(.alwaysOriginal), for: .normal)
        
        return button
    }()
    
    let captionLabel: UILabel = {
        let lbl = UILabel()
    
        lbl.numberOfLines = 0
        
        return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // backgroundColor = .gray
        
        addSubview(userProfileImageView)
        addSubview(usernameLabel)
        addSubview(optionsButton)
        addSubview(photoImageView)
        
        userProfileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        
        usernameLabel.anchor(top: topAnchor, left: userProfileImageView.rightAnchor, bottom: photoImageView.topAnchor, right: optionsButton.leftAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        optionsButton.anchor(top: topAnchor, left: nil, bottom: photoImageView.topAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 44, height: 0)
        
        photoImageView.anchor(top: userProfileImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        photoImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
        
        setupActionButtons()
        
        addSubview(captionLabel)
        captionLabel.anchor(top: likeButton.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
    }
    
    fileprivate func setupActionButtons() {
        let stackView = UIStackView(arrangedSubviews: [likeButton, commentButton, sendButton])
        
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        stackView.anchor(top: photoImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 120, height: 50)
        
        addSubview(bookmarkButton)
        bookmarkButton.anchor(top: photoImageView.bottomAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 40, height: 50)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
