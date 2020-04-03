//
//  UserProfileHeader.swift
//  Instagram
//
//  Created by Ali Sanaknaki on 2020-03-28.
//  Copyright © 2020 Ali Sanaknaki. All rights reserved.
//

import UIKit
import Firebase

protocol UserProfileHeaderDelegate {
    func didChangeToListView()
    func didChangeToGridView()
}

class UserProfileHeader: UICollectionViewCell {
    
    var delegate: UserProfileHeaderDelegate?
    
    var user: User? {
        didSet {
            guard let profileImageUrl = user?.profileImageUrl else { return }
            profileImageView.loadImage(urlString: profileImageUrl)
            usernamelabel.text = user?.username
            
            setupEditFollowButton()
            renderPostsFollowersFollowing()
        }
    }
    
    // Whether or not show follow or edit profile button
    fileprivate func setupEditFollowButton() {
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        guard let userId = user?.uid else { return }
        
        if currentLoggedInUserId == userId {
            editProfileFollowButton.setTitle("Edit Profile", for: .normal)
        } else {
            
            // Check if following
            let ref = Database.database().reference().child("following").child(currentLoggedInUserId)
            ref.child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
                if let isFollowing = snapshot.value as? Int, isFollowing == 1 {
                    self.editProfileFollowButton.setTitle("Following", for: .normal)
                    self.editProfileFollowButton.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
                    self.editProfileFollowButton.setTitleColor(.black, for: .normal)
                } else {
                    self.setupFollowStyle()
                }
            }, withCancel: { (err) in
                print("Failed to check if following: ", err)
            })
        }
    
    }
    
    @objc func handleEditProfileOrFollow() {
        print("test")
        
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        guard let userId = user?.uid else { return }
        let refFollowing = Database.database().reference().child("following").child(currentLoggedInUserId)
        let refFollowers = Database.database().reference().child("followers").child(userId)
        
        if editProfileFollowButton.titleLabel?.text == "Following" {
            
            // Remove (nodeOfUser) in (userLoggedInID) { (nodeOfUser) }
            refFollowing.removeValue { (err, ref) in
                if let err = err {
                    print("Failed to unfollow user: ", err)
                    return
                }
                
                print("Successfully unfollowed user: ", self.user?.username ?? "")
                
                self.setupFollowStyle()
            }
            
            // Remove (userLoggedInID) in (nodeOfUser) { (userLoggedInID) }
            refFollowers.removeValue { (err, ref) in
                if let err = err {
                    print("Failed to unfollow user: ", err)
                    return
                }
                
                print("Successfully unfollowed user: ", self.user?.username ?? "")
            }
        } else {
            
            // Follow
            let followingValues = [userId: 1]
            refFollowing.updateChildValues(followingValues) { (err, ref) in
                if let err = err {
                    print("Failed to follow user: ", err)
                    return
                }
                
                print("Successfully followed user: ", self.user?.username ?? "")
            }
            
            let followerValues = [currentLoggedInUserId: 1]
            refFollowers.updateChildValues(followerValues) { (err, ref) in
                if let err = err {
                    print("Failed to add to users followers list: ", err)
                    return
                }
                
                print(currentLoggedInUserId + " has successfully added follower to this user " + userId)
            }
            
            self.editProfileFollowButton.setTitle("Following", for: .normal)
            self.editProfileFollowButton.backgroundColor = .white
            self.editProfileFollowButton.setTitleColor(.black, for: .normal)
        }
    }
    
    fileprivate func setupFollowStyle() {
        self.editProfileFollowButton.setTitle("Follow", for: .normal)
        self.editProfileFollowButton.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
        self.editProfileFollowButton.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
        self.editProfileFollowButton.setTitleColor(.white, for: .normal)
    }
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        
        iv.layer.cornerRadius = 80 / 2
        
        iv.clipsToBounds = true
        
        return iv
    }()
    
    lazy var gridButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.setImage(#imageLiteral(resourceName: "grid"), for: .normal)
        
        button.addTarget(self, action: #selector(handleChangeToGridView), for: .touchUpInside)
        
        return button
    }()
    
    @objc func handleChangeToGridView() {
        gridButton.tintColor = .mainBlue()
        listButton.tintColor = UIColor(white: 0, alpha: 0.2)
        delegate?.didChangeToGridView()
    }
    
    lazy var listButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.setImage(#imageLiteral(resourceName: "list"), for: .normal)
        
        button.addTarget(self, action: #selector(handleChangeToListView), for: .touchUpInside)
        
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        
        return button
    }()
    
    @objc func handleChangeToListView() {
        listButton.tintColor = .mainBlue()
        gridButton.tintColor = UIColor(white: 0, alpha: 0.2)
        delegate?.didChangeToListView()
    }
    
    let bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.setImage(#imageLiteral(resourceName: "ribbon"), for: .normal)
        
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        
        return button
    }()
    
    let usernamelabel: UILabel = {
        let label = UILabel()
        
        label.text = "Username"
        
        label.font = UIFont.boldSystemFont(ofSize: 14)
        
        return label
    }()
    
    let postsLabel: UILabel = {
        let label = UILabel()
        
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        
        attributedText.append(NSAttributedString(string: "posts", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
        
        label.attributedText = attributedText
        
        label.numberOfLines = 0
        label.textAlignment = .center
        
        return label
    }()
    
    let followersLabel: UILabel = {
        let label = UILabel()
        
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        
        attributedText.append(NSAttributedString(string: "followers", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
        
        label.attributedText = attributedText
        
        label.numberOfLines = 0
        label.textAlignment = .center
        
        return label
    }()
    
    let followingLabel: UILabel = {
        let label = UILabel()
        
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        
        attributedText.append(NSAttributedString(string: "following", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
        
        label.attributedText = attributedText
        label.numberOfLines = 0
        label.textAlignment = .center
        
        return label
    }()
    
    lazy var editProfileFollowButton: UIButton = {
        let button = UIButton(type: .system)
        
        // button.setTitle("Edit Profile", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 3
        
        button.addTarget(self, action: #selector(handleEditProfileOrFollow), for: .touchUpInside)
        
        return button
        
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(profileImageView)
        
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)
    
        setupBottomToolbar()
        
        addSubview(usernamelabel)
        usernamelabel.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, bottom: gridButton.topAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 0)
        
        setupUserStatsView()
        
        addSubview(editProfileFollowButton)
        editProfileFollowButton.anchor(top: postsLabel.bottomAnchor, left: postsLabel.leftAnchor, bottom: nil, right: followingLabel.rightAnchor, paddingTop: 2, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 34)
    }
    
    // StackView to hold all 3 buttons to order posts
    fileprivate func setupBottomToolbar() {
        
        let topDividerView = UIView()
        topDividerView.backgroundColor = UIColor.lightGray
        
        let bottomDividerView = UIView()
        bottomDividerView.backgroundColor = UIColor.lightGray
        
        let stackView = UIStackView(arrangedSubviews: [gridButton, listButton, bookmarkButton])
        
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        addSubview(topDividerView)
        addSubview(bottomDividerView)
        
        stackView.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        
        topDividerView.anchor(top: stackView.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
        bottomDividerView.anchor(top: stackView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
    }
    
    fileprivate func setupUserStatsView() {
        let stackView = UIStackView(arrangedSubviews: [postsLabel, followersLabel, followingLabel])
        
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        
        stackView.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 50)
    }
    
    fileprivate func renderPostsFollowersFollowing() {
        guard let userId = user?.uid else { return }
            
        let postsRef = Database.database().reference().child("posts").child(userId)
        
        postsRef.observe(.value, with: { (snapshot: DataSnapshot!) in
            let numberOfPosts = String(snapshot.childrenCount) + "\n"
            let label = (snapshot.childrenCount > 1 || snapshot.childrenCount == 0) ? "posts" : "post"
            let attributedText = NSMutableAttributedString(string: numberOfPosts, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
            
            attributedText.append(NSAttributedString(string: label, attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
            
            self.postsLabel.attributedText = attributedText
        })
        
        let followersRef = Database.database().reference().child("followers").child(userId)
                
        followersRef.observeSingleEvent(of: .value, with: { (snapshot: DataSnapshot!) in
            let numberOfFollowers = String(snapshot.childrenCount) + "\n"
            let label = (snapshot.childrenCount > 1 || snapshot.childrenCount == 0) ? "followers" : "follower"
            let attributedText = NSMutableAttributedString(string: numberOfFollowers, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
            
            attributedText.append(NSAttributedString(string: label, attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
            
            self.followersLabel.attributedText = attributedText
        })
        
        let followingRef = Database.database().reference().child("following").child(userId)
        
        followingRef.observeSingleEvent(of: .value, with: { (snapshot: DataSnapshot!) in
            let numberOfFollowing = String(snapshot.childrenCount) + "\n"
            let attributedText = NSMutableAttributedString(string: numberOfFollowing, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
            
            attributedText.append(NSAttributedString(string: "following", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
            
            self.followingLabel.attributedText = attributedText
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
