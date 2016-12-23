//
//  NewPinViewController.swift
//  On the Map
//
//  Created by mac on 11/22/16.
//  Copyright © 2016 Alder. All rights reserved.
//

import UIKit
import MapKit

class NewPinViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate {
    
    
    //MARK: - Variables
    var lat = CLLocationDegrees()
    var long = CLLocationDegrees()
    var mapString = String()
    var objectId: String? = nil
    var method: String = "POST"
    var annotation: MKAnnotation?

    //MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var findButton: UIButton!
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        locationTextField.delegate = self
        hideKeyboardWhenTappedAround()
    }
    
    //MARK: -  TextField Delegate
    // Hide keyboard when return pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: -  Actions
    
    @IBAction func closeButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitButton(_ sender: Any) {
        // check if locations textfield isn't empty
        if let locationString = locationTextField.text, locationString != "" {
            // check if URL can be openned
            if let url = URL(string:locationString), UIApplication.shared.canOpenURL(url) {
                activityIndicatoryShowing(showing: true, view: view)
                // Get first and last names from Udacity
                UdacityClient.sharedInstance().getUserData(accountKey: UdacityClient.sharedInstance().accountKey!) { (firstName,lastName,error) in
                    if let firstName = firstName, let lastName = lastName {
                        //Create a new instance of StudentLocation
                        let me = StudentInformation(lat: self.lat, long: self.long, firstName: firstName, lastName: lastName, mediaURL: locationString, mapString: self.mapString, uniqueKey: UdacityClient.sharedInstance().accountKey!)
                        // Post or Put Student Information
                        ParseClient.sharedInstance().postPutStudentLocation(studentInformation: me, httpMethod: self.method, objectId: self.objectId )  { (success, error) in
                            if success {
                                //Refreshing Data
                                StudentInformationArray.sharedInstance().downloadAndStoreData() { success,error in
                                    DispatchQueue.main.async {
                                        self.activityIndicatoryShowing(showing: false, view: self.view)
                                        if success {
                                            self.dismiss(animated: true, completion: nil)
                                            
                                        } else if let error = error  {
                                            self.showAlert(title: "Error with posting", error: error)
                                            self.dismiss(animated: true, completion: nil)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                showAlert(title: "Url can't be open", error: "Enter valid URL")
            }
        } else {
            showAlert(title: "No URL", error: "Enter URL")
        }
    }
    
    @IBAction func findButton(_ sender: Any) {
        // Check if location text field isn't empty
        if let locationString = locationTextField.text, locationString != "" {
            activityIndicatoryShowing(showing: true, view: view)
            mapString = locationString
            // Geocode the location
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(locationString) { (placemarks, error) in
                self.activityIndicatoryShowing(showing: false, view: self.view)
                if let placemark = placemarks?[0] {
                    // Show annotation from geocode
                    self.lat = (placemark.location?.coordinate.latitude)!
                    self.long = (placemark.location?.coordinate.longitude)!
                    self.mapView.showAnnotations([MKPlacemark(placemark: placemark)], animated: true)
                    // Prepare VC for request of web-site and submitting
                    self.findButton.isHidden = true
                    self.submitButton.isHidden = false
                    self.label.text = "Enter your LinkedIn account"
                    self.locationTextField.text = ""
                    self.locationTextField.placeholder = "Enter URL"
                    
                } else if error != nil {
                    self.showAlert(title: "Geolocation failed", error: "Enter different location")
                }
            }
        } else {
            showAlert(title: "No location", error: "Enter location")
        }
    }
    
}
