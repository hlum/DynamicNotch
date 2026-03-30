//
//  CameraSessionManager.swift
//  DynamicNotch
//
//  Created by Hlwan Aung Phyo on 2026/03/30.
//

import AVFoundation

final class CameraSessionManager: CameraSessionManaging {
    
    let session: AVCaptureSession = AVCaptureSession()
    private var isConfigured = false
    private var currentInput: AVCaptureDeviceInput?
    
    var isRunning: Bool { session.isRunning }
    
    func configureIfNeeded() throws {
        guard !isConfigured else { return }
        
        session.beginConfiguration()
        defer { session.commitConfiguration() }
        
        session.sessionPreset = .medium
        
        guard let device = AVCaptureDevice.default(for: .video) else {
            throw CameraSessionError.noVideoDevice
        }
        
        let input = try AVCaptureDeviceInput(device: device)
        guard session.canAddInput(input) else {
            throw CameraSessionError.failedToAddInput
        }
        
        session.addInput(input)
        currentInput = input
        
        isConfigured = true
    }
    
    func start() throws {
        try configureIfNeeded()
        if !session.isRunning {
            session.startRunning()
        }
    }
    
    func stop() {
        guard isConfigured else { return }
        
        if session.isRunning {
            session.stopRunning()
        }
        
        session.beginConfiguration()
        if let currentInput {
            session.removeInput(currentInput)
        }
        session.commitConfiguration()
        
        currentInput = nil
        isConfigured = false
    }
}

enum CameraSessionError: Error {
    case noVideoDevice
    case failedToAddInput
}
