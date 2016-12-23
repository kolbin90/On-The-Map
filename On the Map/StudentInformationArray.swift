//
//  StudentInformationArray.swift
//  On the Map
//
//  Created by mac on 11/20/16.
//  Copyright © 2016 Alder. All rights reserved.
//

import MapKit

// Ckass fir keeping StudentInformation array and annotations
class StudentInformationArray {
    var array: [StudentInformation] = [StudentInformation]()
    var annotations:[MKPointAnnotation] = [MKPointAnnotation]()
    var objectId = String()
    
    func downloadAndStoreData( completionHandler: @escaping (_ success: Bool, _ error: String?) -> Void) {
        ParseClient.sharedInstance().getStudentsLocations() {locations,error in
            guard (error == nil) else {
                completionHandler(false, error)
                return
            }
            guard let locations = locations else {
                completionHandler(false, error)
                return
            }
            self.array = StudentInformation.studentInformationFromResults(locations)
            self.annotations = StudentInformation.annotationsFromStudentInformation(StudentInformationArray.sharedInstance().array)
            completionHandler(true, nil)
        }
    }
    
    // Singleton
    class func sharedInstance() -> StudentInformationArray {
        struct Singleton {
            static var sharedInstance = StudentInformationArray()
        }
        return Singleton.sharedInstance
    }
}
