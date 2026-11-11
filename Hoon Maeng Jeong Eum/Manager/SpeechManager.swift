//
//  File.swift
//  Braille_Read
//
//  Created by Oliver Park on 1/9/26.
//

import Foundation
import AVKit
import AVFoundation
import SwiftUI

@MainActor
class BrailleSpeechManager {
    static let shared = BrailleSpeechManager()
    private let synthesizer = AVSpeechSynthesizer()
    
    func speak(_ text: String, language: String = "ko-KR") {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = 0.4

        synthesizer.speak(utterance)
    }
    
    func speakQueued(_ text: String, language: String = "ko-KR") {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = 0.4
        synthesizer.speak(utterance)
    }
}
