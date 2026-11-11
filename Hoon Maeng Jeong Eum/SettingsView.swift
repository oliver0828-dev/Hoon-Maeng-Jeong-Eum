//
//  SettingsView.swift
//  Braille_Read_1
//
//  Created by Oliver Park on 2/14/26.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("autoAnnounce") private var autoAnnounce: Bool = true
    @AppStorage("activeBrailleSound") private var activeBrailleSound: Bool = true

    private let mainPaperColor = Color.black
    private let cardPaperColor = Color(white: 0.12)
    private let inkColor = Color(red: 1.0, green: 0.88, blue: 0.0)
    private let themeInkColor = Color(red: 1.0, green: 0.88, blue: 0.0)

    var body: some View {
        if #available(iOS 16.1, *) {
            NavigationStack {
                settingsList
                    .fontDesign(.rounded)
            }
        } else {
            NavigationView {
                settingsList
            }
            .navigationViewStyle(.stack)
        }
    }

    private var settingsList: some View {
        List {
            Section {
                Toggle(isOn: $autoAnnounce) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Auto-Announce Letters")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundStyle(inkColor)
                        Text("Automatically speak the letter when it appears on screen")
                            .font(.caption)
                            .foregroundStyle(inkColor.opacity(0.6))
                    }
                }
                .tint(themeInkColor)
                .listRowBackground(Color(white: 0.12))

                Toggle(isOn: $activeBrailleSound) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Active Braille Sound")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundStyle(inkColor)
                        Text("Play a sound when touching an active dot")
                            .font(.caption)
                            .foregroundStyle(inkColor.opacity(0.6))
                    }
                }
                .tint(themeInkColor)
                .listRowBackground(Color(white: 0.12))
            } header: {
                Text("Sound")
            }
        }
        .scrollContentBackground(.hidden)
        .background(mainPaperColor)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
    }
}
