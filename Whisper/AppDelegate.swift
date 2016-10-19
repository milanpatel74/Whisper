//
//  AppDelegate.swift
//  Whisper
//
//  Created by Hayden on 2016/10/2.
//  Copyright © 2016年 unimelb. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FIRApp.configure()
        // If the user has signed in, and haven't signed out, then move to the main view directlly.
        logUser()
        UIApplication.shared.statusBarStyle = .lightContent
        return true
    }
    
    func  logUser() {
        if FIRAuth.auth()!.currentUser != nil {

            print(FIRAuth.auth()!.currentUser?.uid)
            
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
            
            self.window?.rootViewController = snapContainer
            self.window?.rootViewController?.automaticallyAdjustsScrollViewInsets = false
            //self.automaticallyAdjustsScrollViewInsets = false
            self.window?.makeKeyAndVisible()
            
        }
        
        
        
        
    }
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

