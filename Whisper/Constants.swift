//
//  Constants.swift
//  Whisper
//
//  Created by Hayden on 2016/10/6.
//  Copyright © 2016年 unimelb. All rights reserved.
//

import Foundation
import UIKit

// Define some colors that frequently used in Whisper.
let whisper_red = UIColor.init(red: 214/255, green: 69/255, blue: 65/255, alpha: 1)
let whisper_green = UIColor.init(red: 46/255, green: 171/255, blue: 103/255, alpha: 1)



// Define the snapchat scroll view.
let storyboard = UIStoryboard(name: "Main", bundle: nil)
// The left ViewController is the chat view.
let left = storyboard.instantiateViewController(withIdentifier: "left")
// The middle ViewController is the camera view.
let middle = storyboard.instantiateViewController(withIdentifier: "middle")
// The right ViewController is the story view.
let right = storyboard.instantiateViewController(withIdentifier: "right")
// The top ViewController is the profile view.
let top = storyboard.instantiateViewController(withIdentifier: "top")
// The bottom ViewController is the memory view.
let bottom = storyboard.instantiateViewController(withIdentifier: "bottom")
// Add all VCs to a snap container.
let snapContainer = SnapContainerViewController.containerViewWith(left,
                                                                  middleVC: middle,
                                                                  rightVC: right,
                                                                  topVC: top,
                                                                  bottomVC: bottom)


