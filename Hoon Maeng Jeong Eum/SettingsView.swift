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
                        koreanText("글자 자동 읽기")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundStyle(inkColor)
                        koreanText("화면에 글자가 나타나면 자동으로 읽어 줍니다")
                            .font(.caption)
                            .foregroundStyle(inkColor.opacity(0.6))
                    }
                }
                .koreanAccessibilityLabel("글자 자동 읽기")
                .koreanAccessibilityHint("화면에 글자가 나타나면 자동으로 읽어 줍니다")
                .tint(themeInkColor)
                .listRowBackground(Color(white: 0.12))

                Toggle(isOn: $activeBrailleSound) {
                    VStack(alignment: .leading, spacing: 4) {
                        koreanText("점자 위치 음성 안내")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundStyle(inkColor)
                        koreanText("점을 만질 때 몇 번 점인지와 돌출 여부를 음성으로 알려 줍니다")
                            .font(.caption)
                            .foregroundStyle(inkColor.opacity(0.6))
                    }
                }
                .koreanAccessibilityLabel("점자 위치 음성 안내")
                .koreanAccessibilityHint("점을 만질 때 몇 번 점인지와 돌출 여부를 음성으로 알려 줍니다")
                .tint(themeInkColor)
                .listRowBackground(Color(white: 0.12))
            } header: {
                koreanText("음성 및 촉각 안내")
            }
        }
        .scrollContentBackground(.hidden)
        .background(mainPaperColor)
        .navigationTitle(koreanText("설정"))
        .navigationBarTitleDisplayMode(.large)
    }
}
