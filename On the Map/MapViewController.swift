//
//  MapViewController.swift
//  On the Map
//
//  Created by mac on 11/15/16.
//  Copyright © 2016 Alder. All rights reserved.
//

import UIKit
import MapKit
import FBSDKLoginKit
import FBSDKCoreKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // delete facebook session, so if app is closed we're not staying loged in
        if FBSDKAccessToken.current() != nil {
            FBSDKLoginManager().logOut()
        }
        mapView.delegate = self // MKMapViewDelegate
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Refresh annotations
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(StudentInformationArray.sharedInstance().annotations)
        
    }

    
    // MARK: - Actions
    // Add new Pin to the Map
    @IBAction func addPin(_ sender: Any) {
        addingPin()
    }
    
    
    @IBAction func logout(_ sender: AnyObject) {
        // Dismiss VC and delete session from Udacity
        dismiss(animated: true) {
            UdacityClient.sharedInstance().deleteSession{ (success, error) in
                
            }
        }
    }
    
    // Refreshing data and annotations
    @IBAction func refreshButton(_ sender: Any) {
        mapView.removeAnnotations(mapView.annotations)
        activityIndicatoryShowing(showing: true, view: mapView)
        StudentInformationArray.sharedInstance().downloadAndStoreData() {success,error in
            DispatchQueue.main.async {
                self.activityIndicatoryShowing(showing: false, view: self.mapView)
                if success {
                    self.mapView.addAnnotations(StudentInformationArray.sharedInstance().annotations)
                    
                } else if let error = error  {
                    self.showAlert(title: "Download failure", error: error)
                }
            }
        }
    }
}
