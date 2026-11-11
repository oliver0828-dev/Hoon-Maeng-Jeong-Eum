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
import UIKit

@MainActor
class BrailleSpeechManager {
    static let shared = BrailleSpeechManager()
    private let synthesizer = AVSpeechSynthesizer()
    private var pendingWorkItem: DispatchWorkItem?

    private init() {
        configureAudioSession()
    }

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers, .mixWithOthers])
            try session.setActive(true)
        } catch {
            print("AudioSession configuration error: \(error.localizedDescription)")
        }
    }

    func stop() {
        pendingWorkItem?.cancel()
        pendingWorkItem = nil
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }

    /// Speaks a full announcement without overlapping with VoiceOver.
    /// When VoiceOver is active, routes speech through VoiceOver's single speech queue.
    func speak(_ text: String, language: String = "ko-KR", rate: Float = 0.42, delay: TimeInterval = 0) {
        pendingWorkItem?.cancel()
        pendingWorkItem = nil

        if delay > 0 {
            let work = DispatchWorkItem { [weak self] in
                Task { @MainActor in
                    self?.performSpeak(text, language: language, rate: rate, queueForVoiceOver: true)
                }
            }
            pendingWorkItem = work
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: work)
        } else {
            performSpeak(text, language: language, rate: rate, queueForVoiceOver: false)
        }
    }

    /// Immediately announces a touched braille dot (interrupting prior dot speech so it tracks finger movement).
    func speakDot(dotNumber: Int, isActive: Bool, cellIndex: Int? = nil, totalCells: Int = 1, language: String = "ko-KR") {
        pendingWorkItem?.cancel()
        pendingWorkItem = nil

        let prefix: String
        if let cellIndex, totalCells > 1 {
            prefix = "\(cellIndex + 1)칸 "
        } else {
            prefix = ""
        }

        let message = isActive ? "\(prefix)\(dotNumber)번" : "\(prefix)\(dotNumber)번 빈 점"
        performSpeak(message, language: language, rate: 0.48, queueForVoiceOver: false)
    }

    func speakQueued(_ text: String, language: String = "ko-KR") {
        if UIAccessibility.isVoiceOverRunning {
            if synthesizer.isSpeaking {
                synthesizer.stopSpeaking(at: .immediate)
            }
            let attributed = NSAttributedString(
                string: text,
                attributes: [
                    .accessibilitySpeechLanguage: language,
                    .accessibilitySpeechQueueAnnouncement: true
                ]
            )
            UIAccessibility.post(notification: .announcement, argument: attributed)
            return
        }

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = 0.42
        synthesizer.speak(utterance)
    }

    private func performSpeak(_ text: String, language: String, rate: Float, queueForVoiceOver: Bool) {
        if UIAccessibility.isVoiceOverRunning {
            if synthesizer.isSpeaking {
                synthesizer.stopSpeaking(at: .immediate)
            }
            var attributes: [NSAttributedString.Key: Any] = [
                .accessibilitySpeechLanguage: language
            ]
            if queueForVoiceOver {
                attributes[.accessibilitySpeechQueueAnnouncement] = true
            }
            let attributed = NSAttributedString(string: text, attributes: attributes)
            UIAccessibility.post(notification: .announcement, argument: attributed)
            return
        }

        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = rate
        synthesizer.speak(utterance)
    }
}
