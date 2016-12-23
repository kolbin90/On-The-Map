//
//  UdacityClient.swift
//  On the Map
//
//  Created by mac on 10/29/16.
//  Copyright © 2016 Alder. All rights reserved.
//

import Foundation
import UIKit


class UdacityClient: NSObject {
    // MARK: - Variables
    var session = URLSession.shared
    var accountKey:String? = nil
    let statusCodeNoAuthData = 400
    let statusCodeWrongAuthData = 403
    
    // MARK: - Udacity Client functions
    // get first and last name from Udacity
    func getUserData(accountKey:String, completionHandler: @escaping (_ firstName:String?,_ lastName:String?,_ error:String?) -> Void) -> Void {
        
        var request = URLRequest(url: URL(string: Constants.methodForGettingUserData+accountKey)!)
        request.httpMethod = "GET"
        // Make the request
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            // Chwck if there was an error
            guard (error == nil) else {
                completionHandler(nil,nil,"Check your connection or try again later")
                return
            }
            // Check if status code exists
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode  else {
                completionHandler(nil,nil,"Check your connection or try again later")
                return
            }
            // Check status code for incorrect email/password, success
            if (statusCode == self.statusCodeNoAuthData || statusCode == self.statusCodeWrongAuthData)  {
                completionHandler(nil,nil, "Check your email and password")
            } else if !(statusCode >= 200 && statusCode <= 299) {
                completionHandler(nil,nil, "Check your connection or try again later")
            }
            
            // Check if data was returned
            guard let data = data else {
                completionHandler(nil,nil, "Data error. Try again later")
                return
            }
            // Cut first five charachters of data (Udacity needs)
            let range = 5...data.count
            let newData = data.subdata(in: Range(range))
            
            // Parse data, getting account key
            self.convertDataWithCompletionHandler(data: newData) { (result, error) in
                guard (error == nil) else {
                    completionHandler(nil,nil, "Data error. Try again later")
                    return
                }
                guard let result = result else {
                    completionHandler(nil,nil,"Data error. Try again later")
                    return
                }
                guard let accountDictionary = result["user"] as? [String:AnyObject] else {
                    completionHandler(nil,nil, "Data error. Try again later!")
                    return
                }
                guard let firstName = accountDictionary["first_name"] as? String else {
                    completionHandler(nil,nil,"Data error. Try again later!")
                    return
                }
                guard let lastName = accountDictionary["last_name"] as? String else {
                    completionHandler(nil,nil,"Data error. Try again later!")
                    return
                }
                completionHandler(firstName,lastName,nil)
            }
        }
        task.resume()
        
    }
    // post a session
    func postSessionWith(email:String?, password:String?,facebookToken:String?, completionHandler: @escaping (_ success:Bool,_ error:String?) -> Void ) -> Void {
        // Build the URL, configure the request
        var request = URLRequest(url: URL(string: Constants.methodForPostingSession)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let email = email , let password = password {
            request.httpBody = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}".data(using: String.Encoding.utf8)
        }
        if let facebookToken = facebookToken {
            request.httpBody = "{\"facebook_mobile\": {\"access_token\": \"\(facebookToken);\"}}".data(using: String.Encoding.utf8)
        }
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
                completionHandler(false, "Data error. Try again later")
                return
            }
            // Cut first five charachters of data (Udacity needs)
            let range = 5...data.count
            let newData = data.subdata(in: Range(range))
            
            // Parse data, getting account key
            self.convertDataWithCompletionHandler(data: newData) { (result, error) in
                guard (error == nil) else {
                    completionHandler(false, "Data error. Try again later")
                    return
                }
                guard let result = result else {
                    completionHandler(false,"Data error. Try again later")
                    return
                }
                guard let accountDictionary = result["account"] as? [String:AnyObject] else {
                    completionHandler(false, "Data error. Try again later!")
                    return
                }
                guard let accountKey = accountDictionary["key"] as? String else {
                    completionHandler(false,"Data error. Try again later!")
                    return
                }
                
                self.accountKey = accountKey
                completionHandler(true,nil)
            }
        }
        task.resume()
        
    }
    //  delete a session
    func deleteSession(completionHandler: @escaping (_ success:Bool,_ error:String?) -> Void ) -> Void {
        var request = URLRequest(url: URL(string: Constants.methodForPostingSession)!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" {
                xsrfCookie = cookie
            }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
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
            if !(statusCode >= 200 && statusCode <= 299) {
                completionHandler(false, "Check your connection or try again later")
            }
            
            // Check if data was returned
            guard data != nil else {
                completionHandler(false, "Data error. Try again later")
                return
            }
            completionHandler(true, nil)
            
        }
        task.resume()
    }
    
    // MARK: - assist functions
    // Function for parsing data
    private func convertDataWithCompletionHandler(data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }
    
    // MARK: - Singleton
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
}
