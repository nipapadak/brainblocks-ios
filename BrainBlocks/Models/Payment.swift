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
var currentToken: TokenModel!
var failedAction = ""

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
            switch status {
            case "success":
                // set current token for future usage
                currentToken = TokenModel(json: tokenJSON)
                print("session started")
                print("account: \(currentToken.account)")
                print("token: \(currentToken.token)")
            default:
                print("session error")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "cancel"), object: nil)
                return
            }
        }
    }
}

func transferPayment(token: String) {
    Alamofire.request("\(BrainBlocks.sessionURL)/\(token)/transfer", method: .post).responseJSON { response in
        if let resultJSON = response.result.value as? [String : AnyObject]! {
            
            // hold status in let for switch
            let status = resultJSON["status"] as! String
            
            switch status {
            case "success":
                print("transfer success")
                verifyPayment(token: currentToken.token)
            default:
                print("transfer error")
                failedAction = "transfer"
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "cancel"), object: nil)
                return
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
            
            // make sure works
            if token == currentToken.token && received == amount {
                print("payment success")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "verify"), object: nil)
            } else {
                print("payment error")
                failedAction = "verify"
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "cancel"), object: nil)
            }
        }
    }
}
