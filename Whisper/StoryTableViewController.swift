//
//  StoryTableViewController.swift
//  Whisper
//
//  Created by Hayden on 2016/10/17.
//  Copyright © 2016年 unimelb. All rights reserved.
//

import UIKit
import Firebase

class StoryTableViewController: UITableViewController, UISearchResultsUpdating {
    
    let popNavi = PopTransitionAnimator()
    var searchController:UISearchController!

    let databaseRef = FIRDatabase.database().reference()
    let storageRef = FIRStorage.storage()
    
    var friendList = [String]()
    var postArray = [Post]()
    var selectedIndexPath: IndexPath!
    
    var searchResults = [Post]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UINavigationBar.appearance().tintColor = UIColor.white
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.tintColor = UIColor.white
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        searchController = UISearchController(searchResultsController: nil)
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search stories..."
        searchController.searchBar.tintColor = UIColor.white
        searchController.searchBar.barTintColor = UIColor(red: 0.0/255.0, green:
            128.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        
        
        fetchFriendPostList()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.databaseRef.child("Posts").removeAllObservers()
    }

    func fetchFriendPostList() {
        // 加载好友列表
        postArray.removeAll()
        self.friendList.append(FIRAuth.auth()!.currentUser!.uid)

        let friendsRef = databaseRef.child("Friendships").child(FIRAuth.auth()!.currentUser!.uid)
        friendsRef.observeSingleEvent(of: .value, with: { (snapshot) in
            //print(snapshot)
            for friend in snapshot.children {
                let snap = friend as! FIRDataSnapshot
                self.friendList.append(snap.key)
            }
            self.fetchPosts(friendList: self.friendList)
            //print(self.friendList)
            //self.tableView.reloadData()
            
        }) { (error) in
//            let alertView = SCLAlertView()
//            alertView.showError("OOPS", subTitle: error.localizedDescription)
        }
    }
    
    func fetchPosts(friendList: [String]) {
        print("\nStart fetching posts from friend list!\n")
        self.postArray.removeAll()
        // 获取单个好友的Posts
        for friendId in friendList {
            let postRef = self.databaseRef.child("Posts").child(friendId)
            postRef.observe(.childAdded, with: { (snapshot) in
                //print(snapshot)
                let newPost = Post(snapshot: snapshot)
                if newPost.isPrivate == false {
                    print("Hi, new post from ", newPost.username)
                    self.postArray.append(newPost)
                    // print(self.postArray)
                }
                
                self.postArray.sort(by: { (post1, post2) -> Bool in
                    post1.timestamp.doubleValue > post2.timestamp.doubleValue
                })
                self.tableView.reloadData()
            }) { (error) in
//                let alertView = SCLAlertView()
//                alertView.showError("OOPS", subTitle: error.localizedDescription)
            }
        }
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
            return postArray.count
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "storyPostCell", for: indexPath) as! StoryTableViewCell
        
        let cellPost = (searchController.isActive) ? searchResults[indexPath.row] : postArray[indexPath.row]
        
        cell.username.text = cellPost.username
        cell.timeoutLabel.text = "\(cellPost.timeout!)s"
        let date = Date(timeIntervalSince1970: Double(postArray[indexPath.row].timestamp))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm a 'on' MMMM dd"
        cell.timeLabel.text = dateFormatter.string(from: date)
        
        storageRef.reference(forURL: cellPost.imageUrl).data(withMaxSize: 6*1024*1024, completion: { (imgData, error) in
            if let error = error {
//                let alertView = SCLAlertView()
//                alertView.showError("OOPS", subTitle: error.localizedDescription)
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

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if searchController.isActive {
            return false
        } else {
            return true
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        // Social Sharing Button
        let shareAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Share", handler: { (action, indexPath) -> Void in
            let defaultText = "I find a great story in Whisper!\n" + self.postArray[indexPath.row].username
            
            let cell = self.tableView.cellForRow(at: indexPath) as! StoryTableViewCell
            if let imageToShare = cell.storyImage.image {
                let activityController = UIActivityViewController(activityItems:
                    [defaultText, imageToShare], applicationActivities: nil)
                self.present(activityController, animated: true, completion: nil)
            }
            //if let imageToShare = self.tableView.cellForRow(at: indexPath)?.story.image {
            
            //}
            
            print("\n\nShare")
            
        })
        
        // Lock button
        let lockAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Lock",handler: { (action, indexPath) -> Void in
            let ownerUid = self.postArray[indexPath.row].senderId!
            if ownerUid == FIRAuth.auth()!.currentUser!.uid {
                // Delete the row from the data source
                if let pRef = self.postArray[indexPath.row].ref {
                    pRef.child("isPrivate").setValue(true)
                }
                self.postArray.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
                print("\n\nLocked")
                
            } else {
                let alertView = SCLAlertView()
                alertView.showNotice("Notice", subTitle: "You can only lock your own story.")
            }
        })
        
        
        // Delete button
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Delete",handler: { (action, indexPath) -> Void in
            let ownerUid = self.postArray[indexPath.row].senderId!
            if ownerUid == FIRAuth.auth()!.currentUser!.uid {
                // Delete the row from the data source
                if let pRef = self.postArray[indexPath.row].ref {
                    pRef.removeValue()
                }
                self.postArray.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
                print("\n\nDelete")

            } else {
                let alertView = SCLAlertView()
                alertView.showNotice("Notice", subTitle: "You can only delete your own story.")
            }
        })
        
        shareAction.backgroundColor = UIColor(red: 48.0/255.0, green: 173.0/255.0, blue: 99.0/255.0, alpha: 1.0)
        deleteAction.backgroundColor = UIColor(red: 202.0/255.0, green: 202.0/255.0, blue: 203.0/255.0, alpha: 1.0)
        lockAction.backgroundColor = UIColor(red: 247.0/255.0, green: 202.0/255.0, blue: 24.0/255.0, alpha: 1.0)
        
        return [deleteAction, lockAction, shareAction]
    }

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

    @IBAction func goBackToCam(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    func filterContent(for searchText: String) {
        searchResults = postArray.filter({ (post) -> Bool in
            if let name = post.username {
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
        
        if segue.identifier == "postFromStory" {
            let selectedCell = tableView.cellForRow(at: selectedIndexPath) as! StoryTableViewCell
            let destinationVC = segue.destination as! PostViewController
            destinationVC.transitioningDelegate = popNavi
            destinationVC.timeout = postArray[selectedIndexPath.row].timeout as Int
            
            if selectedCell.storyImage.image != nil {
                destinationVC.img = selectedCell.storyImage.image!
            }
        }
        
        
        
    }
 

}
