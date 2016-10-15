//
//  ImageViewController.swift
//  Whisper
//
//  Created by Hayden on 2016/10/15.
//  Copyright © 2016年 unimelb. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {

    var image: UIImage?
    @IBOutlet var imageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.isHidden = false
        
        if let validImage = self.image {
            self.imageView.image = validImage
        }
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
