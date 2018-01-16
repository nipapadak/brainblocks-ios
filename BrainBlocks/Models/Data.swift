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
var paymentAccount: String = "xrb_1jnatu97dka1h49zudxtpxxrho3j591jwu5bzsn7h1kzn3gwit4kejak756y" //defaults.object(forKey: "BrainBlocksAccount") as? String ?? ""

func setPaymentAccount() {
    defaults.set(paymentAccount, forKey: "BrainBlocksAccount")
}
