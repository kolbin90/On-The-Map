//
//  TableViewController.swift
//  On the Map
//
//  Created by mac on 11/20/16.
//  Copyright © 2016 Alder. All rights reserved.
//

import Foundation
import UIKit

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Outlets
    @IBOutlet var studentsTableView: UITableView!
    
    // MARK: - lifetime
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.hidesBarsOnSwipe = true
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        studentsTableView.reloadData()
    }
    
    // MARK: - TableViewDelegate
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        /* Get cell type */
        let cellReuseIdentifier = "StudentCell"
        let student = StudentInformationArray.sharedInstance().array[(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell!
        
        /* Set cell defaults */
        cell?.textLabel!.text = "\(student.firstName) \(student.lastName)"
        cell?.imageView!.image = #imageLiteral(resourceName: "Pin")
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentInformationArray.sharedInstance().array.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let student = StudentInformationArray.sharedInstance().array[(indexPath as NSIndexPath).row]
        openURLInSafari(urlString: student.mediaURL)
        
    }
    
    // MARK: - Actions
    
    // Logout
    @IBAction func logout(_ sender: Any) {
        dismiss(animated: true) {
            UdacityClient.sharedInstance().deleteSession{ (success, error) in
                
            }
        }
    }
    
    // Adding pin button
    @IBAction func addPin(_ sender: Any) {
        addingPin()
    }
    
    // Refreshing data and table view 
    @IBAction func refreshButton(_ sender: Any) {
        activityIndicatoryShowing(showing: true, view: view)
        StudentInformationArray.sharedInstance().downloadAndStoreData() {success,error in
            DispatchQueue.main.async {
                self.activityIndicatoryShowing(showing: false, view: self.view)
                if success {
                    self.studentsTableView.reloadData()
                } else if let error = error  {
                    self.showAlert(title: "Download failure", error: error)
                }
            }
        }
    }
    
}
