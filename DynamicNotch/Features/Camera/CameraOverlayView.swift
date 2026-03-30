//
//  CameraOverlayView.swift
//  DynamicNotch
//
//  Created by Hlwan Aung Phyo on 2026/03/30.
//

import AVFoundation
import SwiftUI

struct CameraOverlayView: View {
    @StateObject var cameraViewModel: CameraViewModel

    var body: some View {
        Button {
            Task {
                await cameraViewModel.togglePreview()
            }
        } label: {
            CameraPreviewCircle(
                session: cameraViewModel.session,
                showPreview: cameraViewModel.isPreviewVisible && cameraViewModel.permissionStatus == .authorized
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("notch.camera.button")
    }
}


private struct CameraPreviewCircle: View {
    let session: AVCaptureSession
    let showPreview: Bool
    
    var body: some View {
        ZStack {
            if showPreview {
                CameraPreviewView(session: session)
            } else {
                Image(systemName: "camera.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .padding(6)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .clipShape(Circle())
        .contentShape(Circle())
    }
}
