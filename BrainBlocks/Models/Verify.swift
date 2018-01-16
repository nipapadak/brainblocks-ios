//
//  Verify.swift
//  BrainBlocks
//
//  Created by Ty Schenk on 1/15/18.
//  Copyright © 2018 BrainBlocks. All rights reserved.
//

import Foundation

struct VerifyModel {
    let token: String
    let destination: String
    var amount: String
}

extension VerifyModel {
    struct Key {
        static let token: String = "token"
        static let destination: String = "destination"
        static let amount: String = "received"
    }
    
    init?(json: [String : AnyObject]) {
        if let token = json[Key.token] as? String,
            let destination = json[Key.destination] as? String,
            let amount = json[Key.amount] as? String {
            
            self.token = token
            self.destination = destination
            self.amount = amount
        } else {
            self.token = ""
            self.destination = "null"
            self.amount = "null"
        }
    }
}
