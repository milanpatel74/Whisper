//
//  PostViewController.swift
//  Whisper
//
//  Created by Hayden on 2016/10/16.
//  Copyright © 2016年 unimelb. All rights reserved.
//

import UIKit

class PostViewController: UIViewController {

    
    @IBOutlet var postImage: UIImageView!
    var timeout = 20
    var img: UIImage!
    
    private var timer: DispatchSourceTimer?
    //var pageStepTime: DispatchTimeInterval = .seconds(20)
    
    // deadline 结束时间
    // interval 时间间隔
    // leeway  时间精度
    func setTheTimer() {
        timer = DispatchSource.makeTimerSource(queue: .main)
        timer?.scheduleRepeating(deadline: .now() + DispatchTimeInterval.seconds(timeout), interval: DispatchTimeInterval.seconds(timeout))
        timer?.setEventHandler {
            //self.dismiss(animated: true, completion: nil)
            if self.navigationController != nil {
                self.navigationController!.popViewController(animated: true)
                
            }
            //let _ = self.navigationController?.popViewController(animated: true)
            
            //self.dismiss(animated: true, completion: nil)
            
        }
        // 启动定时器
        timer?.resume()
    }
    
    func deinitTimer() {
        if let time = self.timer {
            time.cancel()
            timer = nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UINavigationBar.appearance().tintColor = UIColor.white
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.tintColor = UIColor.white
        
        if let image = img {
            postImage.image = image
        }

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setTheTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        deinitTimer()
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
