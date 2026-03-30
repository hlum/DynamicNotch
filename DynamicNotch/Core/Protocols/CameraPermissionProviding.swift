//
//  CameraPermissionProviding.swift
//  DynamicNotch
//
//  Created by Hlwan Aung Phyo on 2026/03/30.
//

import Foundation
import AVFoundation

protocol CameraPermissionProviding {
    var status: CameraPermissionStatus { get }
    func requestPermission() async -> CameraPermissionStatus
}

enum CameraPermissionStatus {
    case notDetermined
    case authorized
    case denied
    
    init(_ status: AVAuthorizationStatus) {
        switch status {
            case .authorized:
                self = .authorized
            case .notDetermined:
                self = .notDetermined
            default:
                self = .denied
        }
    }
}
