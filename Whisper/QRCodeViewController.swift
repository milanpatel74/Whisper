//
//  QRCodeViewController.swift
//  Whisper
//
//  Created by Hayden on 2016/10/15.
//  Copyright © 2016年 unimelb. All rights reserved.
//

import UIKit
import Firebase
import KRProgressHUD

class QRCodeViewController: UIViewController {

    @IBOutlet var scanView: UIView!
    @IBOutlet var codeView: UIImageView!
    @IBOutlet var infoLabel: UILabel!
    @IBOutlet var searchButton: UIButton!
    
    let scanner = QRCode()
    let uemail = FIRAuth.auth()!.currentUser!.email
    let photoUrl = FIRAuth.auth()!.currentUser!.photoURL
    
    var searchedUser: User!
    var searchedEmail = ""
    let databaseRef = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        scanner.prepareScan(scanView) { (stringValue) -> () in
            print(stringValue)
            self.searchedEmail = stringValue
            self.infoLabel.text = stringValue
            self.searchButton.isHidden = false
            self.scanner.strokeColor = UIColor.yellow
        }
        scanner.scanFrame = scanView.bounds
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchButton.isHidden = true
        codeView.isHidden = false
        do {
            let imgData = try Data(contentsOf: photoUrl!)
            let avatar = UIImage(data: imgData)
            codeView.image = QRCode.generateImage(uemail!, avatarImage: avatar)
        } catch {
            print(error)
        }
        
    }
    
    @IBAction func startScan(_ sender: AnyObject) {
        scanner.startScan()
        codeView.isHidden = true
    }
    
    @IBAction func endScan(_ sender: AnyObject) {
        scanner.stopScan()
        scanner.clearDrawLayer()
        codeView.isHidden = false
    }
    
    @IBAction func searchButtonTapped(_ sender: AnyObject) {
        KRProgressHUD.show()
        let userRef = databaseRef.child("users")
        userRef.queryOrdered(byChild: "email").queryEqual(toValue: searchedEmail).observeSingleEvent(of: .childAdded, with: { (snapshot) in
            
            self.searchedUser = User(snapshot: snapshot)
            KRProgressHUD.dismiss()
            self.performSegue(withIdentifier: "scanToAdd", sender: nil)
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "scanToAdd" {
            let resultVC = segue.destination as! SearchResultViewController
            resultVC.searchedUser = searchedUser
        }
        
    }
    

}
