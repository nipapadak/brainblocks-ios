//
//  TokenModel.swift
//  BrainBlocks
//
//  Created by Ty Schenk on 1/14/18.
//  Copyright © 2018 BrainBlocks. All rights reserved.
//

import Foundation

struct TokenModel {
    var account: String
    let status: String
    let token: String
}

extension TokenModel {
    struct Key {
        static let account: String = "account"
        static let status: String = "status"
        static let token: String = "token"
    }
    
    init?(json: [String : AnyObject]) {
        if let account = json[Key.account] as? String,
            let status = json[Key.status] as? String,
            let token = json[Key.token] as? String {
            self.account = account
            self.status = status
            self.token = token
        } else {
            self.account = ""
            self.status = ""
            self.token = ""
        }
    }
}
