//
//  InputEmailViewController.swift
//  Whisper
//
//  Created by Hayden on 2016/10/16.
//  Copyright © 2016年 unimelb. All rights reserved.
//

import UIKit
import Firebase
import KRProgressHUD

class InputEmailViewController: UIViewController {

    @IBOutlet var emailField: CustomizableTextField!
    @IBOutlet var startSearchButton: CustomizableButton!
    
    var searchedUser: User!
    var searchedEmail = ""
    let databaseRef = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UINavigationBar.appearance().tintColor = UIColor.white
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.tintColor = UIColor.white
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func searchButtonTapped(_ sender: AnyObject) {
        let email = emailField.text!.lowercased()
        // Remove the space in the email field.
        let finalEmail = email.trimmingCharacters(in: NSCharacterSet.whitespaces)
        
        if finalEmail.isEmpty {
            // Present an alert view to user
            let alertView = SCLAlertView()
            alertView.showError("OOPS", subTitle: "It seems like you did not fill correctly the email.")
        } else {
            searchedEmail = finalEmail
            KRProgressHUD.show()
            let userRef = databaseRef.child("users")
            userRef.queryOrdered(byChild: "email").queryEqual(toValue: searchedEmail).observeSingleEvent(of: .childAdded, with: { (snapshot) in
                // print("\n\n----------")
                // print(snapshot.exists())
                // print("----------\n\n")
                self.searchedUser = User(snapshot: snapshot)
                KRProgressHUD.dismiss()
                self.performSegue(withIdentifier: "emailToAdd", sender: nil)
                
            }) { (error) in
                print(error.localizedDescription)
            }
        }
        KRProgressHUD.dismiss()
        
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "emailToAdd" {
            let resultVC = segue.destination as! SearchResultViewController
            resultVC.searchedUser = searchedUser
        }
        
    }
    

}
