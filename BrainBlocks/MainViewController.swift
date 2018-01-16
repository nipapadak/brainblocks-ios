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
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(success), name: NSNotification.Name(rawValue: "success"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(failed), name: NSNotification.Name(rawValue: "failed"), object: nil)
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
    
    func startTimer() {
        indicator.startAnimating()
        indicator.isHidden = false
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    @objc func updateTime() {
        // set qr code
        if currentToken != nil && currentToken.account != "" && qrSet == false {
            indicator.stopAnimating()
            let qrCode = QRCode(currentToken.account)
            qrCodeImageView.image = qrCode?.image
            accountLabel.text = currentToken.account
            accountLabel.isHidden = false
            qrSet = true
            totalTime = 120
            timerLabel.isHidden = false
            progressBar.isHidden = false
            cancelButton.isHidden = false
        } else if currentToken == nil && qrSet == false && startAttempts > 1 {
            cancelPayment()
        } else if currentToken == nil && qrSet == false && startAttempts < 2 {
            startAttempts += 1
        }
        
        if totalTime != 0 {
            totalTime -= 1
            progressValue = progressValue - 0.00833
        } else {
            endTimer()
            // MARK: transfer
            transferPayment(token: currentToken.token)
        }
        
        timerLabel.text = "\(totalTime) seconds remaining"
        progressBar.progress = progressValue
    }
    
    func endTimer() {
        indicator.startAnimating()
        indicator.isHidden = false
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
            return
        }
        
        // pull amount input and * 1000 to convert into rai
        if sender.text != "" {
            let enteredAmount = Int(sender.text!)!
            amount = (enteredAmount * 1000)
        } else {
            return
        }
        
        // make sure the amount is less than the api max - 5000 rai
        if amount > 5000 {
            SweetAlert().showAlert("XRB Max", subTitle: "Max XRB allowed: 5.0", style: AlertStyle.error)
            return
        } else {
            startTimer()
            startSession(amount: amount, destination: paymentAccount)
        }
    }
    
    @IBAction func cancelPayment() {
        // cancel payment and reset everything for another session
        print("session canceled")
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
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @objc func success() {
        SweetAlert().showAlert("Payment Success", subTitle: "Thank you for using BrainBlocks!", style: AlertStyle.success)
    }
    
    @objc func failed() {
        SweetAlert().showAlert("Payment Failed", subTitle: "Do you want to retry?", style: AlertStyle.warning, buttonTitle:"No", buttonColor: UIColor.init(hexString: "C3C3C3"), otherButtonTitle:  "Yes, Try Again", otherButtonColor: UIColor.init(hexString: "E0755F")) { (cancelButton) -> Void in
            if cancelButton == true {
                self.cancelPayment()
                SweetAlert().showAlert("Payment Failed", subTitle: "Payment could not process", style: AlertStyle.error)
                return
            } else {
                // wait 1 second before attempting payment again
                let when = DispatchTime.now() + 1
                DispatchQueue.main.asyncAfter(deadline: when) {
                    switch failedAction {
                    case "verify":
                        self.indicator.startAnimating()
                        verifyPayment(token: currentToken.token)
                    case "transfer":
                        self.indicator.startAnimating()
                        transferPayment(token: currentToken.token)
                    default:
                        self.cancelPayment()
                        SweetAlert().showAlert("Payment Failed", subTitle: "Payment could not process", style: AlertStyle.error)
                        return
                    }
                }
            }
        }
    }
    
}
