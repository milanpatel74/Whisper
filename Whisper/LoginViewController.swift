//
//  ViewController.swift
//  Swift Academy
//
//  Created by Frezy Stone Mboumba on 7/8/16.
//  Copyright © 2016 Frezy Stone Mboumba. All rights reserved.
//

import UIKit
import KRProgressHUD

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginView: UIView!
    
    var authService = AuthenticationService()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Setting the delegates for the Textfields
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        // Creating Tap Gesture to dismiss Keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard(gesture:)))
        tapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGesture)
        
        // Creating Swipe Gesture to dismiss Keyboard
        let swipDown = UISwipeGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard(gesture:)))
        swipDown.direction = .down
        view.addGestureRecognizer(swipDown)
        
        view.bringSubview(toFront: loginView)
    }


    
    
    // Dismissing the Keyboard with the Return Keyboard Button
    func dismissKeyboard(gesture: UIGestureRecognizer){
        self.view.endEditing(true)
    }
    
    // Dismissing the Keyboard with the Return Keyboard Button
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
   return true
    }
    
    // Moving the View down after the Keyboard appears
    func textFieldDidBeginEditing(_ textField: UITextField) {
        animateView(up: true, moveValue: 80)
    }

    // Moving the View down after the Keyboard disappears
    func textFieldDidEndEditing(_ textField: UITextField) {
        animateView(up: false, moveValue: 80)
    }
    
    
    // Move the View Up & Down when the Keyboard appears
    func animateView(up: Bool, moveValue: CGFloat){
        
        let movementDuration: TimeInterval = 0.3
        let movement: CGFloat = (up ? -moveValue : moveValue)
        UIView.beginAnimations("animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
        
        
    }
 
    
    @IBAction func loginAction(_ sender: AnyObject) {
        
        let email = usernameTextField.text!.lowercased()
        // Remove the space in the email field.
        let finalEmail = email.trimmingCharacters(in: NSCharacterSet.whitespaces)
        let password = passwordTextField.text!
        
        if finalEmail.isEmpty || password.isEmpty || password.characters.count < 6 {
            // Present an alert view to user
            let alertView = SCLAlertView()
            alertView.showError("OOPS", subTitle: "It seems like you did not fill correctly the information.")
        } else {
            KRProgressHUD.show()
            // If there is no error in the input fields, then sign in the user.
            authService.signIn(email: finalEmail, password: password)
            self.view.endEditing(true)
            KRProgressHUD.dismiss()
        }

    }
    
    @IBAction func close(segue:UIStoryboardSegue) {
    }
    // Unwind Segue Action
    // @IBAction func unwindToLogin(storyboard: UIStoryboardSegue){}
}

