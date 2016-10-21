//
//  UserTableViewController.swift
//  Whisper
//
//  Created by Hayden on 2016/10/13.
//  Copyright © 2016年 unimelb. All rights reserved.
//



import UIKit
import Firebase

class UsersTableViewController: UITableViewController, UISearchResultsUpdating {

    var searchController:UISearchController!
    
    
    var userArray = [User]()
    var chatFunctions = ChatFunctions()
    var friendList = [String: Bool]()
    
    var searchResults = [User]()
    
    var databaseRef: FIRDatabaseReference! { return FIRDatabase.database().reference() }
    var storageRef: FIRStorage! { return FIRStorage.storage() }
    
    
    @IBAction func closeTapped(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UINavigationBar.appearance().tintColor = UIColor.white
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.tintColor = UIColor.white
        
        searchController = UISearchController(searchResultsController: nil)
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search users..."
        searchController.searchBar.tintColor = UIColor.black
        searchController.searchBar.barTintColor = UIColor(red: 255.0/255.0, green:
            128.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        
        
        //tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        fetchFriendList()
        loadUsers()
    }
    
    func fetchFriendList() {
        // 加载好友列表
        let friendsRef = databaseRef.child("Friendships").child(FIRAuth.auth()!.currentUser!.uid)
        friendsRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            for friend in snapshot.children {
                let snap = friend as! FIRDataSnapshot
                self.friendList[snap.key] = true
                //print(snap.key)
                //print(friend)
            }
            
        }) { (error) in
//                let alertView = SCLAlertView()
//                alertView.showError("OOPS", subTitle: error.localizedDescription)
        }
    }
    
    func loadUsers() {
        let userRef = databaseRef.child("users")
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            var allUsers = [User]()
            for user in snapshot.children {
                let newUser = User(snapshot: user as! FIRDataSnapshot)
                
                if newUser.uid != FIRAuth.auth()!.currentUser!.uid {
                    if self.friendList[newUser.uid] == true {
                        allUsers.append(newUser)
                    }
                }
            }
            self.userArray = allUsers.sorted(by: { (user1, user2) -> Bool in
                user1.username < user2.username
            })
            self.tableView.reloadData()

            
            
        }) { (error) in
//            let alertView = SCLAlertView()
//            alertView.showError("OOPS", subTitle: error.localizedDescription)
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if searchController.isActive {
            return searchResults.count
        } else {
            return userArray.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "usersCell", for: indexPath) as! UsersTableViewCell
        
        let user = (searchController.isActive) ? searchResults[indexPath.row] : userArray[indexPath.row]
        
        cell.usernameLabel.text = user.username
        cell.userCountryLabel.text = user.country!
        storageRef.reference(forURL: user.photoURL!).data(withMaxSize: 6*1024*1024, completion: { (imgData, error) in
            if let error = error {
//                let alertView = SCLAlertView()
//                alertView.showError("OOPS", subTitle: error.localizedDescription)
            } else {
                DispatchQueue.main.async {
                    if let data = imgData {
                        cell.userImageView.image = UIImage(data: data)
                    }
                }
                
            }
        })
        
        // Configure the cell...

        cell.userImageView.layer.cornerRadius = 30.0
        cell.userImageView.clipsToBounds = true

        
        return cell
    }
 
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentUser = User(username: FIRAuth.auth()!.currentUser!.displayName!, userId: FIRAuth.auth()!.currentUser!.uid, photoUrl: "\(FIRAuth.auth()!.currentUser!.photoURL!)")
        chatFunctions.startChat(user1: currentUser, user2: userArray[indexPath.row])
        
        performSegue(withIdentifier: "goToChatFromFriends", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if searchController.isActive {
            return false
        } else {
            return true
        }
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let user = userArray[indexPath.row]
            let friendRef = databaseRef.child("Friendships").child(FIRAuth.auth()!.currentUser!.uid)
            let deleteAlertView = SCLAlertView()
            deleteAlertView.addButton("Delete", action: {
                friendRef.child(user.uid).removeValue()
                self.userArray.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            })
            deleteAlertView.showWarning("Warning", subTitle: "Are you sure that you want to delete your friend \(user.username)?")
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    func filterContent(for searchText: String) {
        searchResults = userArray.filter({ (user) -> Bool in
            if let name = user.username {
                let isMatch = name.localizedCaseInsensitiveContains(searchText)
                return isMatch
            }
            return false
        })
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterContent(for: searchText)
            tableView.reloadData()
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "goToChatFromFriends" {
            let chatVC = segue.destination as! ChatViewController
            chatVC.senderId = FIRAuth.auth()!.currentUser!.uid
            chatVC.senderDisplayName = FIRAuth.auth()!.currentUser!.displayName
            chatVC.chatRoomId = chatFunctions.chatRoom_id
        }
    }
 

}
