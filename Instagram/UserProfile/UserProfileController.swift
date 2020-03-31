//
//  userProfileController.swift
//  Instagram
//
//  Created by Ali Sanaknaki on 2020-03-28.
//  Copyright © 2020 Ali Sanaknaki. All rights reserved.
//

import UIKit
import Firebase

class UserProfileController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UserProfileHeaderDelegate {
    
    let cellId = "cellId"
    let homePostCellId = "homePostCellId"
    
    var userId: String?
    
    var isGridView = true
    
    func didChangeToGridView() {
        isGridView = true
        collectionView.reloadData()
    }
    
    func didChangeToListView() {
        isGridView = false
        collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = .white
        
        fetchUser()
        
        // Have to register the header/footer in the collection view giving it the Id
        collectionView.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerId")
        
        // Have to register the cellView
        collectionView.register(UserProfilePhotoCell.self, forCellWithReuseIdentifier: cellId)
        
        // Registering the listView cell post style
        collectionView.register(HomePostCell.self, forCellWithReuseIdentifier: homePostCellId)
        
        setupLogOutButton()
        
    }
    
    fileprivate func setupLogOutButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "gear").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleLogOut))
    }
    
    var posts = [Post]()
    var isFinishedPaging = false
    
    fileprivate func paginatePosts() {
        print("Start paging for more posts.")
        
        // Get user of profile, could be you, could be someone you searching
        guard let uid = self.user?.uid else { return }
        let ref = Database.database().reference().child("posts").child(uid)
        
        // Limit results by toFirst
        // let query = ref.queryOrderedByKey().queryStarting(atValue: "").queryLimited(toFirst: 5)
        var query = ref.queryOrderedByKey()
        
        // Grab last cell posted
        if posts.count > 0 {
            let value = posts.last?.id
            query = query.queryStarting(atValue: value)
        }
        
        query.queryLimited(toFirst: 5).observeSingleEvent(of: .value, with: { (snapshot) in
            
            // All of the remaining objects in snapshot
            guard var allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
            
            if allObjects.count < 4 {
                self.isFinishedPaging = true
            }
            
            if self.posts.count > 0 {
                allObjects.removeFirst()
            }

            guard let user = self.user else { return }
            
            allObjects.forEach ({ (snapshot) in
                // print(snapshot.key)
                
                guard let dict = snapshot.value as? [String: Any] else { return }
                var post = Post(user: user, dictionary: dict)
                
                post.id = snapshot.key // have to capture post id
                self.posts.append(post)
            })
            
//            self.posts.forEach { (post) in
//                <#code#>
//            }
            
            self.collectionView.reloadData()
        }) { (err) in
            print("Failed to paginate for posts: ", err)
        }
    }
    
    fileprivate func fetchOrderedPosts() {
        guard let uid = self.user?.uid else { return }
        let ref = Database.database().reference().child("posts").child(uid)
        
        // Order by 'creationDate' while also watching the list of posts
        ref.queryOrdered(byChild: "creationDate").observe(.childAdded, with: { (snapshot) in
            guard let dict = snapshot.value as? [String: Any] else { return }
            guard let user = self.user else { return } // Grabbed from the var in fetchUser()
            
            let post = Post(user: user, dictionary: dict)

            // Put newest photo ordered by creation date to the FRONT of list,
            self.posts.insert(post, at: 0)
            
            self.collectionView.reloadData()
        }) { (err) in
            print("Failed to fetch ordered posts: ", err)
        }
    }
    
    @objc func handleLogOut() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
            do {
                try Auth.auth().signOut()
                
                // Want to wrap the login view controller in navControl to not push the registration view onto the stack
                let loginController = LoginController()
                let navController = UINavigationController(rootViewController: loginController)
                
                self.present(navController, animated: true, completion: nil)
            } catch let signOutErr {
                print("Failed to sign out: ", signOutErr)
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    // Number of cells
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    // Cell styling
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Fire off paginate call
        if indexPath.item == self.posts.count - 1 && !isFinishedPaging {
            paginatePosts()
        }
        
        // If it's grid, return RegularPhotoCell, else return the HomePostCell
        if isGridView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserProfilePhotoCell
            
            cell.post = posts[indexPath.item]
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homePostCellId, for: indexPath) as! HomePostCell
            
            cell.post = posts[indexPath.item]
            
            return cell
        }
    }
    
    // Right/Left spacing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    // Up/Down spacing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    // Size of each cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if isGridView {
            let width = (view.frame.width-2) / 3
            
            return CGSize(width: width, height: width)
        } else {
            // Username & userProfileImageView, it's a 1:1 image aspect ratio for the image
            var height: CGFloat = 40 + 8 + 8
            height += view.frame.width
            
            // For like/comment/send button group
            height += 50
            
            // For caption
            height += 60
            
            return CGSize(width: view.frame.width, height: height)
            
        }
    }
    
    // Build the header, give it an Id to be altered
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        // Downcast to be the UserProfileHeader
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerId", for: indexPath) as! UserProfileHeader
        
        //
        header.user = self.user
        header.delegate = self
        
        return header
    }
    
    // Render out the size of the header section
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    
    // To be called in fetchUser() and header
    var user: User?
    
    // Only accessible in this view with 'fileprivate'
    // Fetch current user, either yourself or userID
    fileprivate func fetchUser() {
        
        let uid = userId ?? Auth.auth().currentUser?.uid ?? ""
        
        // Call the extension
        Database.fetchUserWithUID(uid: uid) { (user) in
            self.user = user
            
            self.navigationItem.title = self.user?.username
            
            self.collectionView?.reloadData()
            
            // Get posts when you get the right user
            self.paginatePosts()
        }
    }
}
