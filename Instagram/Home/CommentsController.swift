//
//  CommentsController.swift
//  Instagram
//
//  Created by Ali Sanaknaki on 2020-03-31.
//  Copyright © 2020 Ali Sanaknaki. All rights reserved.
//

import UIKit
import Firebase

class CommentsController: UICollectionViewController, UICollectionViewDelegateFlowLayout, CommentInputAccessoryViewDelegate {
    
    var post: Post?
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Comments"
        
        collectionView.backgroundColor = .white
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        collectionView.register(CommentCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView.alwaysBounceVertical = true
        
        collectionView.keyboardDismissMode = .interactive
        
        fetchComments()
    }
    
    var comments = [Comment]()
    
    fileprivate func fetchComments() {
        guard let postId = self.post?.id else { return }
        let ref = Database.database().reference().child("comments").child(postId)
        ref.observe(.childAdded, with: { (snapshot) in
            
            guard let dict = snapshot.value as? [String: Any] else { return }
            
            guard let uid = dict["uid"] as? String else { return }
            
            Database.fetchUserWithUID(uid: uid) { (user) in
                let comment = Comment(user: user, dictionary: dict)
                self.comments.append(comment)
                
                self.collectionView.reloadData()
            }
            
        }) { (err) in
            print("Failed to observe comments")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CommentCell
        
        cell.comment = self.comments[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let dummyCell = CommentCell(frame: frame)
        
        dummyCell.comment = comments[indexPath.item]
        dummyCell.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
        
        // Profile image Height + paddting top + and corrected padding on bottom
        let height = max(40 + 8 + 8, estimatedSize.height)
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        tabBarController?.tabBar.isHidden = false
    }
    
    lazy var containerView: CommentInputAccessoryView = {
        
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let commentInputAccessoryView = CommentInputAccessoryView(frame: frame)
        
        commentInputAccessoryView.delegate = self
        
        return commentInputAccessoryView
    }()
    
    func didSubmit(for comment: String) {
        print("Submitting: ", comment)
        
        guard let uid = Auth.auth().currentUser?.uid else { return } // Grab the user uid of the person who posted it
        
        let postId = self.post?.id ?? ""
        let values = ["text": comment, "creationDate": Date().timeIntervalSince1970, "uid": uid] as [String: Any]
        
        Database.database().reference().child("comments").child(postId).childByAutoId().updateChildValues(values) { (err, ref) in
            if let err = err {
                print("Failed to insert comment : ", err)
                return
            }
            
            print("Succesfully created comment!")
            
            self.containerView.clearCommentTextField()
        }
    }
    
    // Every page in a iOS app has AV that lets you type in info, this will be used for the comments portion of the view
    override var inputAccessoryView: UIView? {
        get {
            return containerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
}
