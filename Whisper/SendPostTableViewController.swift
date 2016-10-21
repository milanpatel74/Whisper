//
//  SendPostTableViewController.swift
//  Whisper
//
//  Created by Hayden on 2016/10/16.
//  Copyright © 2016年 unimelb. All rights reserved.
//

import UIKit
import Firebase
import KRProgressHUD


class SendPostTableViewController: UITableViewController {

    var userArray = [User]()
    var friendList = [String: Bool]()
    var chatFunctions = ChatFunctions()
    
    @IBOutlet var imageView: UIImageView!
    
    var storageRef = FIRStorage.storage().reference()
    var databaseRef = FIRDatabase.database().reference()
    
    var passedImage: UIImage!
    var passedTimeout: NSNumber!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = passedImage
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
//            let alertView = SCLAlertView()
//            alertView.showError("OOPS", subTitle: error.localizedDescription)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = userArray[indexPath.row].username

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        KRProgressHUD.show()
        let user = userArray[indexPath.row]
        let userId1 = FIRAuth.auth()!.currentUser!.uid
        let userId2 = user.uid
        var chatRoomId = ""
        let comparison = userId1.compare(userId2!).rawValue
        if comparison < 0 {
            chatRoomId = userId1.appending(userId2!)
        } else {
            chatRoomId = userId2!.appending(userId1)
        }
        
        let currentUser = User(username: FIRAuth.auth()!.currentUser!.displayName!, userId: FIRAuth.auth()!.currentUser!.uid, photoUrl: "\(FIRAuth.auth()!.currentUser!.photoURL!)")
        chatFunctions.startChat(user1: currentUser, user2: userArray[indexPath.row])
        
        if let image = passedImage {
            
            let imagePath = "messageWithMedia\(chatRoomId + NSUUID().uuidString)/photo.jpg"
            let imageRef = storageRef.child(imagePath)
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            
            let imageData = UIImageJPEGRepresentation(image, 0.8)!
            // 将图片数据存放进storage并且返回URL，把URL存Realtime database.
            imageRef.put(imageData, metadata: metadata, completion: { (newMetaData, error) in
                if error == nil {
                    let message = Message(text: "", senderId: currentUser.uid, username: currentUser.username, mediaType: "PHOTO", mediaUrl: "\(newMetaData!.downloadURL()!)")
                    let messageRef = self.databaseRef.child("ChatRooms").child(chatRoomId).child("Messages").childByAutoId()
                    // 将media message存入数据库
                    messageRef.setValue(message.toAnyObject(), withCompletionBlock: { (error, ref) in
                        if error == nil {
                            // 更新last message
                            let lastMessageRef = self.databaseRef.child("ChatRooms").child(chatRoomId).child("lastMessage")
                            
                            let date = Date(timeIntervalSince1970: Double(NSDate().timeIntervalSince1970))
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "'Last Message: 'MM/dd hh:mm a"
                            let dateString = dateFormatter.string(from: date)
                            
                            lastMessageRef.setValue(dateString, withCompletionBlock: { (error, ref) in
                                if error == nil {
                                    // Send a notification
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateDiscussion"), object: nil)
                                } else {
                                    let alertView = SCLAlertView()
                                    alertView.showError("Last Message Error", subTitle: error!.localizedDescription)
                                }
                            })
                            // 更新last time
                            let lastTimeRef = self.databaseRef.child("ChatRooms").child(chatRoomId).child("date")
                            lastTimeRef.setValue(NSDate().timeIntervalSince1970, withCompletionBlock: { (error, ref) in
                                if error == nil {
                                    // Nothing
                                } else {
                                    let alertView = SCLAlertView()
                                    alertView.showError("Last Message Error", subTitle: error!.localizedDescription)
                                }
                            })
//                                let alertView = SCLAlertView()
//                                alertView.showSuccess("Success", subTitle: "Your photo has been sent to \(user.username) successfully!")
                            KRProgressHUD.showSuccess()
                            KRProgressHUD.dismiss()
                            self.dismiss(animated: true, completion: nil)
                            
                        } else {
                            let alertView = SCLAlertView()
                            alertView.showError("Send Message Error", subTitle: error!.localizedDescription)
                        }
                    })
                    
                } else {
                    let alertView = SCLAlertView()
                    alertView.showError("Upload Image Error", subTitle: error!.localizedDescription)
                }
            })
        }

        

    }
    
    
    @IBAction func sendtoMemory(_ sender: AnyObject) {
        
        postImage(isPrivate: true)
        
    }
    
    @IBAction func sendToStory(_ sender: AnyObject) {
        postImage(isPrivate: false)
        
    }
    
    
    func postImage(isPrivate: Bool) {
        
        KRProgressHUD.show()
        
        let user = FIRAuth.auth()!.currentUser!
        let userId = user.uid
        let username = user.displayName!
        
        let imagePath = "Posts/post-\(userId + NSUUID().uuidString).jpg"
        let imageRef = storageRef.child(imagePath)
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let imageData = UIImageJPEGRepresentation(passedImage, 0.8)!
        // 将图片数据存放进storage并且返回URL，把URL存Realtime database.
        imageRef.put(imageData, metadata: metadata, completion: { (newMetaData, error) in
            if error == nil {
                let post = Post(senderId: userId, username: username, timastamp: NSNumber(value: Int(Date().timeIntervalSince1970)), imageUrl: "\(newMetaData!.downloadURL()!)", isPrivate: isPrivate, timeout: self.passedTimeout)
                let postRef = self.databaseRef.child("Posts").child(userId).childByAutoId()
                
                postRef.setValue(post.toAnyObject(), withCompletionBlock: { (error, ref) in
                    if let error = error {
                        let alertView = SCLAlertView()
                        alertView.showError("Send Post Error", subTitle: error.localizedDescription)
                    } else {
                        DispatchQueue.main.async {
                            let alertView = SCLAlertView()
                            if isPrivate {
                                alertView.showSuccess("Success", subTitle: "Your post has been saved in memory!")
                            } else {
                                alertView.showSuccess("Success", subTitle: "Your post has been sent to story!")
                            }
                        }
                        // Back to the camera view.
                        self.dismiss(animated: true, completion: nil)
                        //self.performSegue(withIdentifier: "backToCam", sender: nil)
                    }
                })
                
            } else {
                let alertView = SCLAlertView()
                alertView.showError("Upload Image Error", subTitle: error!.localizedDescription)
            }
        })
        
        KRProgressHUD.dismiss()
        
        
        
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
