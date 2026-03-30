//
//  CameraViewModel.swift
//  DynamicNotch
//
//  Created by Hlwan Aung Phyo on 2026/03/30.
//

import AVFoundation
import SwiftUI
import Combine

@MainActor
final class CameraViewModel: ObservableObject {
    @Published var isPreviewVisible = false
    @Published var permissionStatus: CameraPermissionStatus
    @Published var isEnabled: Bool
    
    var session: AVCaptureSession { sessionManager.session }
    
    private let permissionProvider: CameraPermissionProviding
    private let sessionManager: CameraSessionManaging
    
    init(
        permissionProvider: CameraPermissionProviding,
        sessionManager: CameraSessionManaging,
        isEnabled: Bool
    ) {
        self.permissionProvider = permissionProvider
        self.sessionManager = sessionManager
        self.permissionStatus = permissionProvider.status
        self.isEnabled = isEnabled
    }
    
    
    func togglePreview() async {
        guard isEnabled else { return }
        
            if isPreviewVisible {
                hidePreview()
                return
            }
            
            let status = await ensurePermission()
            guard status == .authorized else { return }
            
            do {
                try sessionManager.start()
                isPreviewVisible = true
            } catch {
                isPreviewVisible = false
            }
    }
    
    func hidePreview() {
        isPreviewVisible = false
        sessionManager.stop()
    }
    
    private func ensurePermission() async -> CameraPermissionStatus {
        let status = permissionProvider.status
        switch status {
            case .authorized:
                permissionStatus = .authorized
                return .authorized
            case .notDetermined:
                let result = await permissionProvider.requestPermission()
                self.permissionStatus = result
                return result
            case .denied:
                permissionStatus = .denied
                return .denied
        }
    }
}
