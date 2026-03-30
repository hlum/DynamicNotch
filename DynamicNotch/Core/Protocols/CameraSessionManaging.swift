//
//  CameraSessionManaging.swift
//  DynamicNotch
//
//  Created by Hlwan Aung Phyo on 2026/03/30.
//

import AVFoundation

protocol CameraSessionManaging: AnyObject {
    var session: AVCaptureSession { get }
    var isRunning: Bool { get }
    
    func configureIfNeeded() throws
    func start() throws
    func stop()
}
