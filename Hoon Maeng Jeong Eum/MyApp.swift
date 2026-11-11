//
//  MyApp.swift
//  Braille_Read
//
//  Created by Oliver Park on 2/16/26.
//

import SwiftUI

extension UIFont {
    static func roundedSystemFont(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        let systemFont = UIFont.systemFont(ofSize: size, weight: weight)
        if let descriptor = systemFont.fontDescriptor.withDesign(.rounded) {
            return UIFont(descriptor: descriptor, size: size)
        }
        return systemFont
    }
}

@main
struct Braille_Read_1App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    private let mainBackgroundColor = Color.black
    private let inkColor = Color(red: 1.0, green: 0.88, blue: 0.0)
    private let themeInkColor = Color(red: 1.0, green: 0.88, blue: 0.0)
    
    @StateObject private var viewModel = ContentViewModel()
    @AppStorage("selected_braille_type") private var selectedTypeRaw: String = ""
    @State private var showGradeSelection = false
    
    init() {
        let yellowColor = UIColor(red: 1.0, green: 0.88, blue: 0.0, alpha: 1.0)

        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()

        let inlineFont = UIFont.roundedSystemFont(ofSize: 20, weight: .bold)
        let largeFont = UIFont.roundedSystemFont(ofSize: 34, weight: .bold)

        appearance.titleTextAttributes = [.font: inlineFont, .foregroundColor: yellowColor]
        appearance.largeTitleTextAttributes = [.font: largeFont, .foregroundColor: yellowColor]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance

        let tabAppearance = UITabBarAppearance()
        tabAppearance.backgroundColor = .black
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
    }
    
    var body: some Scene {
        WindowGroup {
            if selectedTypeRaw.isEmpty {
                if showGradeSelection {
                    GradeSelectionView()
                } else {
                    WelcomeView(onGetStarted: { showGradeSelection = true })
                }
            } else {
                TabView {
                    LearnTab
                        .tabItem {
                            Label { koreanText("학습") } icon: { Image(systemName: "book.fill") }
                        }
                    
                    SettingsView()
                        .tabItem {
                            Label { koreanText("설정") } icon: { Image(systemName: "gearshape.fill") }
                        }
                }
                .tint(themeInkColor)
                .preferredColorScheme(.dark)
                .environmentObject(viewModel)
                .onAppear {
                    if UIAccessibility.isVoiceOverRunning {
                        UIAccessibility.post(notification: .screenChanged, argument: nil)
                    }
                }
            }
        }
    }
    
    private var activeBrailleType: BrailleType {
        BrailleType(rawValue: selectedTypeRaw) ?? .jeongja
    }
    
    @ViewBuilder
    private var LearnTab: some View {
        if #available(iOS 16.1, *) {
            NavigationStack(path: $viewModel.path) {
                contentView
                    .background(mainBackgroundColor)
                    .navigationTitle(koreanText("학습"))
                    .navigationBarTitleDisplayMode(.large)
                    .fontDesign(.rounded)
                    .navigationDestination(for: Path.self) { path in
                        switch path {
                        case .level(let level):
                            if level.useLandscape {
                                BrailleLandscapeView(level: level, levelTitle: level.title, letters: level.letters, levelStatus: .constant(false))
                            } else {
                                BraillePortraitView(level: level, levelTitle: level.title, letters: level.letters, levelStatus: .constant(false))
                            }
                        case .complete(let level):
                            LevelCompletionView(levelTitle: level.title, nextLevel: findNextLevel(after: level))
                        }
                    }
            }
        } else {
            NavigationView {
                contentView
                    .background(mainBackgroundColor)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            koreanText("학습")
                                .font(.system(.title2, design: .rounded, weight: .bold))
                                .foregroundStyle(inkColor)
                        }
                    }
                    .navigationBarTitleDisplayMode(.inline)
            }
            .navigationViewStyle(.stack)
        }
    }
    
    @ViewBuilder
    var contentView: some View {
        ScrollView {
            VStack(spacing: 24) {
                brailleTypeToggle
                
                let sections = BrailleData.sections(for: activeBrailleType)
                
                ForEach(sections) { section in
                    VStack(alignment: .leading, spacing: 10) {
                        koreanText(section.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(inkColor)
                            .padding(.horizontal)
                            .accessibilityAddTraits(.isHeader)
                        
                        ForEach(section.levels) { level in
                            CardView(level: level)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
    }
    
    private var brailleTypeToggle: some View {
        HStack(spacing: 0) {
            ForEach(BrailleType.allCases, id: \.self) { type in
                Button {
                    HapticManager.instance.triggerTransitionHaptic()
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTypeRaw = type.rawValue
                    }
                    BrailleSpeechManager.shared.speak("\(type.displayName) \(type.subtitle) 과정 선택됨", language: "ko-KR", delay: 0.15)
                } label: {
                    koreanText("\(type.displayName) (\(type.subtitle))")
                        .font(.subheadline)
                        .fontWeight(activeBrailleType == type ? .bold : .medium)
                        .foregroundStyle(activeBrailleType == type ? .black : inkColor.opacity(0.6))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            activeBrailleType == type
                            ? themeInkColor
                            : Color.clear
                        )
                        .clipShape(Capsule())
                }
                .buttonStyle(PlainButtonStyle())
                .koreanAccessibilityLabel("\(type.displayName), \(type.subtitle)")
                .koreanAccessibilityHint("두 번 탭하여 \(type.displayName) \(type.subtitle) 과정으로 전환합니다")
                .accessibilityAddTraits(activeBrailleType == type ? .isSelected : [])
            }
        }
        .padding(4)
        .background(Color(white: 0.12))
        .clipShape(Capsule())
        .padding(.horizontal)
    }
    
    private func findNextLevel(after current: BrailleLevel) -> BrailleLevel? {
        let allLevels = BrailleData.sections(for: activeBrailleType).flatMap { $0.levels }
        guard let idx = allLevels.firstIndex(where: { $0.id == current.id }),
              idx + 1 < allLevels.count else { return nil }
        return allLevels[idx + 1]
    }
}
