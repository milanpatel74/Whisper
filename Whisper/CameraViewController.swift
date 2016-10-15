//
//  CameraViewController.swift
//  Whisper
//
//  Created by Hayden on 2016/10/2.
//  Copyright © 2016年 unimelb. All rights reserved.
//

import UIKit
import CameraManager

class CameraViewController: UIViewController {

    // MARK: - Constants

    let cameraManager = CameraManager()
    
    // MARK: - @IBOutlets

    @IBOutlet var cameraView: UIView!
    @IBOutlet var cameraButton: UIButton!
    @IBOutlet var flashModeButton: UIButton!
    @IBOutlet var askForPermissionsButton: UIButton!
    @IBOutlet var askForPermissionsLabel: UILabel!
    @IBOutlet var captureMode: UIButton!
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //captureMode.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        
        cameraManager.showAccessPermissionPopupAutomatically = false
        captureMode.setImage(UIImage(named: "mode-video"), for: UIControlState())
        
        askForPermissionsButton.isHidden = true
        askForPermissionsLabel.isHidden = true
        
        let currentCameraState = cameraManager.currentCameraStatus()
        
        if currentCameraState == .notDetermined {
            askForPermissionsButton.isHidden = false
            askForPermissionsLabel.isHidden = false
        } else if (currentCameraState == .ready) {
            addCameraToView()
        }
        if !cameraManager.hasFlash {
            flashModeButton.isEnabled = false
            flashModeButton.setImage(UIImage(named: "flash-off"), for: UIControlState())
            //flashModeButton.setTitle("No flash", for: UIControlState())
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.isHidden = true
        cameraManager.resumeCaptureSession()
        cameraManager.cameraOutputMode = CameraOutputMode.stillImage

    }

    fileprivate func addCameraToView()
    {
        cameraManager.addPreviewLayerToView(cameraView, newCameraOutputMode: CameraOutputMode.videoWithMic)
        cameraManager.showErrorBlock = { [weak self] (erTitle: String, erMessage: String) -> Void in
            
            let alertController = UIAlertController(title: erTitle, message: erMessage, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (alertAction) -> Void in  }))
            
            self?.present(alertController, animated: true, completion: nil)
        }
    }

    @IBAction func changeFlashMode(_ sender: UIButton) {
        
        switch (cameraManager.changeFlashMode()) {
        case .off:
            sender.setImage(UIImage(named: "flash-off"), for: UIControlState())
        case .on:
            sender.setImage(UIImage(named: "flash-on"), for: UIControlState())
        case .auto:
            sender.setImage(UIImage(named: "flash-auto"), for: UIControlState())
        }
        
    }
    
    @IBAction func recordButtonTapped(_ sender: UIButton) {
        
        switch (cameraManager.cameraOutputMode) {
        case .stillImage:
            cameraManager.capturePictureWithCompletion({ (image, error) -> Void in
                if let errorOccured = error {
                    self.cameraManager.showErrorBlock("Error occurred", errorOccured.localizedDescription)
                }
                else {
                    let vc: ImageViewController? = self.storyboard?.instantiateViewController(withIdentifier: "ImageVC") as? ImageViewController
                    if let validVC: ImageViewController = vc {
                        if let capturedImage = image {
                            validVC.image = capturedImage
                            self.navigationController?.pushViewController(validVC, animated: true)
                        }
                    }
                }
            })
        case .videoWithMic, .videoOnly:
            sender.isSelected = !sender.isSelected
            //sender.setTitle(" ", for: UIControlState.selected)
            //sender.backgroundColor = sender.isSelected ? UIColor.red : UIColor.green
            if sender.isSelected {
                sender.setImage(UIImage(named: "capture-video-on"), for: UIControlState())
                cameraManager.startRecordingVideo()
            } else {
                sender.setImage(UIImage(named: "capture-video-off"), for: UIControlState())
                cameraManager.stopVideoRecording({ (videoURL, error) -> Void in
                    if let errorOccured = error {
                        self.cameraManager.showErrorBlock("Error occurred", errorOccured.localizedDescription)
                    }
                })
            }
        }

        
    }
    
    @IBAction func outputModeButtonTapped(_ sender: UIButton) {
        
        cameraManager.cameraOutputMode = cameraManager.cameraOutputMode == CameraOutputMode.videoWithMic ? CameraOutputMode.stillImage : CameraOutputMode.videoWithMic
        switch (cameraManager.cameraOutputMode) {
        case .stillImage:
            cameraButton.isSelected = false
            cameraButton.setImage(UIImage(named: "capture-photo"), for: UIControlState())
            //cameraButton.backgroundColor = UIColor.green
            captureMode.setImage(UIImage(named: "mode-photo"), for: UIControlState())
        case .videoWithMic, .videoOnly:
            cameraButton.setImage(UIImage(named: "capture-video-off"), for: UIControlState())
            captureMode.setImage(UIImage(named: "mode-video"), for: UIControlState())
        }

    }
    
    @IBAction func changeCameraDevice(_ sender: UIButton) {
        
        cameraManager.cameraDevice = cameraManager.cameraDevice == CameraDevice.front ? CameraDevice.back : CameraDevice.front
        switch (cameraManager.cameraDevice) {
        case .front:
            sender.setImage(UIImage(named: "camera-front"), for: UIControlState())
        case .back:
            sender.setImage(UIImage(named: "camera-end"), for: UIControlState())
        }
        
    }
    
    @IBAction func askForCameraPermissions(_ sender: UIButton) {
        
        cameraManager.askUserForCameraPermission({ permissionGranted in
            self.askForPermissionsButton.isHidden = true
            self.askForPermissionsLabel.isHidden = true
            self.askForPermissionsButton.alpha = 0
            self.askForPermissionsLabel.alpha = 0
            if permissionGranted {
                self.addCameraToView()
            }
        })
        
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
