//
//  NotchContentProvider.swift
//  DynamicNotch
//
//  Created by Евгений Петрукович on 2/25/26.
//

import SwiftUI

protocol NotchContentProtocol {
    var cameraWidth: CGFloat { get }
    var cameraHeight: CGFloat { get }
    var cameraSpacing: CGFloat { get }
    var cameraHorizontalPadding: CGFloat { get }
    
    var id: String { get }
    var priority: Int { get }
    var strokeColor: Color { get }
    var offsetXTransition: CGFloat { get }
    var offsetYTransition: CGFloat { get }
    var expandedOffsetXTransition: CGFloat { get }
    var expandedOffsetYTransition: CGFloat { get }
    var isExpandable: Bool { get }
    var expandsOnTap: Bool { get }
    
    func size(baseWidth: CGFloat, baseHeight: CGFloat) -> CGSize
    func expandedSize(baseWidth: CGFloat, baseHeight: CGFloat) -> CGSize
    func cornerRadius(baseRadius: CGFloat) -> (top: CGFloat, bottom: CGFloat)
    func expandedCornerRadius(baseRadius: CGFloat) -> (top: CGFloat, bottom: CGFloat)
    
    @MainActor @ViewBuilder func makeView() -> AnyView
    @MainActor @ViewBuilder func makeExpandedView() -> AnyView
}

extension NotchContentProtocol {
    func expandedSizeIncludingCamera(baseWidth: CGFloat, baseHeight: CGFloat) -> CGSize {
        let baseExpanded = expandedSize(baseWidth: baseWidth, baseHeight: baseHeight)
        let cameraExtras = cameraWidth + (cameraSpacing * 2) + (cameraHorizontalPadding * 2)
        
        let width = baseExpanded.width + cameraExtras
        let height = max(baseExpanded.height, cameraHeight)
        
        return CGSize(width: width, height: height)
    }
}

extension NotchContentProtocol {
    var cameraWidth: CGFloat { 120 }
    var cameraHeight: CGFloat { 120 }
    var cameraSpacing: CGFloat { 15 }
    var cameraHorizontalPadding: CGFloat { 30 }
    
    var priority: Int { 0 }
    var strokeColor: Color { .white.opacity(0.2) }
    var offsetXTransition: CGFloat { 0 }
    var offsetYTransition: CGFloat { 0 }
    var isExpandable: Bool { false }
    var expandsOnTap: Bool { isExpandable }
    var expandedOffsetXTransition: CGFloat { offsetXTransition }
    var expandedOffsetYTransition: CGFloat { offsetYTransition }
    
    func cornerRadius(baseRadius: CGFloat) -> (top: CGFloat, bottom: CGFloat) {
        return (top: baseRadius - 4, bottom: baseRadius)
    }

    func expandedSize(baseWidth: CGFloat, baseHeight: CGFloat) -> CGSize {
        size(baseWidth: baseWidth, baseHeight: baseHeight)
    }

    func expandedCornerRadius(baseRadius: CGFloat) -> (top: CGFloat, bottom: CGFloat) {
        cornerRadius(baseRadius: baseRadius)
    }

    @MainActor
    func makeExpandedView() -> AnyView {
        makeView()
    }
}
