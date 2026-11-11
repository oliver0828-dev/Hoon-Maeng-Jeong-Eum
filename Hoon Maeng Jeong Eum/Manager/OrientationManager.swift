//
//  OrientationManager.swift
//  Hoon Maeng Jeong Eum
//

import SwiftUI
import UIKit

/// App delegate that provides the currently allowed interface orientations.
/// The Info.plist allows portrait + landscape, and this lock narrows it down at runtime
/// so that only specific screens (e.g. `BrailleLandscapeView`) can rotate.
final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        OrientationManager.orientationLock
    }
}

enum OrientationManager {
    /// Orientations the app currently allows. Defaults to portrait.
    static var orientationLock: UIInterfaceOrientationMask = .portrait

    /// Locks the app to landscape and rotates the screen automatically.
    static func rotateToLandscape() {
        update(lock: .landscape, rotateTo: .landscapeRight)
    }

    /// Locks the app back to portrait and rotates the screen automatically.
    static func rotateToPortrait() {
        update(lock: .portrait, rotateTo: .portrait)
    }

    private static func update(lock: UIInterfaceOrientationMask, rotateTo target: UIInterfaceOrientationMask) {
        orientationLock = lock

        guard let windowScene = activeWindowScene else { return }

        // Tell UIKit the supported orientations changed, then request the rotation.
        windowScene.keyWindow?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
        windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: target)) { error in
            print("Orientation update failed: \(error.localizedDescription)")
        }
    }

    private static var activeWindowScene: UIWindowScene? {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        return scenes.first { $0.activationState == .foregroundActive } ?? scenes.first
    }
}
