//
//  UserTableViewController.swift
//  Whisper
//
//  Created by Hayden on 2016/10/13.
//  Copyright © 2016年 unimelb. All rights reserved.
//

import UIKit
import Firebase

class UsersTableViewController: UITableViewController {

    var userArray = [User]()
    var chatFunctions = ChatFunctions()
    
    
    var databaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    
    var storageRef: FIRStorage! {
        return FIRStorage.storage()
    }
    
    
    @IBAction func closeTapped(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)

        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadUsers()
    }
    
    func loadUsers() {
        let userRef = databaseRef.child("users")
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            var allUsers = [User]()
            for user in snapshot.children {
                let newUser = User(snapshot: user as! FIRDataSnapshot)
                
                if newUser.uid != FIRAuth.auth()!.currentUser!.uid {
                    allUsers.append(newUser)
                }
            }
            self.userArray = allUsers.sorted(by: { (user1, user2) -> Bool in
                user1.username < user2.username
            })
            self.tableView.reloadData()

            
            
        }) { (error) in
            let alertView = SCLAlertView()
            alertView.showError("OOPS", subTitle: error.localizedDescription)
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
        return userArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "usersCell", for: indexPath) as! UsersTableViewCell
        
        cell.usernameLabel.text = userArray[indexPath.row].username
        cell.userCountryLabel.text = userArray[indexPath.row].country!
        storageRef.reference(forURL: userArray[indexPath.row].photoURL!).data(withMaxSize: 256*1024, completion: { (imgData, error) in
            if let error = error {
                let alertView = SCLAlertView()
                alertView.showError("OOPS", subTitle: error.localizedDescription)
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
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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
