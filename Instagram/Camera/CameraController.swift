//
//  CameraController.swift
//  Instagram
//
//  Created by Ali Sanaknaki on 2020-03-30.
//  Copyright © 2020 Ali Sanaknaki. All rights reserved.
//

import UIKit
import AVFoundation

/*
 * NEED TO ASK FOR PERMISSION IN INFO.PLIST
 */

class CameraController: UIViewController {
    
    let dismissButton: UIButton = {
        let btn = UIButton(type: .system)
        
        btn.setImage(#imageLiteral(resourceName: "right_arrow_shadow"), for: .normal)
        
        btn.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        
        return btn
    }()
    
    @objc func handleDismiss() { dismiss(animated: true, completion: nil) }
    
    let capturePhotoButton: UIButton = {
        let btn = UIButton(type: .system)
        
        btn.setImage(#imageLiteral(resourceName: "capture_photo"), for: .normal)
        btn.addTarget(self, action: #selector(handleCapturePhoto), for: .touchUpInside)
        
        return btn
    }()
    
    @objc func handleCapturePhoto() {
        print("Capturing Photo")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCaptureSession()
        
        setupHUD()
    }
    
    fileprivate func setupHUD() {
        view.addSubview(capturePhotoButton)
        view.addSubview(dismissButton)
        
        capturePhotoButton.anchor(top: nil, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 24, paddingRight: 0, width: 80, height: 80)
        capturePhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        dismissButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 24, paddingLeft: 0, paddingBottom: 0, paddingRight: 24, width: 50, height: 50)
    }
    
    fileprivate func setupCaptureSession() {
        let captureSession = AVCaptureSession()
        
        // 1. Setup Inputs
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
        } catch let err {
            print("Could not setup camera input: ", err)
        }

        // 2. Setup Outputs
        let output = AVCapturePhotoOutput()
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        }
        
        // 3. Setup Output Preview
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        previewLayer.frame = view.frame // What we want to see from camera
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    }
}
