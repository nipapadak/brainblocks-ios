//
//  CodeReaderViewController.swift
//  BrainBlocks
//
//  Created by Ty Schenk on 1/15/18.
//  Copyright © 2018 BrainBlocks. All rights reserved.
//

import UIKit
import AVFoundation

class CodeReaderViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var submitAddress: UIButton!
    @IBOutlet weak var addressTextView: UITextView!
    @IBOutlet weak var submitView: UIView!
    
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    var codeFound: Bool = false
    
    private let supportedCodeTypes = [AVMetadataObject.ObjectType.qr]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        submitAddress.layer.cornerRadius = 10
        submitAddress.layer.masksToBounds = true
        submitView.isHidden = true

        // Get the back-facing camera for capturing videos
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera], mediaType: AVMediaType.video, position: .back)
        
        guard let captureDevice = deviceDiscoverySession.devices.first else {
            print("Failed to get the camera device")
            return
        }
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Set the input device on the capture session.
            captureSession.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        
        // Start video capture.
        captureSession.startRunning()
        
        // Move the message label and top bar to the front
        view.bringSubview(toFront: codeLabel)
        view.bringSubview(toFront: topBar)
        
        // Initialize QR Code Frame to highlight the QR code
        qrCodeFrameView = UIView()
        
        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            view.addSubview(qrCodeFrameView)
            view.bringSubview(toFront: qrCodeFrameView)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Helper methods
    func setCode(decodedURL: String) {
        SweetAlert().showAlert(" Code Found", subTitle: decodedURL, style: AlertStyle.warning, buttonTitle:"No", buttonColor: UIColor.init(hexString: "C3C3C3"), otherButtonTitle:  "Yes, Set as recipient", otherButtonColor: UIColor.init(hexString: "E0755F")) { (isOtherButton) -> Void in
            if isOtherButton == true {
                print("Not correct code")
                self.codeFound = false
            } else {
                SweetAlert().showAlert("Recipient Set!", subTitle: "Payment account is now: \(decodedURL)", style: AlertStyle.success)
                print("Recipient Set! \(decodedURL)")
                paymentAccount = decodedURL
                setPaymentAccount()
                self.closeReader()
            }
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            codeLabel.text = "Looking for QR code"
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            // If the found metadata is equal to the QR code metadata (or barcode) then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil && codeFound == false && metadataObj.stringValue?.validAddress() == true {
                setCode(decodedURL: metadataObj.stringValue!)
                codeLabel.text = metadataObj.stringValue
                codeFound = true
            }
        }
    }

    @IBAction func closeReader() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func enterManually(_ sender: UIButton) {
        UIApplication.shared.statusBarStyle = .default
        submitView.isHidden = false
        captureSession.stopRunning()
        view.addSubview(submitView)
    }
    
    @IBAction func closeSubmitView(_ sender: UIButton) {
        UIApplication.shared.statusBarStyle = .lightContent
        self.view.endEditing(true)
        submitView.isHidden = true
        captureSession.startRunning()
        view.bringSubview(toFront: codeLabel)
        view.bringSubview(toFront: topBar)
    }
    
    @IBAction func submitAddress(_ sender: UIButton) {
        self.view.endEditing(true)
        if addressTextView.text.validAddress() == true {
            UIApplication.shared.statusBarStyle = .lightContent
            paymentAccount = addressTextView.text
            setPaymentAccount()
            SweetAlert().showAlert("Recipient Set!", subTitle: "Payment account is now: \(addressTextView.text)", style: AlertStyle.success)
            self.dismiss(animated: true, completion: nil)
        } else {
            SweetAlert().showAlert("Invalid Address", subTitle: "Please check your Address", style: AlertStyle.error)
        }
    }
}
