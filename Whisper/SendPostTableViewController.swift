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
    
    @IBOutlet var imageView: UIImageView!
    
    var storageRef = FIRStorage.storage().reference()
    var databaseRef = FIRDatabase.database().reference()
    
    var passedImage: UIImage!
    var passedTimeout: NSNumber!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = passedImage
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
        return 5
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = "Hello"

        return cell
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
