//
//  StudentInformation.swift
//  On the Map
//
//  Created by mac on 11/19/16.
//  Copyright © 2016 Alder. All rights reserved.
//
import MapKit


struct StudentInformation {
    
    // MARK: Properties
    
    var lat: CLLocationDegrees
    var long: CLLocationDegrees
    var firstName: String
    var lastName: String
    var mediaURL: String
    var mapString: String?
    var uniqueKey: String
    var objectId: String?
    
    // MARK: Initializers
    
    // construct a StudentInformation from a dictionary
    init?(dictionary: [String:AnyObject]) {                
        if let latDouble = dictionary["latitude"] as? Double {
            lat = CLLocationDegrees(latDouble)
            if let longDouble = dictionary["longitude"] as? Double  {
                long = CLLocationDegrees(longDouble)
            } else {
                return nil
            }
        } else {
            return nil
        }
        
        
        if let first = dictionary["firstName"] as? String {
            firstName = first
        } else {
            return nil
        }
        
        if let last = dictionary["lastName"] as? String {
            lastName = last
        } else {
            return nil
        }
        
        
        if let media = dictionary["mediaURL"] as? String {
            mediaURL = media
        } else {
            return nil
        }
        
        if let uniqueKey = dictionary["uniqueKey"] as? String {
            self.uniqueKey = uniqueKey
        } else {
            return nil
        }
        
        if let objectId = dictionary["objectId"] as? String {
            self.objectId = objectId
        } else {
            return nil
        }
        
    }
    init(lat:CLLocationDegrees,long: CLLocationDegrees,firstName: String,lastName: String, mediaURL: String, mapString: String, uniqueKey: String) {
        self.lat = lat
        self.long = long
        self.firstName = firstName
        self.lastName = lastName
        self.mediaURL = mediaURL
        self.mapString = mapString
        self.uniqueKey = uniqueKey
    }

    
    // MARK: - StudentInformation functions
    
    // Make array of StudentInformaton
    static func studentInformationFromResults(_ results: [[String:AnyObject]]) -> [StudentInformation] {
        var students = [StudentInformation]()
        // iterate through array of dictionaries, each Student is a dictionary
        for result in results {
            let student = StudentInformation(dictionary: result)
            if let student = student {
                students.append(student)
            } else {
                // handle error
            }
        }
        
        return students
    }
    
    // Make array of annotations
    static func annotationsFromStudentInformation(_ students:[StudentInformation]) -> [MKPointAnnotation] {
        var annotations = [MKPointAnnotation]()
        for student in students {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: student.lat, longitude: student.long)
            annotation.title = "\(student.firstName) \(student.lastName)"
            annotation.subtitle = student.mediaURL
            
            // place the annotation in an array of annotations.
            annotations.append(annotation)
        }
        return annotations
    }
}

