//
//  MyProfileViewController.swift
//  Whisper
//
//  Created by Hayden on 2016/10/12.
//  Copyright © 2016年 unimelb. All rights reserved.
//

import UIKit
import Firebase


class MyProfileViewController: UIViewController {

    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var username: UILabel!
    @IBOutlet var email: UILabel!
    @IBOutlet var country: UILabel!
    @IBOutlet var biography: UILabel!
    
    var user: User!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        userImageView.layer.cornerRadius = 65
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Load the user data from database.
        let userRef = FIRDatabase.database().reference().child("users")
        
        //let userRefRef = userRef.child((FIRAuth.auth()?.currentUser?.uid)!)
        
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
        //userRef.observe(.value, with: { (snapshot) in
            
//            for userInfo in snapshot.children {
//                self.user = User(snapshot: userInfo as! FIRDataSnapshot)
//            }
            
            self.user = User(snapshot: snapshot.childSnapshot(forPath: (FIRAuth.auth()?.currentUser?.uid)!) )
            
            if let user = self.user {
                self.email.text = user.email
                self.username.text = user.username
                self.biography.text = user.biography
                self.country.text = user.country
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logout(_ sender: UIButton) {
        do {
            try FIRAuth.auth()?.signOut()
            if FIRAuth.auth()?.currentUser == nil {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Login") as! LoginViewController
                present(vc, animated: true, completion: nil)
            }
        } catch let error as NSError {
            let alertView = SCLAlertView()
            alertView.showError("OOPS", subTitle: error.localizedDescription)
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
