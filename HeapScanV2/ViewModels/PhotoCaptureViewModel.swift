//
//  PhotoCaptureViewModel.swift
//  موثوق رحاب
//

import Foundation
import AVFoundation
import UIKit
import Photos
import Combine

class PhotoCaptureViewModel: NSObject, ObservableObject {
    @Published var photos: [ScanSession] = []
    @Published var isSaving = false
    @Published var isFlashOn = false
    @Published var cameraReady = false
    
    let captureSession = AVCaptureSession()
    private var photoOutput = AVCapturePhotoOutput()
    private let locationManager = LocationManager()
    private let watermarkService = WatermarkService.shared
    private var isSessionConfigured = false
    
    private var userName: String {
        UserDefaults.standard.string(forKey: "userName") ?? ""
    }
    
    override init() {
        super.init()
        locationManager.requestPermission()
        locationManager.startUpdating()
    }
    
    func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupAndStartCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        self?.setupAndStartCamera()
                    }
                }
            }
        default:
            break
        }
    }
    
    private func setupAndStartCamera() {
        guard !isSessionConfigured else {
            startSession()
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            self.captureSession.beginConfiguration()
            self.captureSession.sessionPreset = .photo
            
            // Remove existing inputs/outputs
            for input in self.captureSession.inputs {
                self.captureSession.removeInput(input)
            }
            for output in self.captureSession.outputs {
                self.captureSession.removeOutput(output)
            }
            
            guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                  let input = try? AVCaptureDeviceInput(device: camera) else {
                self.captureSession.commitConfiguration()
                return
            }
            
            if self.captureSession.canAddInput(input) {
                self.captureSession.addInput(input)
            }
            
            self.photoOutput = AVCapturePhotoOutput()
            if self.captureSession.canAddOutput(self.photoOutput) {
                self.captureSession.addOutput(self.photoOutput)
            }
            
            self.captureSession.commitConfiguration()
            self.isSessionConfigured = true
            
            // Start running
            self.captureSession.startRunning()
            
            DispatchQueue.main.async {
                self.cameraReady = true
            }
        }
    }
    
    func startSession() {
        guard isSessionConfigured else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self, !self.captureSession.isRunning else { return }
            self.captureSession.startRunning()
            DispatchQueue.main.async {
                self.cameraReady = true
            }
        }
    }
    
    func stopSession() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.stopRunning()
        }
    }
    
    func capturePhoto() {
        guard captureSession.isRunning else { return }
        let settings = AVCapturePhotoSettings()
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
           device.hasFlash {
            settings.flashMode = isFlashOn ? .on : .off
        }
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func toggleFlash() {
        isFlashOn.toggle()
    }
    
    func deletePhoto(_ photo: ScanSession) {
        photos.removeAll { $0.id == photo.id }
    }
    
    func saveAllToGallery() {
        isSaving = true
        
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { [weak self] status in
            guard let self = self, status == .authorized else {
                DispatchQueue.main.async { self?.isSaving = false }
                return
            }
            
            let group = DispatchGroup()
            
            for photo in self.photos {
                group.enter()
                PHPhotoLibrary.shared().performChanges {
                    PHAssetChangeRequest.creationRequestForAsset(from: photo.image)
                } completionHandler: { _, _ in
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                self.isSaving = false
            }
        }
    }
}

extension PhotoCaptureViewModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let originalImage = UIImage(data: data) else { return }
        
        let now = Date()
        let coordinate = locationManager.location?.coordinate
        
        // Add watermark with logo
        let watermarkedImage = watermarkService.addWatermark(
            to: originalImage,
            photographerName: userName,
            date: now,
            location: coordinate
        ) ?? originalImage
        
        let capturedPhoto = ScanSession(
            image: watermarkedImage,
            timestamp: now,
            location: coordinate,
            photographerName: userName
        )
        
        DispatchQueue.main.async {
            self.photos.append(capturedPhoto)
        }
    }
}
