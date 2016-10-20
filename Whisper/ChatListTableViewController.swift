//
//  ChatListTableViewController.swift
//  Whisper
//
//  Created by Hayden on 2016/10/13.
//  Copyright © 2016年 unimelb. All rights reserved.
//

import UIKit
import Firebase

class ChatListTableViewController: UITableViewController {

    var chatsArray = [ChatRoom]()
    var chatFunctions = ChatFunctions()

    
    var databaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    
    var storageRef: FIRStorage! {
        return FIRStorage.storage()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UINavigationBar.appearance().tintColor = UIColor.white
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.tintColor = UIColor.white
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
        
        fetchChats()
        NotificationCenter.default.addObserver(self, selector: #selector(ChatListTableViewController.fetchChats), name: NSNotification.Name(rawValue: "updateDiscussion"), object: nil)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func fetchChats() {
        chatsArray.removeAll(keepingCapacity: false)

        databaseRef.child("ChatRooms").queryOrdered(byChild: "userId").queryEqual(toValue: FIRAuth.auth()!.currentUser!.uid).observe(.childAdded, with: { (snapshot) in

            // print("\n\n\n\nObserver!\n\n\n\n")
            
            let key = snapshot.key
            let ref = snapshot.ref
            let snap = snapshot.value as! [String: AnyObject]
            let username = snap["username"] as! String
            let other_Username = snap["other_Username"] as! String
            let userId = snap["userId"] as! String
            let other_UserId = snap["other_UserId"] as! String
            let members = snap["members"] as! [String]
            let chatRoomId = snap["chatRoomId"] as! String
            let lastMessage = snap["lastMessage"] as! String
            let userPhotoUrl = snap["userPhotoUrl"] as! String
            let other_UserPhotoUrl = snap["other_UserPhotoUrl"] as! String
            let date = snap["date"] as! NSNumber
            
            var newChat = ChatRoom(username: username, other_Username: other_Username, userId: userId, other_UserId: other_UserId, members: members, chatRoomId: chatRoomId, lastMessage: lastMessage, userPhotoUrl: userPhotoUrl, other_UserPhotoUrl: other_UserPhotoUrl, date: date)
            newChat.ref = ref
            newChat.key = key
            
            self.chatsArray.insert(newChat, at: 0)
            self.tableView.reloadData()
        
        }) { (error) in
            print(error.localizedDescription)
            // let alertView = SCLAlertView()
            // alertView.showError("Chatrooms Error", subTitle: error.localizedDescription)
        }
        
        
        
        databaseRef.child("ChatRooms").queryOrdered(byChild: "other_UserId").queryEqual(toValue: FIRAuth.auth()!.currentUser!.uid).observe(.childAdded, with: { (snapshot) in


            //print("\n\n\n\nObserver!\n\n\n\n")
            let key = snapshot.key
            let ref = snapshot.ref
            let snap = snapshot.value as! [String: AnyObject]
            let username = snap["username"] as! String
            let other_Username = snap["other_Username"] as! String
            let userId = snap["userId"] as! String
            let other_UserId = snap["other_UserId"] as! String
            let members = snap["members"] as! [String]
            let chatRoomId = snap["chatRoomId"] as! String
            let lastMessage = snap["lastMessage"] as! String
            let userPhotoUrl = snap["userPhotoUrl"] as! String
            let other_UserPhotoUrl = snap["other_UserPhotoUrl"] as! String
            let date = snap["date"] as! NSNumber
            
            var newChat = ChatRoom(username: username, other_Username: other_Username, userId: userId, other_UserId: other_UserId, members: members, chatRoomId: chatRoomId, lastMessage: lastMessage, userPhotoUrl: userPhotoUrl, other_UserPhotoUrl: other_UserPhotoUrl, date: date)
            newChat.ref = ref
            newChat.key = key
            
            self.chatsArray.insert(newChat, at: 0)
            self.tableView.reloadData()
            
            
        }) { (error) in
            print(error.localizedDescription)
            // let alertView = SCLAlertView()
            // alertView.showError("Chatrooms Error", subTitle: error.localizedDescription)
        }

        
    }
    
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return chatsArray.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatlistCell", for: indexPath) as! ChatListTableViewCell
        var userPhotoUrlString: String! = ""
        if chatsArray[indexPath.row].userId == FIRAuth.auth()!.currentUser!.uid {
            userPhotoUrlString = chatsArray[indexPath.row].other_UserPhotoUrl!
            cell.usernameLabel.text = chatsArray[indexPath.row].other_Username
        } else {
            userPhotoUrlString = chatsArray[indexPath.row].userPhotoUrl!
            cell.usernameLabel.text = chatsArray[indexPath.row].username
        }
        
        let fromDate = NSDate(timeIntervalSince1970: TimeInterval(chatsArray[indexPath.row].date))
        let toDate = NSDate()
        
        let components = Set<Calendar.Component>([.second, .minute, .hour, .day, .weekOfMonth])
        let differenceOfDate = Calendar.current.dateComponents(components, from: fromDate as Date, to: toDate as Date)
        
        if differenceOfDate.second! <= 0 {
            cell.dateLabel.text = "now"
            cell.fireImage.image = UIImage(named: "fire-1")
        } else if differenceOfDate.second! > 0 && differenceOfDate.minute! == 0 {
            cell.dateLabel.text = "\(differenceOfDate.second!)s"
            cell.fireImage.image = UIImage(named: "fire-2")
        } else if differenceOfDate.minute! > 0 && differenceOfDate.hour! == 0 {
            cell.dateLabel.text = "\(differenceOfDate.minute!)m"
            cell.fireImage.image = UIImage(named: "fire-3")
        } else if differenceOfDate.hour! > 0 && differenceOfDate.day! == 0 {
            cell.dateLabel.text = "\(differenceOfDate.hour!)h"
            cell.fireImage.image = UIImage(named: "fire-4")
        } else if differenceOfDate.day! > 0 && differenceOfDate.weekOfMonth! == 0 {
            cell.dateLabel.text = "\(differenceOfDate.day!)d"
            cell.fireImage.image = UIImage(named: "fire-5")
        } else if differenceOfDate.weekOfMonth! > 0 {
            cell.dateLabel.text = "\(differenceOfDate.weekOfMonth!)w"
            cell.fireImage.image = UIImage(named: "fire-6")
        }
        
        //let components: CFCalendarUnit = [.second, .minute, .hour, .day, .weekOfMonth]
        //let differenceOfDate = Calendar.current
        //let differenceOfDate = CFCalendar.currentCalendar().components(components, fromDate: fromDate, toDate: toDate, option: [])
        
        //if differenceOfDate.second
        
        
        
        // Observe the message of each chat room. Then update the last message label.
        databaseRef.child("ChatRooms").child(chatsArray[indexPath.row].chatRoomId).child("lastMessage").observe(.value, with: { (snapshot) in
            cell.lastMessageLabel.text = (snapshot.value as? String)!
        })
        
        
        if let urlString = userPhotoUrlString {
            storageRef.reference(forURL: urlString).data(withMaxSize: 256*1024, completion: { (imgData, error) in
                if let error = error {
                    let alertView = SCLAlertView()
                    alertView.showError("Chatrooms Error", subTitle: error.localizedDescription)
                } else {
                    DispatchQueue.main.async {
                        if let data = imgData {
                            cell.userImageView.image = UIImage(data: data)
                        }
                    }
                }
            })
        }

        // Configure the cell...

        
        cell.userImageView.layer.cornerRadius = 30.0
        cell.userImageView.clipsToBounds = true
        
        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            self.chatsArray[indexPath.row].ref?.removeValue()
            self.chatsArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentUser = User(username: FIRAuth.auth()!.currentUser!.displayName!, userId: FIRAuth.auth()!.currentUser!.uid, photoUrl: "\(FIRAuth.auth()!.currentUser!.photoURL!)")
        var otherUser: User!
        if currentUser.uid == chatsArray[indexPath.row].userId {
            otherUser = User(username: chatsArray[indexPath.row].other_Username, userId: chatsArray[indexPath.row].other_UserId, photoUrl: chatsArray[indexPath.row].other_UserPhotoUrl)
        } else {
            otherUser = User(username: chatsArray[indexPath.row].username, userId: chatsArray[indexPath.row].userId, photoUrl: chatsArray[indexPath.row].userPhotoUrl)
        }
        
        chatFunctions.startChat(user1: currentUser, user2: otherUser)

        
        performSegue(withIdentifier: "goToChatFromChats", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
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
    @IBAction func goBackToCam(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "goToChatFromChats" {
            let chatVC = segue.destination as! ChatViewController
            chatVC.senderId = FIRAuth.auth()!.currentUser!.uid
            chatVC.senderDisplayName = FIRAuth.auth()!.currentUser!.displayName
            chatVC.chatRoomId = chatFunctions.chatRoom_id
        }
    }


}
