//
//  DiscoveryTableViewController.swift
//  Whisper
//
//  Created by Hayden on 2016/10/17.
//  Copyright © 2016年 unimelb. All rights reserved.
//

import UIKit

class DiscoveryTableViewController: UITableViewController {

    var webURL = "www.google.com.au"
    var titles = "Web"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UINavigationBar.appearance().tintColor = UIColor.white
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.tintColor = UIColor.white
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    @IBAction func newsTapped(_ sender: AnyObject) {
        webURL = "https://au.news.yahoo.com"
        titles = "News"
        performSegue(withIdentifier: "showWebView", sender: self)
    }
    
    @IBAction func sportsTapped(_ sender: AnyObject) {
        webURL = "http://www.espn.com.au/afl/"
        titles = "Sports"
        performSegue(withIdentifier: "showWebView", sender: self)
    }
    
    @IBAction func bbcTapped(_ sender: AnyObject) {
        webURL = "http://www.bbc.com/"
        titles = "BBC"
        performSegue(withIdentifier: "showWebView", sender: self)
    }

    @IBAction func EntertainmentTpped(_ sender: AnyObject) {
        webURL = "https://au.be.yahoo.com/entertainment/"
        titles = "Entertainments"
        performSegue(withIdentifier: "showWebView", sender: self)
    }
    
    @IBAction func travelTapped(_ sender: AnyObject) {
        webURL = "https://au.be.yahoo.com/travel/#page1"
        titles = "Travel"
        performSegue(withIdentifier: "showWebView", sender: self)
    }
    
    @IBAction func foodTapped(_ sender: AnyObject) {
        webURL = "https://au.be.yahoo.com/food/#page1"
        titles = "Foods"
        performSegue(withIdentifier: "showWebView", sender: self)
    }
    
    @IBAction func fashionTapped(_ sender: AnyObject) {
        webURL = "https://au.be.yahoo.com/fashion/#page1"
        titles = "Fashion"
        performSegue(withIdentifier: "showWebView", sender: self)
    }
    
    @IBAction func financeTapped(_ sender: AnyObject) {
        webURL = "https://au.finance.yahoo.com/"
        titles = "Finance"
        performSegue(withIdentifier: "showWebView", sender: self)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }

//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showWebView" {
            let destinationVC = segue.destination as! WebViewController
            destinationVC.webURL = webURL
            destinationVC.titles = titles
            
        }
    }
    

}
