//
//  SearchResultViewController.swift
//  Whisper
//
//  Created by Hayden on 2016/10/16.
//  Copyright © 2016年 unimelb. All rights reserved.
//

import UIKit
import Firebase

class SearchResultViewController: UIViewController {
    
    var searchedUser: User!
    var friendList = [String: Bool]()
    
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var username: UILabel!
    @IBOutlet var email: UILabel!
    @IBOutlet var country: UILabel!
    @IBOutlet var biography: UILabel!
    @IBOutlet var addButton: UIButton!
    
    let databaseRef = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
                
        if let user = self.searchedUser {
            username.text = user.username
            email.text = user.email
            country.text = user.country
            biography.text = user.biography
            checkFriendList(user: user)
            FIRStorage.storage().reference(forURL: user.photoURL).data(withMaxSize: 1*512*1024, completion: { (imgData, error) in
                if let error = error {
                    let alertView = SCLAlertView()
                    alertView.showError("AAOOPS", subTitle: error.localizedDescription)
                } else {
                    if let data = imgData {
                        self.userImageView.image = UIImage(data: data)
                    }
                }
            })
        }
        
    }
    
    func checkFriendList(user: User) {
        // 加载好友列表
        let friendsRef = databaseRef.child("Friendships").child(FIRAuth.auth()!.currentUser!.uid)
        friendsRef.observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
            for friend in snapshot.children {
                let snap = friend as! FIRDataSnapshot
                self.friendList[snap.key] = true
                //print(snap.key)
                //print(friend)
            }
            print(self.friendList)
            if self.friendList[user.uid] != nil {
                self.addButton.backgroundColor = whisper_red
                self.addButton.isEnabled = false
                DispatchQueue.main.async {
                    let alertView = SCLAlertView()
                    alertView.showWarning("Warning", subTitle: "You are already friend with \(user.username!).")
                }
                

                
            } else if self.searchedUser.uid == FIRAuth.auth()!.currentUser!.uid {
                
                self.addButton.backgroundColor = whisper_red
                self.addButton.isEnabled = false
                DispatchQueue.main.async {
                    let alertView = SCLAlertView()
                    alertView.showWarning("Warning", subTitle: "You are already friend with \(user.username!).")
                }

            }
            
        }) { (error) in
            let alertView = SCLAlertView()
            alertView.showError("OOPS", subTitle: error.localizedDescription)
        }
    }
    
    @IBAction func AddFriendTapped(_ sender: AnyObject) {
        if let user = searchedUser {
            let friendshipRef = databaseRef.child("Friendships").child(FIRAuth.auth()!.currentUser!.uid)
            
            friendshipRef.child(user.uid).setValue(true)
            let alertView = SCLAlertView()
            alertView.showSuccess("Success", subTitle: "\(user.username!) is your friend now")
            self.navigationController!.popToRootViewController(animated: true)
        }
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
