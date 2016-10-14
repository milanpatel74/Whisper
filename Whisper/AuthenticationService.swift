//
//  AuthenticationService.swift
//  WhatsAppClone
//
//  Created by Frezy Stone Mboumba on 7/20/16.
//  Copyright © 2016 Frezy Stone Mboumba. All rights reserved.
//

import Foundation
import Firebase


struct AuthenticationService {
    
    // The root reference of Firebase realtime database.
    var databaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    
    // The root reference of Firebase storage.
    var storageRef: FIRStorageReference! {
        return FIRStorage.storage().reference()
    }
    
    // 3 - We save the user info in the Database
    private func saveInfo(user: FIRUser!, username: String, password: String, country: String, biography: String){
        
        // Save user information to the realtime database.
        let userInfo = ["email": user.email!, "username": username, "country": country, "biography": biography, "uid": user.uid, "photoURL": "\(user.photoURL!)"]
        // The URL is converted to String type using "\(user.photoURL)"
        
        let userRef = databaseRef.child("users").child(user.uid)
        userRef.setValue(userInfo)
        signIn(email: user.email!, password: password)
    }
    
    // 4 - We sign in the User
    func signIn(email: String, password: String){
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            if error == nil {
                // If the user is signed in successfully.
                if let user = user {
                    print("\(user.displayName) has signed in successfully")
                    print("\(user.email!) has signed in successfuly")
                    let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDel.logUser()
                }
            } else {
                // If sign in error occurs, show a alert and tell the error description.
                let alertView =  SCLAlertView()
                alertView.showError("Sign In Failed", subTitle: error!.localizedDescription)
            }
        }) // Authentication sign in ends.
    }
    
    // 1 - We create firstly a New User
    func signUp(email: String, username: String, password: String, country: String, biography: String, data: Data!){
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            if error == nil {
                self.setUserInfo(user: user, username: username, password: password, country: country, biography: biography, data: data)
            }else {
                DispatchQueue.main.async {
                    let alertView =  SCLAlertView()
                    alertView.showError("😁OOPS😁", subTitle: error!.localizedDescription)
                }
            }
        })
        
    }
    
    func resetPassword(email: String){
        
        FIRAuth.auth()?.sendPasswordReset(withEmail: email, completion: { (error) in
            if error == nil {
                
                DispatchQueue.main.async {
                    let alertView =  SCLAlertView()
                    alertView.showSuccess("Resetting Password", subTitle: "An email containing the different information on how to reset your password has been sent to \(email)")
                }
                
                
                
            }else {
                
                let alertView =  SCLAlertView()
                alertView.showError("😁OOPS😁", subTitle: error!.localizedDescription)
            }
        })
        
    }
    
    // 2 - We set the User Info
    private func setUserInfo(user: FIRUser!, username: String, password: String, country: String, biography: String, data: Data!){
        
        let imagePath = "profileImage\(user.uid)/userPic.jpg"
        
        let imageRef = storageRef.child(imagePath)
        
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpeg"
        
        imageRef.put(data, metadata: metadata) { (metadata, error) in
            if error == nil {
                
                let changeRequest = user.profileChangeRequest()
                changeRequest.displayName = username
                
                if let photoURL = metadata!.downloadURL(){
                    changeRequest.photoURL = photoURL
                }
                
                changeRequest.commitChanges(completion: { (error) in
                    if error == nil {
                        
                        self.saveInfo(user: user, username: username, password: password, country: country, biography: biography)
                    }
                    else {
                        
                        let alertView =  SCLAlertView()
                        alertView.showError("😁OOPS😁", subTitle: error!.localizedDescription)

                    }
                    
                })
            }else {
                
                let alertView =  SCLAlertView()
                alertView.showError("😁OOPS😁", subTitle: error!.localizedDescription)

                
            }
        }
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
