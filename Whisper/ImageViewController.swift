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
    var timeout: NSNumber = 5

    
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var timeSlider: UISlider!
    
    
    
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
    
    
    @IBAction func timeSliderChanged(_ sender: AnyObject) {
        // sender可以是任何类型，所以此处要强制转换
        let slider = sender as! UISlider
        // 让Slider只能选择整型
        let i = Int(slider.value)
        slider.value = Float(i)
        timeLabel.text = "\(i)"
        timeout = i as NSNumber
    }
    
    @IBAction func sendButtonTapped(_ sender: AnyObject) {
    }
    
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func close(segue:UIStoryboardSegue) {
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "sendPhoto" {
            let resultVC = segue.destination as! SendPostTableViewController
            if let img = image {
                resultVC.passedImage = img
                resultVC.passedTimeout = timeout
            }
        }

    }
    

}
