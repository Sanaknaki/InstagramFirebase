//
//  CommentsController.swift
//  Instagram
//
//  Created by Ali Sanaknaki on 2020-03-31.
//  Copyright © 2020 Ali Sanaknaki. All rights reserved.
//

import UIKit
import Firebase

class CommentsController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var post: Post?
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Comments"
        
        collectionView.backgroundColor = .red
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        collectionView.register(CommentCell.self, forCellWithReuseIdentifier: cellId)
        
        fetchComments()
    }
    
    var comments = [Comment]()
    
    fileprivate func fetchComments() {
        guard let postId = self.post?.id else { return }
        let ref = Database.database().reference().child("comments").child(postId)
        ref.observe(.childAdded, with: { (snapshot) in
            
            guard let dict = snapshot.value as? [String: Any] else { return }
            
            let comment = Comment(dictionary: dict)
            self.comments.append(comment)
            
            self.collectionView.reloadData()
            
        }) { (err) in
            print("Failed to observe comments")
        }
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
        return CGSize(width: view.frame.width, height: 50)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        tabBarController?.tabBar.isHidden = false
    }
    
    lazy var containerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.frame = CGRect(x: 0, y: 0, width: 100, height: 70)
        
        let submitButton = UIButton(type: .system)
        submitButton.setTitle("Submit", for: .normal)
        submitButton.setTitleColor(.black, for: .normal)
        submitButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        submitButton.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        
        containerView.addSubview(commentTextField)
        containerView.addSubview(submitButton)
        
        commentTextField.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: submitButton.leftAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        submitButton.anchor(top: containerView.topAnchor, left: nil, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 50, height: 0)
        
        return containerView
    }()
    
    let commentTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Comment"
        
        return textField
    }()
    
    @objc func handleSubmit() {
        print("Submitting: ", commentTextField.text ?? "")
        
        guard let uid = Auth.auth().currentUser?.uid else { return } // Grab the user uid of the person who posted it
        
        let postId = self.post?.id ?? ""
        let values = ["text": commentTextField.text ?? "", "creationDate": Date().timeIntervalSince1970, "uid": uid] as [String: Any]
        
        Database.database().reference().child("comments").child(postId).childByAutoId().updateChildValues(values) { (err, ref) in
            if let err = err {
                print("Failed to insert comment : ", err)
                return
            }
            
            print("Succesfully created comment!")
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
