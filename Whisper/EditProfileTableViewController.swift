//
//  EditProfileTableViewController.swift
//  Whisper
//
//  Created by Hayden on 2016/10/14.
//  Copyright © 2016年 unimelb. All rights reserved.
//

import UIKit
import Firebase

class EditProfileTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    // The root reference of Firebase realtime database.
    var databaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    
    // The root reference of Firebase storage.
    var storageRef: FIRStorageReference! {
        return FIRStorage.storage().reference()
    }
    
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var biographyTextField: UITextField!
    
    var pickerView: UIPickerView!
    var countryArrays = [String]()
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userImageView.layer.cornerRadius = userImageView.layer.frame.height/2
        
        usernameTextField.delegate = self
        emailTextField.delegate = self
        countryTextField.delegate = self
        biographyTextField.delegate = self
        
        // Retrieving all the countries, Sorting and Storing them inside countryArrays
        for code in NSLocale.isoCountryCodes as [String]{
            let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
            let name = NSLocale(localeIdentifier: "en_EN").displayName(forKey: NSLocale.Key.identifier, value: id) ?? "Country not found for code: \(code)"
            
            countryArrays.append(name)
            //            countryArrays.sorted(by: { (name1, name2) -> Bool in
            //                name1 < name2
            //            })
        }
        
        pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        //pickerView.tintColor = UIColor.black
        pickerView.backgroundColor = UIColor.darkGray
        countryTextField.inputView = pickerView
        
        
        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(EditProfileTableViewController.choosePictureAction))
        imageTapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(imageTapGesture)
        userImageView.isUserInteractionEnabled = true
        userImageView.addGestureRecognizer(imageTapGesture)
        
        
        // Creating Tap Gesture to dismiss Keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(EditProfileTableViewController.dismissKeyboard(gesture:)))
        tapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGesture)
        
        // Creating Swipe Gesture to dismiss Keyboard
        let swipDown = UISwipeGestureRecognizer(target: self, action: #selector(EditProfileTableViewController.dismissKeyboard(gesture:)))
        swipDown.direction = .down
        view.addGestureRecognizer(swipDown)
        
        fetchCurrentuserInfo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    func fetchCurrentuserInfo() {
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
                self.emailTextField.text = user.email
                self.usernameTextField.text = user.username
                self.biographyTextField.text = user.biography
                self.countryTextField.text = user.country
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
    
    
    @IBAction func updateAction(_ sender: AnyObject) {
        
        let email = emailTextField.text!.lowercased()
        // Remove the space in the email field.
        let finalEmail = email.trimmingCharacters(in: NSCharacterSet.whitespaces)
        let country = countryTextField.text!
        let biography = biographyTextField.text!
        let username = usernameTextField.text!
        let userPicture = userImageView.image
        
        let imageData = UIImageJPEGRepresentation(userPicture!, 0.8)!
        if finalEmail.isEmpty || finalEmail.isEmpty || country.isEmpty || biography.isEmpty || username.isEmpty {
            // Present an alert view to user
            let alertView = SCLAlertView()
            alertView.showError("OOPS", subTitle: "It seems like you did not fill correctly the information.")
        } else {
            let imagePath = "profileImage\(user.uid)/userPic.jpg"
            
            let imageRef = storageRef.child(imagePath)
            
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            
            imageRef.put(imageData, metadata: metadata) { (metadata, error) in
                if error == nil {
                    
                    let changeRequest = FIRAuth.auth()!.currentUser!.profileChangeRequest()
                    changeRequest.displayName = username
                    
                    if let photoURL = metadata!.downloadURL(){
                        changeRequest.photoURL = photoURL
                    }
                    
                    changeRequest.commitChanges(completion: { (error) in
                        if error == nil {
                            let user = FIRAuth.auth()!.currentUser!
                            // Save user information to the realtime database.
                            let userInfo = ["email": user.email!, "username": username, "country": country, "biography": biography, "uid": user.uid, "photoURL": "\(user.photoURL!)"]
                            // The URL is converted to String type using "\(user.photoURL)"
                            
                            let userRef = self.databaseRef.child("users").child(user.uid)
                            userRef.setValue(userInfo, withCompletionBlock: { (error, ref) in
                                if error == nil {
                                    self.navigationController!.popToRootViewController(animated: true)
                                } else {
                                    let alertView =  SCLAlertView()
                                    alertView.showError("Update Error", subTitle: error!.localizedDescription)
                                }
                            })
                        } else {
                            // Has an error.
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

    
    // Dismissing the Keyboard with the Return Keyboard Button
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        usernameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        countryTextField.resignFirstResponder()
        biographyTextField.resignFirstResponder()
        return true
    }
    
    func choosePictureAction() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = true
        
        let alertController = UIAlertController(title: "Add a Picture", message: "Choose From", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            pickerController.sourceType = .camera
            self.present(pickerController, animated: true, completion: nil)
            
        }
        let photosLibraryAction = UIAlertAction(title: "Photos Library", style: .default) { (action) in
            pickerController.sourceType = .photoLibrary
            self.present(pickerController, animated: true, completion: nil)
            
        }
        
        let savedPhotosAction = UIAlertAction(title: "Saved Photos Album", style: .default) { (action) in
            pickerController.sourceType = .savedPhotosAlbum
            self.present(pickerController, animated: true, completion: nil)
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        alertController.addAction(cameraAction)
        alertController.addAction(photosLibraryAction)
        alertController.addAction(savedPhotosAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.userImageView.image = image
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
    //        self.dismiss(animated: true, completion: nil)
    //        self.userImageView.image = image
    //    }
    
    // Dismissing all editing actions when User Tap or Swipe down on the Main View
    func dismissKeyboard(gesture: UIGestureRecognizer){
        self.view.endEditing(true)
    }
    
    
    
    
    // MARK: - Picker view data source
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return countryArrays[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        countryTextField.text = countryArrays[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countryArrays.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let title = NSAttributedString(string: countryArrays[row], attributes: [NSForegroundColorAttributeName: UIColor.white])
        return title
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            self.choosePictureAction()
            print("Select Picture")
        }
    }
    

}
