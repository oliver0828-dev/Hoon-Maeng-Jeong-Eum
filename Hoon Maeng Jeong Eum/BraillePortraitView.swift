//
//  BraillePortraitView.swift
//  Braille_Read_1
//
//  Created by Oliver Park on 1/3/26.
//

import SwiftUI
import AVFoundation
import AVKit

struct BraillePortraitView: View {
    @EnvironmentObject var viewModel: ContentViewModel
    
    let level: BrailleLevel
    let levelTitle: String
    let letters: [BrailleLetter]
    @Binding var levelStatus: Bool
    
    @AppStorage("autoAnnounce") private var autoAnnounce: Bool = true
    @AppStorage("activeBrailleSound") private var activeBrailleSound: Bool = true

    @State private var currentIndex: Int = 0
    @State private var showCompletionScreen: Bool = false
    @State private var hasAnnouncedCurrentLetter: Bool = false
    @AppStorage("selected_braille_type") private var selectedBrailleType: String = BrailleType.jeongja.rawValue
    @AppStorage("hasSeenGrade1PortraitTutorial") private var hasSeenGrade1Tutorial: Bool = false
    @AppStorage("hasSeenGrade2PortraitTutorial") private var hasSeenGrade2Tutorial: Bool = false
    @State private var showTutorial: Bool = {
        let typeRaw = UserDefaults.standard.string(forKey: "selected_braille_type") ?? BrailleType.jeongja.rawValue
        let key = typeRaw == BrailleType.yakja.rawValue ? "hasSeenGrade2PortraitTutorial" : "hasSeenGrade1PortraitTutorial"
        return !UserDefaults.standard.bool(forKey: key)
    }()

    private var hasSeenCurrentGradeTutorial: Bool {
        selectedBrailleType == BrailleType.yakja.rawValue ? hasSeenGrade2Tutorial : hasSeenGrade1Tutorial
    }

    private var progressKey: String { "\(level.storageKey)_progress" }
    
    private let mainPaperColor = Color.black
    private let cardPaperColor = Color(white: 0.12)
    private let inkColor = Color(red: 1.0, green: 0.88, blue: 0.0)
    private let themeInkColor = Color(red: 1.0, green: 0.88, blue: 0.0)
    
    private var currentLetter: BrailleLetter {
        if letters.isEmpty {
            return BrailleLetter(hangul: "?", englishName: "Error", activeDots: [])
        }
      
        if currentIndex < letters.count {
            return letters[currentIndex]
        } else {
            return letters[0]
        }
    }
    
    private var currentCells: [Set<Int>] {
        currentLetter.cells
    }
    
    private var brailleNumbersText: String {
        let allActiveDots = currentCells.flatMap { Array($0) }.sorted()
        let uniqueDots = Array(Set(allActiveDots)).sorted()
        
        if uniqueDots.isEmpty {
            return "No active dots"
        } else if uniqueDots.count == 1 {
            return "Braille Number: \(uniqueDots.first!)"
        } else {
            return "Braille Numbers: \(uniqueDots.map(String.init).joined(separator: ", "))"
        }
    }
    
    @State private var dotFrames: [String: CGRect] = [:]
    @State private var currentlyTouchingDot: String? = nil
    
    var body: some View {
        ZStack {
            mainPaperColor
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerSection
                
                Spacer()
                    .frame(maxHeight: 20)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 30)
                        .fill(cardPaperColor)
                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                        .shadow(color: Color.black.opacity(0.1), radius: 15, x: 0, y: 8)
                    
                    VStack {
                        HStack {
                            Button {
                                if !UIAccessibility.isVoiceOverRunning {
                                    BrailleSpeechManager.shared.speak(currentLetter.hangul, language: "ko-KR")
                                    BrailleSpeechManager.shared.speakQueued(brailleNumbersText, language: "en-US")
                                }
                                HapticManager.instance.triggerTransitionHaptic()
                            } label: {
                                Image(systemName: "speaker.wave.3.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 44, height: 44)
                                    .foregroundStyle(inkColor)
                                    .padding(12)
                            }
                            .accessibilityLabel("\(currentLetter.hangul)")
                            .padding(.leading, 8)
                            
                            Spacer()
                        }
                        
                        Spacer()
                            .frame(maxHeight: 10)
                        
                        VStack(spacing: 30) {
                            HStack(spacing: 40) {
                                ForEach(0..<currentCells.count, id: \.self) { cellIndex in
                                    singleBrailleGrid(cellIndex: cellIndex)
                                }
                            }
                            .coordinateSpace(name: "brailleContainer")
                            .accessibilityElement(children: .ignore)
                            .accessibilityLabel("Braille Display")
                            .accessibilityHint("Drag your finger to feel the dots")
                            .accessibilityAddTraits(.allowsDirectInteraction)
                            .gesture(
                                DragGesture(minimumDistance: 0, coordinateSpace: .named("brailleContainer"))
                                    .onChanged { value in
                                        detectTouch(at: value.location)
                                    }
                                    .onEnded { _ in
                                        currentlyTouchingDot = nil
                                    }
                            )
                            
                            // Braille Numbers Label
                            Text(brailleNumbersText)
                                .font(.system(size: 25, weight: .semibold, design: .rounded))
                                .foregroundColor(themeInkColor)
                        }
                        .padding(.bottom, 30)
                        .animation(.easeInOut, value: currentCells.count)
                        
                        RoundedRectangle(cornerRadius: 20)
                            .frame(height: 2)
                            .foregroundStyle(inkColor.opacity(0.1))
                        
                        swipeButtonLetter
                        
                        Spacer()
                            .frame(maxHeight: 15)
                    }
                }
                .frame(maxWidth: 360)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 30)
            }

        }
        .fullScreenCover(isPresented: $showTutorial) {
            TutorialIntroView(steps: [TutorialStep.courseIntro] + TutorialStep.portraitTutorial + [TutorialStep.voiceOverTip, TutorialStep.settingsStep]) {
                if selectedBrailleType == BrailleType.yakja.rawValue {
                    hasSeenGrade2Tutorial = true
                } else {
                    hasSeenGrade1Tutorial = true
                }
                showTutorial = false
                if autoAnnounce {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        BrailleSpeechManager.shared.speak(currentLetter.hangul, language: "ko-KR")
                        BrailleSpeechManager.shared.speakQueued(brailleNumbersText, language: "en-US")
                    }
                }
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .toolbarBackground(.hidden, for: .navigationBar)
        .onAppear {
            let saved = UserDefaults.standard.integer(forKey: progressKey)
            currentIndex = letters.indices.contains(saved) ? saved : 0
            if autoAnnounce && hasSeenCurrentGradeTutorial {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    BrailleSpeechManager.shared.speak(currentLetter.hangul, language: "ko-KR")
                    BrailleSpeechManager.shared.speakQueued(brailleNumbersText, language: "en-US")
                }
            }
            hasAnnouncedCurrentLetter = true
        }
        .onDisappear {
            UserDefaults.standard.set(currentIndex, forKey: progressKey)
        }
      
        .onChange(of: currentIndex) { _ in
            if autoAnnounce {
                BrailleSpeechManager.shared.speak(currentLetter.hangul, language: "ko-KR")
                BrailleSpeechManager.shared.speakQueued(brailleNumbersText, language: "en-US")
            }
            hasAnnouncedCurrentLetter = true
        }
      
        .onChange(of: currentCells.count) { _ in
            dotFrames.removeAll()
        }
       
        .navigationDestination(isPresented: $showCompletionScreen) {
            LevelCompletionView(
                levelTitle: levelTitle,
                nextLevel: findNextLevel(after: level),
                showGrade2Advancement: level.storageKey == "sec3_lvl1_completed"
            )
            .navigationBarBackButtonHidden(true)
        }
    }
    
    private func findNextLevel(after currentLevel: BrailleLevel) -> BrailleLevel? {
        let typeRaw = UserDefaults.standard.string(forKey: "selected_braille_type") ?? BrailleType.jeongja.rawValue
        let brailleType = BrailleType(rawValue: typeRaw) ?? .jeongja
        let allLevels = BrailleData.sections(for: brailleType).flatMap { $0.levels }
        if let index = allLevels.firstIndex(where: { $0.id == currentLevel.id }),
           index + 1 < allLevels.count {
            return allLevels[index + 1]
        }
        return nil
    }
    
    
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack {
                Spacer()

                ZStack {
                    RoundedRectangle(cornerRadius: 150)
                        .fill(inkColor)
                        .frame(width: 120, height: 35)

                    Text("\(currentIndex + 1) / \(letters.count)")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundStyle(mainPaperColor)
                        .monospacedDigit()
                }

                Spacer()
            }
            .frame(maxWidth: 340)
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(inkColor.opacity(0.1))
                        .frame(height: 6)
                    
                    RoundedRectangle(cornerRadius: 3)
                        .fill(themeInkColor)
                        .frame(width: geometry.size.width * (CGFloat(currentIndex + 1) / CGFloat(max(letters.count, 1))), height: 6)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentIndex)
                }
                .frame(maxWidth: 340)
                .frame(maxWidth: .infinity)
            }
            .frame(height: 6)
            .frame(maxWidth: 340)
            .frame(maxWidth: .infinity)
        }
    }
    
    private func singleBrailleGrid(cellIndex: Int) -> some View {
        Grid(horizontalSpacing: 50, verticalSpacing: 50) {
            GridRow {
                dotView(cellIndex: cellIndex, number: 1)
                dotView(cellIndex: cellIndex, number: 4)
            }
            GridRow {
                dotView(cellIndex: cellIndex, number: 2)
                dotView(cellIndex: cellIndex, number: 5)
            }
            GridRow {
                dotView(cellIndex: cellIndex, number: 3)
                dotView(cellIndex: cellIndex, number: 6)
            }
        }
    }
    
    private var swipeButtonLetter: some View {
        HStack(spacing: 8) {
            Button {
                if currentIndex > 0 {
                    HapticManager.instance.triggerTransitionHaptic()
                    withAnimation {
                        currentIndex -= 1
                    }
                }
            } label: {
                Image(systemName: "arrowshape.left.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 70)
            }
            .disabled(currentIndex == 0)
            .opacity(currentIndex == 0 ? 0.3 : 1.0)
            .accessibilityLabel("Go back")
            
            Spacer()
            
            VStack {
                Text(currentLetter.hangul)
                Text(currentLetter.englishName)
            }
            .font(.title)
            .fontWeight(.bold)
            .frame(minWidth: 120)
            
            Spacer()
            
            Button {
                HapticManager.instance.triggerTransitionHaptic()
                
                if currentIndex < letters.count - 1 {
                    withAnimation {
                        currentIndex += 1
                    }
                } else {
                    showCompletionScreen = true
                }
            } label: {
                Image(systemName: currentIndex < letters.count - 1 ? "arrowshape.right.fill" : "checkmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 70)
            }
            .accessibilityLabel(currentIndex < letters.count - 1 ? "Go next" : "Complete")
        }
        .frame(width: 340)
        .foregroundStyle(themeInkColor)
    }
    
    private func dotView(cellIndex: Int, number: Int) -> some View {
        let isActive = currentCells[cellIndex].contains(number)
        let dotID = "\(cellIndex)-\(number)"
        let isTouching = (currentlyTouchingDot == dotID)
        
        return NewDotView(
            isActive: isActive,
            isTouching: isTouching,
            paperColor: cardPaperColor,
            dotNumber: number
        )
        .frame(width: 90, height: 90)
        .overlay(
            GeometryReader { geo in
                Color.clear
                    .task {
                     
                        dotFrames[dotID] = geo.frame(in: .named("brailleContainer"))
                    }
                    .onChange(of: geo.frame(in: .named("brailleContainer"))) { newFrame in
                        dotFrames[dotID] = newFrame
                    }
            }
        )
        .scaleEffect(isTouching ? 1.15 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isTouching)
    }
    
    private func detectTouch(at location: CGPoint) {
        var foundDotID: String? = nil
        
        for (id, frame) in dotFrames {
            if frame.insetBy(dx: -15, dy: -15).contains(location) {
                foundDotID = id
                break
            }
        }
        
        if foundDotID != currentlyTouchingDot {
            currentlyTouchingDot = foundDotID
            
            if let id = foundDotID {
               
                let components = id.split(separator: "-").compactMap { Int($0) }
                
                if components.count == 2 {
                    let cellIndex = components[0]
                    let dotNumber = components[1]
                    
                
                    if currentCells.indices.contains(cellIndex) {
                        if currentCells[cellIndex].contains(dotNumber) {
                            HapticManager.instance.triggerActiveHaptic()
                            if activeBrailleSound {
                                SoundManager.instance.playDing()
                            }
                        } else {
                            HapticManager.instance.triggerInactiveHaptic()
                        }
                    } else {
                        HapticManager.instance.triggerInactiveHaptic()
                    }
                }
            }
        }
    }
}

struct NewDotView: View {
    let isActive: Bool
    let isTouching: Bool
    let paperColor: Color
    let dotNumber: Int // 1-6

    private let activeColor = Color(red: 1.0, green: 0.88, blue: 0.0)

    var body: some View {
        ZStack {
            if isActive {
                Circle()
                    .fill(activeColor)

                Text("\(dotNumber)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
            } else {
                Circle()
                    .fill(Color(white: 0.2))

                Text("\(dotNumber)")
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(white: 0.45))
            }
        }
    }
}

