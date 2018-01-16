//
//  MainViewController.swift
//  BrainBlocks
//
//  Created by Ty Schenk on 1/14/18.
//  Copyright © 2018 BrainBlocks. All rights reserved.
//

import UIKit
import QRCode
import NotificationCenter

class MainViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var qrCodeImageView: UIImageView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var countdownTimer: Timer!
    var totalTime = 120
    var progressValue: Float = 1.0
    var qrSet: Bool = false
    var startAttempts = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // listen for success notification
        NotificationCenter.default.addObserver(self, selector: #selector(success), name: NSNotification.Name(rawValue: "success"), object: nil)
        
        // listen for failed notification
        NotificationCenter.default.addObserver(self, selector: #selector(failed), name: NSNotification.Name(rawValue: "failed"), object: nil)
        
        // listen for session start notificaiton
        NotificationCenter.default.addObserver(self, selector: #selector(startTimer), name: NSNotification.Name(rawValue: "start"), object: nil)
        
        amountTextField.delegate = self
        amountTextField.addDoneButtonToKeyboard(myAction:  #selector(self.amountTextField.resignFirstResponder))
        accountLabel.isHidden = true
        progressBar.progress = progressValue
        indicator.isHidden = true
        timerLabel.isHidden = true
        progressBar.isHidden = true
        cancelButton.layer.cornerRadius = 10.0
        cancelButton.layer.masksToBounds = true
        cancelButton.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .default
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func startTimer() {
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        let when = DispatchTime.now() + 1.2 // wait for countdown to start
        DispatchQueue.main.asyncAfter(deadline: when) {
            // set qr code
            self.indicator.stopAnimating()
            let qrCode = QRCode(account)
            self.qrCodeImageView.image = qrCode?.image
            self.accountLabel.text = account
            self.accountLabel.isHidden = false
            self.qrSet = true
            self.totalTime = 120
            self.timerLabel.isHidden = false
            self.progressBar.isHidden = false
            self.cancelButton.isHidden = false
        }
    }
    
    // update timmer label and progress bar
    @objc func updateTime() {
        if totalTime != 0 {
            totalTime -= 1
            progressValue = progressValue - 0.00833
        } else {
            endTimer()
        }
        
        timerLabel.text = "\(totalTime) seconds remaining"
        progressBar.progress = progressValue
    }
    
    // end timer and reset back to start for next payment
    func endTimer() {
        indicator.stopAnimating()
        indicator.isHidden = true
        countdownTimer.invalidate()
        progressValue = 1.0
        cancelButton.isHidden = true
        timerLabel.isHidden = true
        progressBar.isHidden = true
        cancelButton.isHidden = true
        amountTextField.text = ""
        qrCodeImageView.image = UIImage()
        accountLabel.text = ""
        qrSet = false
    }
    
    @IBAction func amountWasSet(_ sender: UITextField) {
        // check to make sure the payment account is available
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
            print("payment amount: \(amount)")
        } else {
            print("invalid amount")
            return
        }
        
        // make sure the amount is less than the api max - 5000 rai
        if amount > 5000 {
            SweetAlert().showAlert("XRB Max", subTitle: "Max XRB allowed: 5.0", style: AlertStyle.error)
            return
        } else {
            startSession(amount: amount, destination: paymentAccount)
            indicator.startAnimating()
            indicator.isHidden = false
        }
    }
    
    
    // cancel payment and reset everything for another session
    @IBAction func cancelPayment() {
        cancelButton.isHidden = true
        timerLabel.isHidden = true
        progressBar.isHidden = true
        accountLabel.text = ""
        amountTextField.text = ""
        accountLabel.text = ""
        qrCodeImageView.image = UIImage()
        indicator.stopAnimating()
        progressValue = 1.0
        startAttempts = 0
        qrSet = false
        countdownTimer.invalidate()
        
        print("session canceled")
        
        // if token is not empty, cancel all networking tasks in afManager
        if token != "" {
            afManager.session.getAllTasks { task in
                task.forEach { $0.cancel() }
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @objc func success() {
        // display success alert
        endTimer()
        SweetAlert().showAlert("Payment Success", subTitle: "Thank you for using BrainBlocks!", style: AlertStyle.success)
    }
    
    @objc func failed() {
        // cancel payment
        cancelPayment()
        SweetAlert().showAlert("Payment Failed", subTitle: "Payment could not process", style: AlertStyle.error)
    }
    
}
