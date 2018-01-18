//: Playground - noun: a place where people can play

import UIKit
import Foundation

let paymentAmount = 1

var amount: Double {
    return Double(round(Double(paymentAmount)) / 1000)
}

print("Pay \(amount) XRB")
