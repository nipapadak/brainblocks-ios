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
    @IBOutlet weak var accountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the vi=ew.
        scanCodeButton.layer.cornerRadius = 10
        scanCodeButton.layer.masksToBounds = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .lightContent
        
        if paymentAccount != "" {
            accountLabel.text = "Payment Account: \(paymentAccount)"
        } else {
            SweetAlert().showAlert("Setup Payment Account", subTitle: "Without a payment account, we can not pay you 🙁", style: AlertStyle.error)
            accountLabel.text = "Payment Account: Not Set"
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
}
