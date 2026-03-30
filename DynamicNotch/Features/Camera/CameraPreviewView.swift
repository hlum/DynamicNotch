//
//  CameraPreviewView.swift
//  DynamicNotch
//
//  Created by Hlwan Aung Phyo on 2026/03/30.
//

import AVFoundation
import SwiftUI
internal import AppKit

struct CameraPreviewView: NSViewRepresentable {
    let session: AVCaptureSession
    
    func makeNSView(context: Context) -> some NSView {
        let view = NSView()
        view.wantsLayer = true
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        
        if let connection = previewLayer.connection,
           connection.isVideoMirroringSupported {
            connection.automaticallyAdjustsVideoMirroring = false
            connection.isVideoMirrored = true
        } else {
            previewLayer.setAffineTransform(CGAffineTransform(scaleX: -1, y: 1))
        }
        view.layer = previewLayer
        return view
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) {
        guard let previewLayer = nsView.layer as? AVCaptureVideoPreviewLayer else { return }
        previewLayer.session = session
    }
}
