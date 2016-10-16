//
//  StoryTableViewController.swift
//  Whisper
//
//  Created by Hayden on 2016/10/17.
//  Copyright © 2016年 unimelb. All rights reserved.
//

import UIKit
import Firebase

class StoryTableViewController: UITableViewController {

    let databaseRef = FIRDatabase.database().reference()
    let storageRef = FIRStorage.storage()
    
    var friendList = [String]()
    var postArray = [Post]()
    var selectedIndexPath: IndexPath!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchFriendPostList()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    func fetchFriendPostList() {
        // 加载好友列表
        postArray.removeAll()
        print("Hello World\n\n\n")
        
        let friendsRef = databaseRef.child("Friendships").child(FIRAuth.auth()!.currentUser!.uid)
        friendsRef.observeSingleEvent(of: .value, with: { (snapshot) in
            //print(snapshot)
            self.friendList.append(FIRAuth.auth()!.currentUser!.uid)
            for friend in snapshot.children {
                let snap = friend as! FIRDataSnapshot
                self.friendList.append(snap.key)
            }
            print(self.friendList)
            
            // 获取单个好友的Posts
            for friendId in self.friendList {
                let postRef = self.databaseRef.child("Posts").child(friendId)
                postRef.observe(.value, with: { (snapshot) in
                    print(snapshot)
                    for post in snapshot.children {
                        let newPost = Post(snapshot: post as! FIRDataSnapshot)
                        if newPost.isPrivate == false {
                            print("Hi", newPost.senderId)
                            self.postArray.append(newPost)
                            print(self.postArray)
                        }
                    }
                    self.postArray.sort(by: { (post1, post2) -> Bool in
                        post1.timestamp.doubleValue > post2.timestamp.doubleValue
                    })
                    self.tableView.reloadData()
                }) { (error) in
                    let alertView = SCLAlertView()
                    alertView.showError("OOPS", subTitle: error.localizedDescription)
                }
            }

            
            
            self.tableView.reloadData()
            
        }) { (error) in
            let alertView = SCLAlertView()
            alertView.showError("OOPS", subTitle: error.localizedDescription)
        }
    }
    
    
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return postArray.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "storyPostCell", for: indexPath) as! StoryTableViewCell
        
        let cellPost = postArray[indexPath.row]
        cell.username.text = cellPost.username
        cell.timeoutLabel.text = "\(cellPost.timeout!)s"
        let date = Date(timeIntervalSince1970: Double(postArray[indexPath.row].timestamp))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm a 'on' MMMM dd"
        cell.timeLabel.text = dateFormatter.string(from: date)
        
        storageRef.reference(forURL: postArray[indexPath.row].imageUrl).data(withMaxSize: 6*1024*1024, completion: { (imgData, error) in
            if let error = error {
                let alertView = SCLAlertView()
                alertView.showError("OOPS", subTitle: error.localizedDescription)
            } else {
                DispatchQueue.main.async {
                    if let data = imgData {
                        let img = UIImage(data: data)!
                        cell.storyImage.image = img
                        //self.imageArray.append(img)
                    }
                }
            }
        })
        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        performSegue(withIdentifier: "postFromStory", sender: nil)
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
        if segue.identifier == "postFromStory" {
            let selectedCell = tableView.cellForRow(at: selectedIndexPath) as! StoryTableViewCell
            let destinationVC = segue.destination as! PostViewController
            destinationVC.timeout = postArray[selectedIndexPath.row].timeout as Int
            
            if selectedCell.storyImage.image != nil {
                destinationVC.img = selectedCell.storyImage.image!
            }
        }
        
        
        
    }
 

}
