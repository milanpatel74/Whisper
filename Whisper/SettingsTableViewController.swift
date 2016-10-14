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
    



    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
