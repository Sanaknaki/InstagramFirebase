//
//  UserSearchController.swift
//  Instagram
//
//  Created by Ali Sanaknaki on 2020-03-30.
//  Copyright © 2020 Ali Sanaknaki. All rights reserved.
//

import UIKit
import Firebase

class UserSearchController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
        
    lazy var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Search"
        
        sb.barTintColor = .gray
        
        // Search bar has a textfield in it, and to edit it, must call it through this call.
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        
        sb.delegate = self
        
        return sb
    }()
    
    // Filter results
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {
            self.filteredUsers = self.users
        } else {
            self.filteredUsers = self.users.filter { (user) -> Bool in
                return user.username.lowercased().contains(searchText.lowercased())
            }
        }
        
        self.collectionView.reloadData()
    }
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .white
        
        // Add search bar to the navigation bar
        let navBar = navigationController?.navigationBar
        navBar?.addSubview(searchBar)
        searchBar.anchor(top: navBar?.topAnchor, left: navBar?.leftAnchor, bottom: navBar?.bottomAnchor, right: navBar?.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        
        collectionView?.register(UserSearchCell.self, forCellWithReuseIdentifier: cellId)
        
        // Allow to bounce it aka scroll up/down whenever
        collectionView.alwaysBounceVertical = true
        
        fetchUsers()
    }
    
    var filteredUsers = [User]()
    var users = [User]()
    
    fileprivate func fetchUsers() {
        print("Fetching users")
        
        // Get to users node
        let ref = Database.database().reference().child("users")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            // Snapshot is a dict
            // print(snapshot.value)
            
            guard let dicts = snapshot.value as? [String: Any] else { return }
            
            dicts.forEach({ (key: String, value: Any) in
                guard let userDict = value as? [String: Any] else { return }
                
                let user = User(uid: key, dict: userDict)
                self.users.append(user)
            })
            
            // Alphabetically sorted
            self.users.sort(by: { (u1, u2) -> Bool in
                return u1.username.compare(u2.username) == .orderedAscending
            })
            
            self.filteredUsers = self.users
            
            self.collectionView.reloadData()
            
        }) { (err) in
            print("Failed to fetch users for search: ", err)
        }
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserSearchCell
        
        cell.user = filteredUsers[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: view.frame.width, height: 60)
    }
}
