//
//  SettingsTableViewController.swift
//  Whisper
//
//  Created by Hayden on 2016/10/14.
//  Copyright © 2016年 unimelb. All rights reserved.
//

import UIKit
import Firebase

class SettingsTableViewController: UITableViewController {

    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var userBioLabel: UILabel!
    
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userImageView.layer.cornerRadius = userImageView.layer.frame.width/2

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let userRef = FIRDatabase.database().reference().child("users")
        
        //let userRefRef = userRef.child((FIRAuth.auth()?.currentUser?.uid)!)
        
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.user = User(snapshot: snapshot.childSnapshot(forPath: (FIRAuth.auth()?.currentUser?.uid)!) )
            
            if let user = self.user {
                self.usernameLabel.text = user.username
                self.userBioLabel.text = user.biography
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
        }) { (error) in
            let alertView = SCLAlertView()
            alertView.showError("BBOOPS", subTitle: error.localizedDescription)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 && indexPath.row == 0 {
            // This is a sensitive operation, show an alert first.
            let deleteAlertView = SCLAlertView()
            deleteAlertView.addButton("Delete", action: {
                self.deleteAccount()
            })
            deleteAlertView.showWarning("Warning", subTitle: "Are you sure that you want to delete your account?")
        } else if indexPath.section == 2 && indexPath.row == 1 {
            resetPassword()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // This is the function to reset the user password.
    func resetPassword() {
        let email = FIRAuth.auth()!.currentUser!.email!
        AuthenticationService().resetPassword(email: email)
    }
    
    // This is the function to delete the account.
    func deleteAccount() {
        
        let currentUser = FIRAuth.auth()!.currentUser!
        let currentUserref = FIRDatabase.database().reference().child("users").child(currentUser.uid)
        let profileStorageRef = FIRStorage.storage().reference().child("profileImage\(currentUser.uid)/userPic.jpg")
        
        // 思路：先删除数据库中的User，再删除Storage中的多媒体数据，最后删除账户
        
        // 第一步：删除数据库中的资料
        // 正常删除账户之后，删除数据库资料和Storage
        currentUserref.removeValue(completionBlock: { (error, ref) in
            if let error = error {
                // 删除用户资料出错，提示出错
                DispatchQueue.main.async {
                let alertView = SCLAlertView()
                alertView.showError("Delete Database Error", subTitle: error.localizedDescription)
                }
            } else {
                // 没有出错
                print("User data in database is deleted successfully.")
            }
        })
        // 第二步：删除Storage中的媒体数据
        profileStorageRef.delete(completion: { (error) in
            if let error = error {
                // 如果出错
                DispatchQueue.main.async {
                let alertView = SCLAlertView()
                alertView.showError("Delete Storage Error", subTitle: error.localizedDescription)
                }
            } else {
                print("User storage is deleted successfully.")
            }
        })
        // 第三步：删除Authtication账户
        FIRAuth.auth()?.currentUser?.delete(completion: { (error) in
            if let error = error {
                // 删除账户出错，提示出错
                DispatchQueue.main.async {
                let alertView = SCLAlertView()
                alertView.showError("Delete Account Error", subTitle: error.localizedDescription)
                }
            } else {
                print("User account is deleted successfully.")
            }
        })
        DispatchQueue.main.async {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Login") as! LoginViewController
            self.present(vc, animated: true, completion: nil)
        }

        
        
        
        // 这里有问题：如果长时间没有logoff，将会报错，只删除了数据库中的User而没有删除Auth中的账号。
        // 另外：没有删除Storage中对应的条目。
//        currentUserref.observeSingleEvent(of: .value, with: { (snapshot) in
//            let currentUser = User(snapshot: snapshot)
//            currentUser.ref?.removeValue(completionBlock: { (error, ref) in
//                if error == nil {
//                    FIRAuth.auth()?.currentUser?.delete(completion: { (error) in
//                        if error == nil {
//                            // Delete user and log off.
//                            print("Account successfully deleted!")
//                            DispatchQueue.main.async {
//                                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Login") as! LoginViewController
//                                self.present(vc, animated: true, completion: nil)
//                            }
//                        } else {
//                            let alertView = SCLAlertView()
//                            alertView.showError("Delete User Error1", subTitle: error!.localizedDescription)
//                        }
//                    })
//                } else {
//                    let alertView = SCLAlertView()
//                    alertView.showError("Delete User Error2", subTitle: error!.localizedDescription)
//                }
//            })
//        }) { (error) in
//            let alertView = SCLAlertView()
//            alertView.showError("Delete User Error3", subTitle: error.localizedDescription)
//        }
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
