//
//  MemoryTableViewController.swift
//  Whisper
//
//  Created by Hayden on 2016/10/16.
//  Copyright © 2016年 unimelb. All rights reserved.
//

import UIKit
import Firebase

class MemoryTableViewController: UITableViewController {

    var postArray = [Post]()
    let databaseRef = FIRDatabase.database().reference()
    let storageRef = FIRStorage.storage()
    
    var selectedRow = 1
    var selectedIndexPath: IndexPath!
    var imageArray = [UIImage]()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchPosts()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseRef.child("Posts").child(FIRAuth.auth()!.currentUser!.uid).removeAllObservers()
    }

    func fetchPosts() {
        let postRef = databaseRef.child("Posts").child(FIRAuth.auth()!.currentUser!.uid)
        postRef.observe(.value, with: { (snapshot) in
            var allPosts = [Post]()
            for post in snapshot.children {
                let newPost = Post(snapshot: post as! FIRDataSnapshot)
                if newPost.isPrivate == true {
                    allPosts.append(newPost)
                }
            }
            allPosts.sort(by: { (post1, post2) -> Bool in
                post1.timestamp.doubleValue > post2.timestamp.doubleValue
            })
            self.postArray = allPosts
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

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "memoryCell", for: indexPath) as! MemoryTableViewCell
        let date = Date(timeIntervalSince1970: Double(postArray[indexPath.row].timestamp))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm a 'on' MMMM dd, yyyy"
        cell.timeLabel.text = dateFormatter.string(from: date)

        storageRef.reference(forURL: postArray[indexPath.row].imageUrl).data(withMaxSize: 6*1024*1024, completion: { (imgData, error) in
            if let error = error {
                let alertView = SCLAlertView()
                alertView.showError("OOPS", subTitle: error.localizedDescription)
            } else {
                DispatchQueue.main.async {
                    if let data = imgData {
                        let img = UIImage(data: data)!
                        cell.imageLabel.image = img
                        //self.imageArray.append(img)
                    }
                }
            }
        })

        // Configure the cell...

        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 258
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        selectedIndexPath = indexPath
        performSegue(withIdentifier: "postFromMemory", sender: nil)
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
        if segue.identifier == "postFromMemory" {
            let selectedCell = tableView.cellForRow(at: selectedIndexPath) as! MemoryTableViewCell
            let destinationVC = segue.destination as! PostViewController
            destinationVC.timeout = postArray[selectedRow].timeout as Int
            
            if selectedCell.imageLabel.image != nil {
                destinationVC.img = selectedCell.imageLabel.image!
            }
        }
    }
 

}
