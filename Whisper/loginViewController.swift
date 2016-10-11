//
//  loginViewController.swift
//  Whisper
//
//  Created by Hayden on 2016/10/6.
//  Copyright © 2016年 unimelb. All rights reserved.
//

import UIKit
import Firebase
import KRProgressHUD

class loginViewController: UIViewController {

    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var forgetButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.isNavigationBarHidden = false
        
        

        //navigationController?.navigationBar.barTintColor = UIColor.init(red: 46/255, green: 171/255, blue: 103/255, alpha: 1)
        

        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginDidTapped(_ sender: AnyObject) {
        KRProgressHUD.show(progressHUDStyle: .whiteColor)
        FIRAuth.auth()!.signIn(withEmail: username.text!, password: password.text!) { (user, error) in
            if error == nil {
                print("\nLogin Success!\n")

                KRProgressHUD.showSuccess()
                KRProgressHUD.dismiss()
            } else {

                // Change the appearance when the login operation fails.
                print("\nLogin Fail!\n")
                //print(error)
                print(error!.localizedDescription)
                //print(error.debugDescription)
                KRProgressHUD.showError()
                KRProgressHUD.dismiss()
                self.loginButton.titleLabel?.text = "RETRY"
                self.loginButton.backgroundColor = whisper_red
                self.forgetButton.titleLabel?.textColor = whisper_red
                self.navigationController?.navigationBar.barTintColor = whisper_red
                self.navigationController?.navigationBar.topItem?.title = "LOGIN FAULURE"
            }
        }
        
        
    }
    
    @IBAction func forgetPassword(_ sender: AnyObject) {
        
        let alert = UIAlertController(title: "Forget Password", message: "Please enter your username to get a password reset email", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Sent", style: .default) { action in
            let email = alert.textFields![0].text!
            
            FIRAuth.auth()?.sendPasswordReset(withEmail: email) { error in
                if error != nil {
                    // A reset error happened.
                    print("An error occurs")
                    print(error?.localizedDescription)
                } else {
                    // Password reset email sent.
                    print("An email has been sent")
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        alert.addTextField { textEmail in
            textEmail.placeholder = "Enter your email"
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
        
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
