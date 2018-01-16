//
//  Data.swift
//  BrainBlocks
//
//  Created by Ty Schenk on 1/15/18.
//  Copyright © 2018 BrainBlocks. All rights reserved.
//

import Foundation

let defaults = UserDefaults()
// MARK: Change back to use defaults
var paymentAccount: String = defaults.object(forKey: "BrainBlocksAccount") as? String ?? ""

func setPaymentAccount() {
    defaults.set(paymentAccount, forKey: "BrainBlocksAccount")
}
