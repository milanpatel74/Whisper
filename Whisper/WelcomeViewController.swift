//
//  WelcomeViewController.swift
//  Whisper
//
//  Created by Hayden on 2016/10/5.
//  Copyright © 2016年 unimelb. All rights reserved.
//

import UIKit
import Firebase

class WelcomeViewController: UIViewController {

    @IBOutlet var loginButton: UIButton!
    @IBOutlet var signupButton: UIButton!
    @IBOutlet var welcomeText: UILabel!
    
 
    
    override func viewDidLoad() {
        super.viewDidLoad()

        welcomeText.text = ""
        welcomeText.textColor = UIColor.white
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style:
            .plain, target: nil, action: nil)

        
        if let user = FIRAuth.auth()?.currentUser {
            print("Hello, ", user.email!, "\n")
            //self.present(snapContainer, animated: true, completion: nil)
        } else {
            print("\nNo current user\n")
        }
        
        // Do any additional setup after loading the view.

        let translate = CGAffineTransform(translationX: 0, y: 600)
        loginButton.transform = translate
        signupButton.transform = translate
        

        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.7, options: [], animations: {
            self.loginButton.transform = CGAffineTransformFromString("login")
            }, completion: nil)
        
        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.7, options: [], animations: {
            self.signupButton.transform = CGAffineTransformFromString("signup")
            }, completion: nil)
        
        UIView.animate(withDuration: 0.4, delay: 1.0, options: [], animations: {
            self.loginButton.backgroundColor = UIColor.init(red: 46/255, green: 171/255, blue: 103/255, alpha: 1)
            }, completion: nil)
        
        
        //try! FIRAuth.auth()!.signOut()

        
        
        
        
        
        
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.barTintColor = whisper_green


        
//        FIRAuth.auth()!.addStateDidChangeListener() { auth, user in
//            if user != nil {
//                //self.present(snapContainer, animated: true, completion: nil)
//                print("\n\n\n\n")
//                print(user!.email!)
//                print(user!.photoURL)
//                print(user!.displayName)
//                print(user!.uid)
//            }
//        }

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
