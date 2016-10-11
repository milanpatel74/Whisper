//
//  SignupViewController.swift
//  Whisper
//
//  Created by Hayden on 2016/10/6.
//  Copyright © 2016年 unimelb. All rights reserved.
//

import UIKit
import Firebase

class SignupViewController: UIViewController {
    
    @IBOutlet var viewww: UIView!
    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.isNavigationBarHidden = false
        //navigationController?.navigationBar.barTintColor = UIColor.init(red: 46/255, green: 171/255, blue: 103/255, alpha: 1)
        


    }


    @IBAction func signupDidTapped(_ sender: AnyObject) {
        FIRAuth.auth()!.createUser(withEmail: username.text!, password: password.text!, completion: {
            (user, error) in
            if error == nil {
                FIRAuth.auth()!.signIn(withEmail: self.username.text!, password: self.password.text!)
            }
        })
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
