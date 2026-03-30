//
//  CameraPermissionProvider.swift
//  DynamicNotch
//
//  Created by Hlwan Aung Phyo on 2026/03/30.
//

import AVFoundation

final class CameraPermissionProvider: CameraPermissionProviding {
    var status: CameraPermissionStatus {
        CameraPermissionStatus(AVCaptureDevice.authorizationStatus(for: .video))
    }
    
    
    func requestPermission() async -> CameraPermissionStatus {
        let granted = await AVCaptureDevice.requestAccess(for: .video)
        return granted ? .authorized : .denied
    }
}
