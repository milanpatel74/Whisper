//
//  ImageViewController.swift
//  Whisper
//
//  Created by Hayden on 2016/10/15.
//  Copyright © 2016年 unimelb. All rights reserved.
//

import UIKit
import imglyKit

class ImageViewController: UIViewController, ToolStackControllerDelegate {

    var image: UIImage?
    @IBOutlet var imageView: UIImageView!
    //var windowTintColor: UIColor!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.isHidden = false

        // Set the appearance of editor.
//        if let window = UIApplication.shared.delegate?.window! {
//            windowTintColor = window.tintColor
//            window.tintColor = UIColor.white
//        }

        if let validImage = self.image {
            self.imageView.image = validImage
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        if let window = UIApplication.shared.delegate?.window! {
//            window.tintColor = windowTintColor
//        }
    }
    
    @IBAction func editImageTapped(_ sender: UIButton) {
        if let editedImage = image {
            let photoEditViewController = PhotoEditViewController(photo: editedImage)
            let toolStackController = ToolStackController(photoEditViewController: photoEditViewController)
            toolStackController.delegate = self
            present(toolStackController, animated: true, completion: nil)
        }
        
    }
    
    func toolStackController(_ toolStackController: ToolStackController, didFinishWith image: UIImage) {
        imageView.image = image
        self.image = image
        dismiss(animated: true, completion: nil)
    }
    
    func toolStackControllerDidFail(_ toolStackController: ToolStackController) {
        print("fail")
    }
    
    func toolStackControllerDidCancel(_ toolStackController: ToolStackController) {
        print("Cancel")
        dismiss(animated: true, completion: nil)
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
