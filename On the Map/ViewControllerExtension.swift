//
//  ViewControllerExtension.swift
//  On the Map
//
//  Created by mac on 11/20/16.
//  Copyright © 2016 Alder. All rights reserved.
//

import UIKit

extension UIViewController {
    
    // Show activity indicator
    func activityIndicatoryShowing(showing: Bool, view: UIView) {
        if showing {
            let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
            let container: UIView = UIView()
            let loadingView: UIView = UIView()
            container.tag = 1
            container.frame = view.frame
            container.center = view.center
            container.backgroundColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.3)
            loadingView.frame = CGRect(x:0, y:0, width:80, height:80)
            loadingView.center = view.center
            loadingView.backgroundColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.7)
            loadingView.clipsToBounds = true
            loadingView.layer.cornerRadius = 10
            activityIndicator.frame = CGRect(x:0, y:0, width:40, height:40)
            activityIndicator.center = CGPoint(x: (loadingView.frame.size.width / 2), y: (loadingView.frame.size.height / 2))
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
            activityIndicator.color = UIColor(red: 1.000, green: 0.553, blue: 0.000, alpha: 1.0)
            DispatchQueue.main.async {
                loadingView.addSubview(activityIndicator)
                container.addSubview(loadingView)
                //view.addSubview(loadingView)
                view.addSubview(container)
                activityIndicator.startAnimating()
            }
        } else {
            let subViews = view.subviews
            for subview in subViews{
                if subview.tag == 1 {
                    subview.removeFromSuperview()
                }
            }
        }
    }
    
    // Show Alert controller with error
    func showAlert(title: String, error: String) {
        let alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    // Hide keyboard when tapped somewhere
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // Open URL in Safari
    
    func openURLInSafari(urlString: String) {
        var openedUrl = false
        
        if let URL = URL(string: urlString) {
            //app.openURL(toOpenURL)
            if  UIApplication.shared.canOpenURL(URL) {
                UIApplication.shared.open(URL, options: [:], completionHandler: nil)
                openedUrl = true
            }
        }
        
        if !openedUrl {
            showAlert(title: "URL can't be opened", error: "URL provided by student is invalid")
        }
    }
    
    func addingPin() {
        // Check if your pin exists and show alert
        let students = StudentInformationArray.sharedInstance().array
        for student in students {
            if student.uniqueKey == UdacityClient.sharedInstance().accountKey! {
                
                let alert = UIAlertController(title: "Pin already exists", message: "Do you want to update information?", preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { (action: UIAlertAction!) in
                    let controller = self.storyboard!.instantiateViewController(withIdentifier: "NewPinViewController") as! NewPinViewController
                    controller.objectId = student.objectId! // save objectId
                    controller.method = "PUT" // choose method for http task
                    self.present(controller, animated: true, completion: nil) // present NewPinViewController
                }))
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                }))
                
                present(alert, animated: true, completion: nil) // present Alert
            }
        }
        let controller = storyboard!.instantiateViewController(withIdentifier: "NewPinViewController") as! NewPinViewController
        present(controller, animated: true, completion: nil) // present NewPinViewController
    }
}
