//
//  LoginViewController.swift
//  On the Map
//
//  Created by mac on 10/29/16.
//  Copyright © 2016 Alder. All rights reserved.
//

import Foundation
import UIKit
import FBSDKLoginKit


class LoginViewController: UIViewController, FBSDKLoginButtonDelegate, UITextFieldDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var facebookButton: FBSDKLoginButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        configureBackground()
        facebookButton.delegate = self
        styleFor(TextField: passwordTextField)
        styleFor(TextField: emailTextField)
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribedToKeyboardNotifications(true)
        passwordTextField.text = ""
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        subscribedToKeyboardNotifications(false)
    }
    
    
    
    
    // MARK: - Actions
    
    @IBAction func loginButton(_ sender: UIButton) {
        loginWithUdacity()
    }
    
    
    @IBAction func signUpButton(_ sender: AnyObject) {
        // Open Udacity sign-up page
        UIApplication.shared.open(URL(string: UdacityClient.Constants.signUpURL)!, options: [:], completionHandler: nil)
    }
    
    
    
    // MARK: - LoginViewController functions
    
    func loginWithUdacity() {
        activityIndicatoryShowing(showing: true, view: view)
        // Posting sesion for Udacity with function postSessionWith()
        UdacityClient.sharedInstance().postSessionWith(email: emailTextField.text!, password: passwordTextField.text!, facebookToken: nil) { (success, error) in
            // Dispatch UI changes on main queue
            DispatchQueue.main.async {
                if success {
                    // Completing login with completeLogin()
                    self.completeLogin() {
                        self.activityIndicatoryShowing(showing: false, view: self.view)
                    }
                } else if let error = error {
                    // Show Alert Controller if error not nil
                    self.activityIndicatoryShowing(showing: false, view: self.view)
                    self.showAlert(title: "Login failure", error: error)
                }
            }
        }
    }
    
    
    
    func completeLogin(completionHandler: @escaping () -> Void) {
        // Download Students Locations
        StudentInformationArray.sharedInstance().downloadAndStoreData() {success,error in
            DispatchQueue.main.async {
                if success {
                    // Present tab-bar view controller if succes
                    let controller = self.storyboard!.instantiateViewController(withIdentifier: "StudentTabBar") as! UITabBarController
                    self.present(controller, animated: true) {
                        completionHandler()
                    }
                } else if let error = error  {
                    // Show alert if error
                    self.showAlert(title: "Download failure", error: error)
                    completionHandler()
                }
            }
        }
    }
    
    
    // MARK: Facebook
    
    // Login with Facebook
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        // Process error
        if ((error) != nil) {
            let errorString = String(describing: error)
            showAlert(title: "Login failure", error: errorString)
            
        } else if result.isCancelled {
            // Handle cancellations
        } else {
            // Success. Post session to Udacity
            activityIndicatoryShowing(showing: true, view: self.view)
            UdacityClient.sharedInstance().postSessionWith(email: nil, password: nil
            , facebookToken: FBSDKAccessToken.current().tokenString) {(success, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        self.activityIndicatoryShowing(showing: false, view: self.view)
                        self.showAlert(title: "Login failure", error: error)
                        return
                    }
                    if success {
                        // Completing login with completeLogin()
                        self.completeLogin(){
                            self.activityIndicatoryShowing(showing: false, view: self.view)
                        }
                    }
                }
            }
        }
    }
    
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {

    }
    
    
    // MARK: - Keyboard & Notifications setting
    // Hide keyboard when return pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    // Move view up, so both textviews and loginButton are visible
    func keyboardWillShow(_ notification: Notification) {
        view.frame.origin.y = (getKeyboardHeight(notification: notification) - (view.frame.height - loginButton.frame.maxY) ) * -1
    }
    // Move view back
    func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    
    
    // Adding or removing observers for keyboard notifications
    func subscribedToKeyboardNotifications(_ state: Bool) {
        if state {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)) , name: .UIKeyboardWillHide, object: nil)
        } else {
            NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
            NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
        }
    }
    
    
    // MARK: - View settings
    func configureBackground() {
        // Making gradient
        let backgroundGradient = CAGradientLayer()
        let colorTop = UIColor(red: 1.000, green: 0.553, blue: 0.000, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 1.000, green: 0.383, blue: 0.000, alpha: 1.0).cgColor
        backgroundGradient.colors = [colorTop, colorBottom]
        backgroundGradient.locations = [0.0, 1.0]
        backgroundGradient.frame = view.frame
        view.layer.insertSublayer(backgroundGradient, at: 0)
    }
    
    func styleFor(TextField textField: UITextField) {
        // Set up padding and color of placeholder text
        let paddingView = UIView(frame:CGRect(x:0, y:0, width:20, height:10))
        textField.leftViewMode = UITextFieldViewMode.always
        textField.leftView = paddingView
        textField.attributedPlaceholder = NSAttributedString(string:textField.placeholder != nil ? textField.placeholder! : "", attributes:[NSForegroundColorAttributeName: UIColor.white])
        textField.delegate = self // Textfield delegate
    }
    
}

