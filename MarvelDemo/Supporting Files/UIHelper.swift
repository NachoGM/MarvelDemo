//
//  UIHelper.swift
//  MarvelDemo
//
//  Created by Nacho González Miró on 28/6/18.
//  Copyright © 2018 Nacho González Miró. All rights reserved.
//

import Foundation
import SwiftHash
import UIKit

class Helper: UIViewController {
    
    let publicKey = "36e1193bc5f9fe04de7afba1a99aeb39"
    let privateKey = "4743e03be2783d4f4fec40b8452d273efd67fd40"
    let ts = "1"
    let BASE_URL = "http://gateway.marvel.com"
    
    func handleError401(hash: String) {
        if hash.isEmpty {
            self.displayAlertMessage(userTitle: "Invalid Hash", userMessage: "Occurs when a ts, hash and apikey parameter are sent but the hash is not valid per the above hash generation rule.")
            return
        } else {
            self.displayAlertMessage(userTitle: "Invalid Referer", userMessage: "Occurs when a referrer which is not valid for the passed apikey parameter is sent.")
            return
        }
    }
    
    func handleError403() {
        self.displayAlertMessage(userTitle: "Forbidden", userMessage: "Occurs when a user with an otherwise authenticated request attempts to access an endpoint to which they do not have access.")
        return
    }
    
    func handleError405() {
        self.displayAlertMessage(userTitle: "Method Not Allowed", userMessage: "Occurs when an API endpoint is accessed using an HTTP verb which is not allowed for that endpoint.")
        return
    }
    
    func handleError409(hash: String) {
        if hash.isEmpty {
            self.displayAlertMessage(userTitle: "Missing Hash", userMessage: "Occurs when an apikey parameter is included with a request, a ts parameter is present, but no hash parameter is sent. Occurs on server-side applications only.")
            return
        } else {
            self.displayAlertMessage(userTitle: "Missing API Key", userMessage: "Occurs when the apikey parameter is not included with a request.")
        }
    }
    
    func displayAlertMessage(userTitle: String, userMessage: String) {
        
        let myAlert = UIAlertController(title: userTitle, message: userMessage, preferredStyle: UIAlertControllerStyle.alert);
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
            return
        }
        
        myAlert.addAction(okAction);
        self.present(myAlert, animated: true, completion: nil);
    }
    
}
