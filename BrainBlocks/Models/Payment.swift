//
//  Payment.swift
//  BrainBlocks
//
//  Created by Ty Schenk on 1/14/18.
//  Copyright © 2018 BrainBlocks. All rights reserved.
//

import Foundation
import Alamofire

// Set up a payment session: curl -X POST https://brainblocks.io/api/session -d 'destination=xrb_xyz&amount=1000' (returns a token)
// Wait 120 seconds for a successful payment: curl -X POST https://brainblocks.io/api/session/<token>/transfer
// Verify a payment: curl https://brainblocks.io/api/session/<token>/verify

var amount = 0
var afManager : SessionManager!
var token: String = ""
var account: String = ""

class BrainBlocks {
    static let sessionURL = "https://brainblocks.io/api/session"
}

func startSession(amount: Int, destination: String) {
    
    let headers = [
        "Content-Type": "application/x-www-form-urlencoded"
    ]
    let params: [String : String] = [
        "amount": "\(amount)",
        "destination": "\(destination)"
    ]
    
    Alamofire.request(BrainBlocks.sessionURL, method: .post, parameters: params, headers: headers).responseJSON { response in
        if let tokenJSON = response.result.value as? [String : AnyObject]! {
            
            let status = tokenJSON["status"] as! String
            account = tokenJSON["account"] as! String
            token = tokenJSON["token"] as! String
            
            switch status {
            case "success":
                // set current token for future usage
                print("session started")
                print("session account: \(account)")
            
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "start"), object: nil)
                transferPayment(token: token)
            default:
                print("session error")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "failed"), object: nil)
                return
            }
        }
    }
}

func transferPayment(token: String) {
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = 125
    configuration.timeoutIntervalForResource = 125
    afManager = Alamofire.SessionManager(configuration: configuration)
    
    afManager.request("\(BrainBlocks.sessionURL)/\(token)/transfer", method: .post).responseJSON { response in
        if let resultJSON = response.result.value as? [String : AnyObject]! {
            
            // check if results are nil and call failed if they are
            if resultJSON == nil {
                print("transfer result json nil")
                // MARK: Add method to tell user that payment has been canceled and not just normal failed error
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "failed"), object: nil)
                return
            }
            
            // hold status in let for switch
            let status = resultJSON["status"] as! String
            
            switch status {
            case "success":
                print("transfer success")
                verifyPayment(token: token)
            default:
                print("transfer error")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "failed"), object: nil)
            }
        }
    }
}

func verifyPayment(token: String) {
    Alamofire.request("\(BrainBlocks.sessionURL)/\(token)/verify", method: .get).responseJSON { response in
        if let resultJSON = response.result.value as? [String : AnyObject]! {
            
            // pull token from result json
            let token = resultJSON["token"] as! String
            let received = resultJSON["received"] as! Int
            
            // make sure token and received amounts are correct
            if token == token && received == amount {
                print("payment success")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "success"), object: nil)
            } else {
                print("payment error")
                // MARK: update this to tell user that payment amount may not be correct
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "failed"), object: nil)
            }
        }
    }
}
