//
//  SettingsViewController.swift
//  BrainBlocks
//
//  Created by Ty Schenk on 1/14/18.
//  Copyright © 2018 BrainBlocks. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var scanCodeButton: UIButton!
    @IBOutlet weak var updateManualllyButton: UIButton!
    @IBOutlet weak var accountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        scanCodeButton.layer.cornerRadius = 10
        scanCodeButton.layer.masksToBounds = true
        updateManualllyButton.layer.cornerRadius = 10
        updateManualllyButton.layer.masksToBounds = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if paymentAccount != "" {
            accountLabel.text = "Payment Account: \(paymentAccount)"
            updateManualllyButton.setTitle("Set Manuallly", for: .normal)
        } else {
            SweetAlert().showAlert("Setup Payment Account", subTitle: "Without a payment account, we can not pay you 🙁", style: AlertStyle.error)
            accountLabel.text = "Payment Account: Not Set"
            updateManualllyButton.setTitle("Update Manuallly", for: .normal)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func launchCodeScan(_ sender: UIButton) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "codeReader") as? CodeReaderViewController {
            present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func setPaymentAccount(_ sender: UIButton) {
        print("set new payment account")
    }
    
}
