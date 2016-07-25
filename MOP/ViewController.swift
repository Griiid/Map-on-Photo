//
//  ViewController.swift
//  MOP
//
//  Created by Eddie Hsu on 2016/7/16.
//  Copyright © 2016年 Griiid. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    @IBOutlet weak var PhotoImageView: UIImageView!
    @IBOutlet weak var TakePhotoBtn: UIButton!
    @IBOutlet weak var AlbumBtn: UIButton!
    @IBOutlet weak var SwapCameraBtn: UIButton!
    @IBOutlet weak var TrashBtn: UIButton!
    @IBOutlet weak var SaveBtn: UIButton!
    @IBOutlet weak var UploadBtn: UIButton!
    
    let captureSession = AVCaptureSession()
    var previewLayer : AVCaptureVideoPreviewLayer?
    let stillImageOutput = AVCaptureStillImageOutput()
    var squareImage: UIImage?
    
    // If we find a device we'll store it here for later use
    var captureDevice : AVCaptureDevice?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        captureSession.sessionPreset = AVCaptureSessionPresetPhoto // high resolutoin
        
        let devices = AVCaptureDevice.devices()
        
        // Loop through all the capture devices on this phone
        for device in devices {
            // Make sure this particular device supports video
            if (device.hasMediaType(AVMediaTypeVideo)) {
                // Finally check the position and confirm we've got the back camera
                if(device.position == AVCaptureDevicePosition.Back) {
                    captureDevice = device as? AVCaptureDevice
                }
            }
        }
        
        if captureDevice != nil {
            beginSession()
        }
        
        stillImageOutput.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
        if captureSession.canAddOutput(stillImageOutput) {
            captureSession.addOutput(stillImageOutput)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func beginSession() {
        do {
            captureSession.addInput(try AVCaptureDeviceInput(device: captureDevice) as AVCaptureDeviceInput)
        } catch let err as NSError {
            print("error: \(err.localizedDescription)")
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.view.layer.addSublayer(previewLayer!)
        //        previewLayer?.frame = self.view.layer.frame
        previewLayer?.frame = PhotoImageView.frame
        captureSession.startRunning()
    }
    
    func setButtonShowHide(mode: Int) {
        switch  mode {
        case 0:
            // hide album button and swap camera button and take photo button
            self.AlbumBtn.hidden = true
            self.SwapCameraBtn.hidden = true
            self.TakePhotoBtn.hidden = true
            
            // show trash button and save button and upload button
            self.TrashBtn.hidden = false
            self.SaveBtn.hidden = false
            self.UploadBtn.hidden = false
            
            break
        case 1:
            // hide album button and swap camera button and take photo button
            self.AlbumBtn.hidden = false
            self.SwapCameraBtn.hidden = false
            self.TakePhotoBtn.hidden = false
            
            // show trash button and save button  and upload button
            self.TrashBtn.hidden = true
            self.SaveBtn.hidden = true
            self.UploadBtn.hidden = true
            
            break
        default:
            break
        }
    }
    
    // reference: http://stackoverflow.com/questions/30014651/cropping-avcapturevideopreviewlayer-output-to-a-square
    @IBAction func takePhoto(sender: AnyObject) {
        
        if let videoConnection = stillImageOutput.connectionWithMediaType(AVMediaTypeVideo) {
            stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection) {
                (imageDataSampleBuffer, error) -> Void in
                
                if let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer) {
                    if let image = UIImage(data: imageData) {
                        // stop capture
                        self.captureSession.stopRunning()
                        
                        self.squareImage = self.cropImageInSquare(image)
                        self.PhotoImageView.image = self.squareImage
                        
                        // hide previewLayer
                        self.previewLayer?.hidden = true
                        
                        self.setButtonShowHide(0)
                    }
                }
            }
        }
    }
    
    // Crop Image in Square
    func cropImageInSquare(image: UIImage) -> UIImage {
        var width: CGFloat
        var height: CGFloat
        
        if image.size.width <= image.size.height {
            width = image.size.width
            height = image.size.height
        }
        else {
            width = image.size.height
            height = image.size.width
        }
        
        UIGraphicsBeginImageContext(CGSizeMake(width, width))
        let offsetY = floor((height - width) / 2.0)
        image.drawInRect(CGRectMake(0, -offsetY, image.size.width, image.size.height))
        let smallImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return smallImage
    }
    
    func saveToCamera(sender: UITapGestureRecognizer) {
        if let videoConnection = stillImageOutput.connectionWithMediaType(AVMediaTypeVideo) {
            stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection) {
                (imageDataSampleBuffer, error) -> Void in
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                UIImageWriteToSavedPhotosAlbum(UIImage(data: imageData)!, nil, nil, nil)
            }
        }
    }
    
    // Delete Current Photo and start capture
    @IBAction func deletePhoto(sender: AnyObject) {
        self.previewLayer?.hidden = false
        self.captureSession.startRunning()
        self.setButtonShowHide(1)
    }
    
    @IBAction func savePhoto(sender: AnyObject) {
        // TODO: How to save photo in a album belong to this app.
        
//        UIImageWriteToSavedPhotosAlbum(squareImage!, nil, nil, nil)
        UIImageWriteToSavedPhotosAlbum(PhotoImageView.image!, nil, nil, nil)
        
        self.setButtonShowHide(1)
    }
    
    @IBAction func UploadPhoto(sender: AnyObject) {
    }
}

