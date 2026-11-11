//
//  File.swift
//  Braille_Read_1
//
//  Created by Oliver Park on 1/3/26.
//

import Foundation
import SwiftUI
import AVKit
import AVFoundation
import AudioToolbox

@MainActor
class SoundManager {
     static let instance = SoundManager()
    var player: AVAudioPlayer?

    func playSound() {
        guard let url = Bundle.main.url(forResource: "Tada-sound", withExtension: ".mp3") else {
            print("Sound file not found")
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch let error {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }

    func playDing() {
        AudioServicesPlaySystemSound(1057) 
    }
}
