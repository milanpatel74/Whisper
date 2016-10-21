//
//  SignupViewController.swift
//  Swift Academy
//
//  Created by Frezy Stone Mboumba on 7/8/16.
//  Copyright © 2016 Frezy Stone Mboumba. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController, UITextFieldDelegate,UIPickerViewDelegate, UIPickerViewDataSource,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var backgroundImage: UIImageView!
    @IBOutlet weak var userImageView: CustomizableImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var biographyTextField: UITextField!
    
    var pickerView: UIPickerView!
    var countryArrays = [String]()
    var authService = AuthenticationService()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        backgroundImage.addSubview(blurEffectView)
        
        // Do any additional setup after loading the view.
        usernameTextField.delegate = self
        passwordTextField.delegate = self
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
        
        // Creating Tap Gesture to dismiss Keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SignupViewController.dismissKeyboard(gesture:)))
        tapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGesture)
        
        // Creating Swipe Gesture to dismiss Keyboard
        let swipDown = UISwipeGestureRecognizer(target: self, action: #selector(SignupViewController.dismissKeyboard(gesture:)))
        swipDown.direction = .down
        view.addGestureRecognizer(swipDown)
    }

    // Signing up the User
    @IBAction func signUpAction(_ sender: AnyObject) {
        
        let email = emailTextField.text!.lowercased()
        // Remove the space in the email field.
        let finalEmail = email.trimmingCharacters(in: NSCharacterSet.whitespaces)
        let password = passwordTextField.text!
        let country = countryTextField.text!
        let biography = biographyTextField.text!
        let username = usernameTextField.text!
        let userPicture = userImageView.image
        
        let imageData = UIImageJPEGRepresentation(userPicture!, 0.8)
        if finalEmail.isEmpty || finalEmail.isEmpty || password.isEmpty || country.isEmpty || biography.isEmpty || username.isEmpty || password.characters.count < 6 {
            // Present an alert view to user
            let alertView = SCLAlertView()
            alertView.showError("OOPS", subTitle: "It seems like you did not fill correctly the information.")
        } else {
            authService.signUp(email: finalEmail, username: username, password: password, country: country, biography: biography, data: imageData!)
        }
        
    }

    // Choosing User Picture
    @IBAction func choosePictureAction(_ sender: AnyObject) {
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
    
    // Dismissing the Keyboard with the Return Keyboard Button
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        countryTextField.resignFirstResponder()
        biographyTextField.resignFirstResponder()
        return true
    }
    
    // Moving the View up after the Keyboard appears
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
    
//    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
//        return 1
//    }

    
}
