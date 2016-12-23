//
//  ParseClient.swift
//  On the Map
//
//  Created by mac on 11/18/16.
//  Copyright © 2016 Alder. All rights reserved.
//

import Foundation
import UIKit

class ParseClient: NSObject {
    // MARK: - Variables
    var session = URLSession.shared
    let statusCodeNoAuthData = 400
    let statusCodeWrongAuthData = 403
    
    // MARK: - ParseClient functions
    func getStudentsLocations(completionHandler: @escaping (_ locations: [[String:AnyObject]]?, _ error: String?) -> Void) -> Void {
        // Build the URL, configure the request
        var request = URLRequest(url: URL(string: Constants.methodForStudentLocationsWithParameters)!)
        request.httpMethod = "GET"
        request.addValue(Constants.parseAppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.RESTAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        // Make the request
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            // Chwck if there was an error
            guard (error == nil) else {
                completionHandler(nil,"Check your connection or try again later")
                return
            }
            // Check if status code exists
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode  else {
                completionHandler(nil,"Check your connection or try again later")
                return
            }
            // Check status code for incorrect email/password, success
            if (statusCode == self.statusCodeNoAuthData || statusCode == self.statusCodeWrongAuthData)  {
                completionHandler(nil, "Check your email and password")
            } else if !(statusCode >= 200 && statusCode <= 299) {
                completionHandler(nil, "Check your connection or try again later")
            }
            
            // Check if data was returned
            guard let data = data else {
                completionHandler(nil,"Data error. Try again later")
                return
            }
            // Parse data, getting account key
            self.convertDataWithCompletionHandler(data: data) { (result, error) in
                guard (error == nil) else {
                    completionHandler(nil, "Data error. Try again later")
                    return
                }
                guard let result = result else {
                    completionHandler(nil,"Data error. Try again later")
                    return
                }
                guard let locations = result["results"] as? [[String : AnyObject]] else {
                    completionHandler(nil,"Data error. Try again later")
                    return
                }
                completionHandler(locations,nil)
            }
        }
        task.resume()
    }
    
    func postPutStudentLocation(studentInformation: StudentInformation, httpMethod: String, objectId: String?, completionHandler: @escaping (_ success: Bool, _ error: String?) -> Void) -> Void {
        
        let student = studentInformation
        var urlString = String()
        // Build the URL, configure the request

        if let objectId = objectId {
            urlString = "\(Constants.methodForStudentLocations)/\(objectId)"
        } else {
           urlString = Constants.methodForStudentLocations
        }
        
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = httpMethod
        request.addValue(Constants.parseAppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.RESTAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(student.uniqueKey)\", \"firstName\": \"\(student.firstName)\", \"lastName\": \"\(student.lastName)\",\"mapString\": \"\(student.mapString!)\", \"mediaURL\": \"https://udacity.com\",\"latitude\": \(student.lat), \"longitude\": \(student.long)}".data(using: String.Encoding.utf8)
        
        
        // Make the request
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            // Chwck if there was an error
            guard (error == nil) else {
                completionHandler(false,"Check your connection or try again later")
                return
            }
            // Check if status code exists
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode  else {
                completionHandler(false,"Check your connection or try again later")
                return
            }
            // Check status code for incorrect email/password, success
            if (statusCode == self.statusCodeNoAuthData || statusCode == self.statusCodeWrongAuthData)  {
                completionHandler(false, "Check your email and password")
            } else if !(statusCode >= 200 && statusCode <= 299) {
                completionHandler(false, "Check your connection or try again later")
            }
            
            // Check if data was returned
            guard let data = data else {
                completionHandler(false,"Data error. Try again later")
                return
            }
            // Parse data, getting account key
            self.convertDataWithCompletionHandler(data: data) { (result, error) in
                guard (error == nil) else {
                    completionHandler(false, "Data error. Try again later")
                    return
                }
                guard let result = result else {
                    completionHandler(false,"Data error. Try again later")
                    return
                }
                guard (result["createdAt"] as? String) != nil || ((result["updatedAt"] as? String) != nil) else {
                    completionHandler(false,"Data error. Try again later")
                    return
                }
                
                completionHandler(true,nil)
            }
            
            
            
        }
        task.resume()

    }
    
    // MARK: - assist functions
    func convertDataWithCompletionHandler(data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        completionHandlerForConvertData(parsedResult, nil)
    }
    // MARK: -  Singleton
    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }
}


