//
//  MainViewController.swift
//  BrainBlocks
//
//  Created by Ty Schenk on 1/14/18.
//  Copyright © 2018 BrainBlocks. All rights reserved.
//

import UIKit
import BrainBlocksKit

class MainViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var amountTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // listen for BrainBlocksSessionStart notification
        NotificationCenter.default.addObserver(self, selector: #selector(sessionStart), name: NSNotification.Name(rawValue: "BrainBlocksSessionStart"), object: nil)
        
        // listen for BrainBlocksSessionStartFailed notification
        NotificationCenter.default.addObserver(self, selector: #selector(sessionStartFailed), name: NSNotification.Name(rawValue: "BrainBlocksSessionStartFailed"), object: nil)
        
        // listen for BrainBlocksPaymentSuccess notification
        NotificationCenter.default.addObserver(self, selector: #selector(sessionSuccess), name: NSNotification.Name(rawValue: "BrainBlocksPaymentSuccess"), object: nil)
        
        // listen for BrainBlocksPaymentFailed notification
        NotificationCenter.default.addObserver(self, selector: #selector(sessionFailed), name: NSNotification.Name(rawValue: "BrainBlocksPaymentFailed"), object: nil)
        
        // listen for BrainBlocksSessionCancelled notification
        NotificationCenter.default.addObserver(self, selector: #selector(sessionCancelled), name: NSNotification.Name(rawValue: "BrainBlocksSessionCancelled"), object: nil)
        
        // listen for BrainBlocksSessionTimeOut notification
        NotificationCenter.default.addObserver(self, selector: #selector(sessionTimeOut), name: NSNotification.Name(rawValue: "BrainBlocksSessionTimeOut"), object: nil)
        
        // listen for BrainBlocksInsufficientPayment notification
        NotificationCenter.default.addObserver(self, selector: #selector(insufficientPayment), name: NSNotification.Name(rawValue: "BrainBlocksInsufficientPayment"), object: nil)
        
        amountTextField.delegate = self
        amountTextField.addDoneButtonToKeyboard(myAction:  #selector(self.amountTextField.resignFirstResponder))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .default
    }
    
    @IBAction func amountWasSet(_ sender: UITextField) {
        // check to make sure the payment account is available
        var amount = 0
        if paymentAccount == "" {
            SweetAlert().showAlert("Setup Payment Account", subTitle: "Setup your payment account first before accepting payments", style: AlertStyle.error)
            sender.text = ""
            print("payment account now setup yet")
            return
        }
        
        // pull amount input and * 1000 to convert into rai
        if sender.text != "" {
            let enteredAmount = Double(sender.text!)!
            amount = Int((enteredAmount * 1000.0))
            print("payment amount: \(amount) rai")
        } else {
            print("invalid amount")
            return
        }
        
        // make sure the amount is less than the api max - 5000 rai
        if amount > 5000 {
            SweetAlert().showAlert("XRB Max", subTitle: "Max XRB allowed: 5.0", style: AlertStyle.error)
            return
        } else {
            BrainBlocksPayment().launchBrainBlocksPaymentView(viewController: self, paymentAmount: amount, paymentDestination: paymentAccount)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    // MARK: Example Implementations of BrainBlocks Event Notifications
    
    // BrainBlocksSessionStart notification function
    @objc func sessionStart() {
        print("BrainBlocks Payment Session Started")
    }
    
    // BrainBlocksSessionStartFailed notification function
    @objc func sessionStartFailed() {
        // display timed out payment alert
        SweetAlert().showAlert("Payment Failed", subTitle: "Could not establish Payment Session", style: AlertStyle.error)
        print("BrainBlocks Payment Session Failed")
    }
    
    // BrainBlocksPaymentSuccess notification function
    @objc func sessionSuccess() {
        // display success alert
        SweetAlert().showAlert("Payment Success", subTitle: "Thank you for using BrainBlocks!", style: AlertStyle.success)
        print("session success")
    }
    
    // BrainBlocksPaymentFailed notification function
    @objc func sessionFailed() {
        // display cancel payment alert
        SweetAlert().showAlert("Payment Failed", subTitle: "Payment could not process", style: AlertStyle.error)
        print("session failed")
    }
    
    // BrainBlocksSessionCancelled notification function
    @objc func sessionCancelled() {
        // display cancel payment alert
        SweetAlert().showAlert("Payment Cancelled", subTitle: "Payment has been cancelled", style: AlertStyle.error)
        print("session cancelled")
    }
    
    // BrainBlocksSessionTimeOut notification function
    @objc func sessionTimeOut() {
        // display timed out payment alert
        SweetAlert().showAlert("Payment Failed", subTitle: "Payment Session has timed out", style: AlertStyle.error)
        print("session time out")
    }
    
    // BrainBlocksInsufficientPayment notification function
    @objc func insufficientPayment() {
        // display cancel payment alert
        SweetAlert().showAlert("Payment Failed", subTitle: "Payment could not be verified. Potential Insufficient Payment", style: AlertStyle.error)
        print("session insufficient payment")
    }
    
}
