import SwiftUI
import Combine
internal import AppKit
import UniformTypeIdentifiers

struct NotchView: View {
    @ObservedObject var notchViewModel: NotchViewModel
    @ObservedObject var notchEventCoordinator: NotchEventCoordinator
    @ObservedObject var powerViewModel: PowerViewModel
    @ObservedObject var bluetoothViewModel: BluetoothViewModel
    @ObservedObject var networkViewModel: NetworkViewModel
    @ObservedObject var downloadViewModel: DownloadViewModel
    @ObservedObject var focusViewModel: FocusViewModel
    @ObservedObject var airDropViewModel: AirDropNotchViewModel
    @ObservedObject var airDropController: NotchAirDropController
    @ObservedObject var generalSettingsViewModel: GeneralSettingsViewModel
    @ObservedObject var nowPlayingViewModel: NowPlayingViewModel
    @ObservedObject var lockScreenManager: LockScreenManager
    @StateObject var cameraViewModel: CameraViewModel
    
    var body: some View {
        ZStack {
            notchBody
                .environment(\.notchScale, notchViewModel.notchModel.scale)
                .background(
                    NotchEventHandlersView(
                        notchEventCoordinator: notchEventCoordinator,
                        powerViewModel: powerViewModel,
                        bluetoothViewModel: bluetoothViewModel,
                        networkViewModel: networkViewModel,
                        downloadViewModel: downloadViewModel,
                        focusViewModel: focusViewModel,
                        airDropViewModel: airDropViewModel,
                        generalSettingsViewModel: generalSettingsViewModel,
                        nowPlayingViewModel: nowPlayingViewModel,
                        lockScreenManager: lockScreenManager
                    )
                )
                .onChange(of: notchViewModel.notchModel.content?.id) {
                    notchViewModel.handleStrokeVisibility()
                }
                .onChange(of: generalSettingsViewModel.notchWidth) {
                    notchViewModel.updateDimensions()
                }
                .onChange(of: generalSettingsViewModel.notchHeight) {
                    notchViewModel.updateDimensions()
                }
            
            if notchViewModel.notchModel.content == nil {
                NotchShape(
                    topCornerRadius: notchViewModel.notchModel.cornerRadius.top,
                    bottomCornerRadius: notchViewModel.notchModel.cornerRadius.bottom
                )
                .fill(Color.black)
                .frame(
                    width: notchViewModel.notchModel.baseWidth - 20,
                    height: notchViewModel.notchModel.baseHeight
                )
                .customNotchPressable(
                    notchViewModel: notchViewModel,
                    isPressed: $notchViewModel.isPressed,
                    baseSize: notchViewModel.interactiveNotchSize
                )
                .contextMenu {
                    if !generalSettingsViewModel.isMenuBarIconVisible {
                        contextMenuItem
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

private extension NotchView {
    @ViewBuilder
    var notchBody: some View {
        NotchShape(
            topCornerRadius: notchViewModel.interactiveCornerRadius.top,
            bottomCornerRadius: notchViewModel.interactiveCornerRadius.bottom
        )
        .fill(.black)
        .stroke(
            generalSettingsViewModel.isShowNotchStrokeEnabled ?
            visibleStrokeColor : Color.clear,
            lineWidth: generalSettingsViewModel.notchStrokeWidth
        )
        .overlay {
            contentOverlay
                .mask(
                    NotchShape(
                        topCornerRadius: notchViewModel.interactiveCornerRadius.top,
                        bottomCornerRadius: notchViewModel.interactiveCornerRadius.bottom
                    )
                )
        }
        .overlay {
            AirDropDestinationView(
                isTargeted: $airDropController.isTargeted,
                onDropPasteboard: { pasteboard in
                    airDropController.handlePasteboardDrop(pasteboard)
                }
            )
        }
        .frame(
            width: notchViewModel.interactiveNotchSize.width,
            height: notchViewModel.interactiveNotchSize.height
        )
        .offset(y: 1)
        .customNotchPressable(
            notchViewModel: notchViewModel,
            isPressed: $notchViewModel.isPressed,
            baseSize: notchViewModel.interactiveNotchSize
        )
        .customNotchSwipeDismissable(
            notchViewModel: notchViewModel
        )
        .onHover(perform: { isHovered in
            guard generalSettingsViewModel.expandOnHoverEnabled else { return }
            if isHovered {
                notchViewModel.handleActiveContentTap()
            } else {
                cameraViewModel.hidePreview()
                notchViewModel.handleOutsideClick()
            }
        })
        .contextMenu {
            if !generalSettingsViewModel.isMenuBarIconVisible {
                contextMenuItem
            }
        }
        .animation(notchViewModel.animations.strokeVisibility, value: generalSettingsViewModel.isShowNotchStrokeEnabled)
        .animation(notchViewModel.animations.notchVisibility, value: notchViewModel.showNotch)
    }

    var visibleStrokeColor: Color {
        notchViewModel.notchModel.content?.strokeColor ?? notchViewModel.cachedStrokeColor
    }
    
    @ViewBuilder
    var contentOverlay: some View {
        if let content = notchViewModel.notchModel.content {
            renderedContentView(for: content)
                .id(notchViewModel.notchModel.presentationID)
                .transition(
                    notchViewModel.contentTransition(
                        offsetX: notchViewModel.notchModel.offsetXTransition,
                        offsetY: notchViewModel.notchModel.offsetYTransition
                    )
                )
        }
    }
    
    @MainActor
    @ViewBuilder
    func renderedContentView(for content: NotchContentProtocol) -> some View {
        if notchViewModel.notchModel.isPresentingExpandedLiveActivity {
            let spacing = content.cameraSpacing

            HStack(alignment: .center, spacing: spacing) {
                content.makeExpandedView()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .layoutPriority(1)
                                
                if generalSettingsViewModel.isCameraEnabled {
                    cameraPlaceholder(for: content)
                }
            }
            .frame(
                maxWidth: notchViewModel.interactiveNotchSize.width,
                maxHeight: notchViewModel.interactiveNotchSize.height,
                alignment: .leading
            )
            .padding(.horizontal, 80)
        } else {
            content.makeView()
        }
    }
    
    @ViewBuilder
    private func cameraPlaceholder(for content: NotchContentProtocol) -> some View {
        CameraOverlayView(cameraViewModel: cameraViewModel)
            .frame(width: content.cameraWidth, height: content.cameraHeight, alignment: .center)
            .frame(maxHeight: .infinity, alignment: .center)
            .opacity(0.5)
    }
    
    @ViewBuilder
    var contextMenuItem: some View {
        SettingsLink {
            Image(systemName: "gearshape")
            Text("Settings")
        }
        
        Divider()
        Button(action: { NSApp.terminate(nil) }) {
            Image(systemName: "rectangle.portrait.and.arrow.right")
            Text("Quit")
        }
    }
}

// MARK: listening events here
private struct NotchEventHandlersView: View {
    let notchEventCoordinator: NotchEventCoordinator
    let powerViewModel: PowerViewModel
    let bluetoothViewModel: BluetoothViewModel
    let networkViewModel: NetworkViewModel
    let downloadViewModel: DownloadViewModel
    let focusViewModel: FocusViewModel
    let airDropViewModel: AirDropNotchViewModel
    let generalSettingsViewModel: GeneralSettingsViewModel
    let nowPlayingViewModel: NowPlayingViewModel
    let lockScreenManager: LockScreenManager
    
    var body: some View {
        Color.clear
            .onAppear {
//                notchEventCoordinator.handleCameraEvent()
            }
            .onReceive(powerViewModel.$event.compactMap { $0 }) { event in
                notchEventCoordinator.handlePowerEvent(event)
            }
            .onReceive(bluetoothViewModel.$event.compactMap { $0 }) { event in
                notchEventCoordinator.handleBluetoothEvent(event)
            }
            .onReceive(networkViewModel.$networkEvent.compactMap { $0 }) { event in
                notchEventCoordinator.handleNetworkEvent(event)
            }
            .onReceive(downloadViewModel.$event.compactMap { $0 }) { event in
                notchEventCoordinator.handleDownloadEvent(event)
            }
            .onReceive(focusViewModel.$focusEvent.compactMap { $0 }) { event in
                notchEventCoordinator.handleFocusEvent(event)
            }
            .onReceive(airDropViewModel.$event.compactMap { $0 }) { event in
                notchEventCoordinator.handleAirDropEvent(event)
            }
            .onReceive(generalSettingsViewModel.notchSizeEvent) { event in
                notchEventCoordinator.handleNotchWidthEvent(event)
            }
            .onReceive(nowPlayingViewModel.$event.compactMap { $0 }) { event in
                notchEventCoordinator.handleNowPlayingEvent(event)
            }
            .onReceive(lockScreenManager.$event.compactMap { $0 }) { event in
                notchEventCoordinator.handleLockScreenEvent(event)
            }
    }
}
