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
    
    private let impactSoft = UIImpactFeedbackGenerator(style: .soft)
    private let impactMed = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let impactRigid = UIImpactFeedbackGenerator(style: .rigid)
    private let selectionGenerator = UISelectionFeedbackGenerator()
    private let notificationGenerator = UINotificationFeedbackGenerator()
    
    func triggerActiveHaptic() {
        impactHeavy.prepare()
        impactRigid.prepare()
        impactHeavy.impactOccurred(intensity: 1.0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.055) { [weak self] in
            self?.impactRigid.impactOccurred(intensity: 0.9)
        }
    }
    
    func triggerInactiveHaptic() {
        impactSoft.prepare()
        impactSoft.impactOccurred(intensity: 0.35)
    }
    
    func triggerTransitionHaptic() {
        impactMed.prepare()
        impactMed.impactOccurred(intensity: 0.7)
    }
    
    func triggerBoundaryHaptic() {
        selectionGenerator.prepare()
        selectionGenerator.selectionChanged()
    }
    
    func triggerCompletionHaptic() {
        notificationGenerator.prepare()
        notificationGenerator.notificationOccurred(.success)
    }
}
