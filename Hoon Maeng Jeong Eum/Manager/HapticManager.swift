//
//  File.swift
//  Braille_Read
//
//  Created by Oliver Park on 1/3/26.
//

import Foundation
import AVFoundation
import SwiftUI

@MainActor
class HapticManager {
    static let instance = HapticManager()
    
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMed = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    
    func triggerActiveHaptic() {
        impactHeavy.prepare()
        impactHeavy.impactOccurred()
    }
    
    func triggerInactiveHaptic() {
        impactLight.prepare()
        impactLight.impactOccurred(intensity: 0.5)
    }
    
    func triggerTransitionHaptic() {
        impactMed.prepare()
        impactMed.impactOccurred(intensity: 0.4)
    }
}
