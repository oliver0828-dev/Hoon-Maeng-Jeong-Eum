//
//  BrailleLandscapeView.swift
//  Braille_Read_1
//
//  Created by Oliver Park on 1/8/26.
//

import SwiftUI

struct BrailleLandscapeView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: ContentViewModel

    let level: BrailleLevel
    let levelTitle: String
    let letters: [BrailleLetter]
    @Binding var levelStatus: Bool
    
    @AppStorage("autoAnnounce") private var autoAnnounce: Bool = true
    @AppStorage("activeBrailleSound") private var activeBrailleSound: Bool = true

    @State private var currentIndex: Int = 0
    @State private var showCompletionScreen: Bool = false
    @State private var dotFrames: [String: CGRect] = [:]
    @State private var currentlyTouchingDot: String? = nil
    @State private var currentJamoIndex: Int = 0
    @State private var hasSpokenInitial: Bool = false
    @AppStorage("hasSeenLandscapeTutorial") private var hasSeenLandscapeTutorial: Bool = false
    @State private var showTutorial: Bool = !UserDefaults.standard.bool(forKey: "hasSeenLandscapeTutorial")

    private var progressKey: String { "\(level.storageKey)_progress" }
    private var jamoProgressKey: String { "\(level.storageKey)_jamo_progress" }
    
    private let mainPaperColor = Color.black
    private let cardPaperColor = Color(white: 0.12)
    private let inkColor = Color(red: 1.0, green: 0.88, blue: 0.0)
    private let themeInkColor = Color(red: 1.0, green: 0.88, blue: 0.0)
    
    private var currentLetter: BrailleLetter {
        letters.indices.contains(currentIndex) ? letters[currentIndex] : BrailleLetter(hangul: "?", englishName: "Error", cells: [[]])
    }
    
    private var totalCells: Int {
        letters.reduce(0) { $0 + $1.cells.count }
    }
    
    private var totalProgress: Int {
        var count = 0
        for i in 0..<currentIndex {
            count += letters[i].cells.count
        }
        count += currentJamoIndex + 1
        return count
    }
    
    private var brailleNumbersTextLandscape: String {
        if currentLetter.cells.indices.contains(currentJamoIndex) {
            let jamoDots = Array(currentLetter.cells[currentJamoIndex]).sorted()
            
            if jamoDots.isEmpty {
                return "None"
            } else {
                return jamoDots.map(String.init).joined(separator: ", ")
            }
        }
        return "None"
    }
    
    private var currentFramesReady: Bool {
        (1...6).allSatisfy { dotFrames["\(currentJamoIndex)-\($0)"] != nil }
    }
    
    var body: some View {
        GeometryReader { screen in
            let screenH = screen.size.height
            let isCompact = screenH < 400
            let leftWidth: CGFloat = isCompact ? 160 : 240
            
            let gridHeight = screenH * 0.72
            let dotSize: CGFloat = min(gridHeight / 3.8, 90)
            let dotSpacing: CGFloat = dotSize * 0.55
            let arrowSize: CGFloat = 50
            
            ZStack {
                mainPaperColor.ignoresSafeArea()
                
                HStack(spacing: 0) {
                    // LEFT SIDE: Compact info panel
                    VStack(spacing: 0) {
                        // Close button
                        HStack {
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundStyle(inkColor.opacity(0.3))
                            }
                            .accessibilityLabel("Close")
                            Spacer()
                        }
                        .padding(.leading, 12)
                        .padding(.top)
                        
                        Spacer(minLength: 0)
                        
                        // All info grouped tightly
                        VStack(spacing: isCompact ? 4 : 8) {
                            Button {
                                if !UIAccessibility.isVoiceOverRunning {
                                    speakCurrentLetter()
                                }
                                HapticManager.instance.triggerTransitionHaptic()
                            } label: {
                                Image(systemName: "speaker.wave.3.fill")
                                    .font(isCompact ? .body : .title3)
                                    .foregroundStyle(inkColor)
                                    .padding(8)
                                    .background(Circle().fill(inkColor.opacity(0.05)))
                            }
                            .accessibilityLabel("Play pronunciation for \(currentLetter.hangul)")
                            
                            Text(currentLetter.hangul)
                                .font(.system(size: isCompact ? 44 : 52, weight: .bold, design: .rounded))
                                .foregroundStyle(themeInkColor)
                                .accessibilityLabel(currentLetter.hangul)
                            
                            if currentLetter.cells.count > 1 {
                                Text("Page \(currentJamoIndex + 1) of \(currentLetter.cells.count)")
                                    .font(.system(size: 15))
                                    .foregroundStyle(inkColor.opacity(0.6))
                            }
                            
                            Text(currentLetter.englishName)
                                .font(.system(size: isCompact ? 15 : 17, weight: .semibold))
                                .foregroundStyle(inkColor.opacity(0.7))
                            
                            VStack(alignment: .center, spacing: 2) {
                                Text("Braille Numbers:\n\(brailleNumbersTextLandscape)")
                                    .font(.system(size: isCompact ? 20 : 24, weight: .bold, design: .rounded))
                                    .foregroundColor(themeInkColor)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.vertical, 6)
                        }
                        .padding(.horizontal, 12)
                        
                        Spacer(minLength: 0)
                        
                        // Progress Bar
                        VStack(spacing: 3) {
                            Text("\(totalProgress) / \(totalCells)")
                                .font(.system(size: isCompact ? 16 : 18, weight: .bold, design: .rounded))
                                .foregroundStyle(inkColor)
                                .monospacedDigit()
                            
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(inkColor.opacity(0.1))
                                        .frame(height: 6)
                                    
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(themeInkColor)
                                        .frame(width: geo.size.width * CGFloat(totalProgress) / CGFloat(max(totalCells, 1)), height: 6)
                                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentIndex)
                                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentJamoIndex)
                                }
                            }
                            .frame(height: 6)
                        }
                        .padding(.horizontal, 12)
                        .padding(.bottom, 8)
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Progress: \(totalProgress) of \(totalCells)")
                    }
                    .frame(width: leftWidth)
                    
                    HStack(spacing: 0) {
                        Button {
                            if currentJamoIndex > 0 {
                                withAnimation { currentJamoIndex -= 1 }
                            } else if currentIndex > 0 {
                                withAnimation {
                                    currentIndex -= 1
                                    currentJamoIndex = currentLetter.cells.count - 1
                                }
                            }
                        } label: {
                            Image(systemName: "arrowshape.left.fill")
                                .resizable().scaledToFit().frame(width: arrowSize, height: arrowSize)
                                .foregroundStyle(themeInkColor.opacity((currentIndex == 0 && currentJamoIndex == 0) ? 0.2 : 1.0))
                        }
                        .disabled(currentIndex == 0 && currentJamoIndex == 0)
                        .accessibilityLabel("Go back")
                        .padding(.leading, 8)
                        
                        Spacer()
                        
                        singleBrailleGrid(cellIndex: currentJamoIndex, dotSize: dotSize, dotSpacing: dotSpacing)
                            .id("\(currentIndex)-\(currentJamoIndex)")
                            .coordinateSpace(name: "brailleLandscapeContainer")
                            .accessibilityElement(children: .ignore)
                            .accessibilityLabel("Braille Display")
                            .accessibilityHint("Drag your finger to feel the dots")
                            .accessibilityAddTraits(.allowsDirectInteraction)
                            .simultaneousGesture(
                                DragGesture(minimumDistance: 0, coordinateSpace: .named("brailleLandscapeContainer"))
                                    .onChanged { value in
                                        if currentFramesReady {
                                            detectTouch(at: value.location)
                                        }
                                    }
                                    .onEnded { _ in
                                        currentlyTouchingDot = nil
                                    }
                            )
                        
                        Spacer()
                        
                        Button {
                            if currentJamoIndex < currentLetter.cells.count - 1 {
                                withAnimation { currentJamoIndex += 1 }
                            } else if currentIndex < letters.count - 1 {
                                withAnimation {
                                    currentIndex += 1
                                    currentJamoIndex = 0
                                }
                            } else {
                                showCompletionScreen = true
                            }
                        } label: {
                            let isLastJamoOfLastWord = (currentIndex == letters.count - 1) && (currentJamoIndex == currentLetter.cells.count - 1)
                            Image(systemName: isLastJamoOfLastWord ? "checkmark.circle.fill" : "arrowshape.right.fill")
                                .resizable().scaledToFit().frame(width: arrowSize, height: arrowSize)
                                .foregroundStyle(themeInkColor)
                        }
                        .accessibilityLabel(
                            (currentIndex == letters.count - 1 && currentJamoIndex == currentLetter.cells.count - 1) ? "Complete" : "Go next"
                        )
                        .padding(.trailing, 8)
                    }
                    .frame(maxWidth: .infinity)
                }

            }
        }
        .fullScreenCover(isPresented: $showTutorial) {
            TutorialIntroView(steps: [TutorialStep.courseIntro] + TutorialStep.landscapeTutorial) {
                hasSeenLandscapeTutorial = true
                showTutorial = false
                if autoAnnounce {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        speakCurrentLetter()
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            setOrientation(.landscapeRight)
            let savedIndex = UserDefaults.standard.integer(forKey: progressKey)
            let savedJamo = UserDefaults.standard.integer(forKey: jamoProgressKey)
            let newIndex = letters.indices.contains(savedIndex) ? savedIndex : 0
            let jamoCount = letters.indices.contains(newIndex) ? letters[newIndex].cells.count : 1
            let newJamo = savedJamo < jamoCount ? savedJamo : 0

            let indexWillChange = newIndex != currentIndex
            currentIndex = newIndex
            currentJamoIndex = newJamo

            if !hasSpokenInitial && autoAnnounce && hasSeenLandscapeTutorial {
                hasSpokenInitial = true
                // If currentIndex changed, onChange(of: currentIndex) will already call speakCurrentLetter.
                // Only schedule it here when the index stayed the same and onChange won't fire.
                if !indexWillChange {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        speakCurrentLetter()
                    }
                }
            } else {
                hasSpokenInitial = true
            }
        }
        .onDisappear {
            setOrientation(.portrait)
            UserDefaults.standard.set(currentIndex, forKey: progressKey)
            UserDefaults.standard.set(currentJamoIndex, forKey: jamoProgressKey)
        }
        .onChange(of: currentIndex) { _ in
            if currentJamoIndex >= currentLetter.cells.count {
                currentJamoIndex = 0
            }
            dotFrames.removeAll()
            currentlyTouchingDot = nil
            if autoAnnounce {
                speakCurrentLetter()
            }
        }
        .onChange(of: currentJamoIndex) { _ in
            dotFrames.removeAll()
            currentlyTouchingDot = nil
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
    
    private func speakCurrentLetter() {
        let cellCount = currentLetter.cells.count

        BrailleSpeechManager.shared.speak(currentLetter.hangul, language: "ko-KR")

        if cellCount > 1 {
            BrailleSpeechManager.shared.speakQueued("Page \(currentJamoIndex + 1) of \(cellCount)", language: "en-US")
        }

        let dots = brailleNumbersTextLandscape
        let dotsAnnouncement = dots == "None" ? "No active dots" : "Braille Numbers: \(dots)"
        BrailleSpeechManager.shared.speakQueued(dotsAnnouncement, language: "en-US")
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
    
    private func singleBrailleGrid(cellIndex: Int, dotSize: CGFloat, dotSpacing: CGFloat) -> some View {
        Grid(horizontalSpacing: dotSpacing, verticalSpacing: dotSpacing) {
            ForEach(0..<3) { row in
                GridRow {
                    dotView(cellIndex: cellIndex, number: row + 1, dotSize: dotSize)
                    dotView(cellIndex: cellIndex, number: row + 4, dotSize: dotSize)
                }
            }
        }
    }

    private func dotView(cellIndex: Int, number: Int, dotSize: CGFloat) -> some View {
        let isActive = currentLetter.cells[cellIndex].contains(number)
        let dotID = "\(cellIndex)-\(number)"
        let isTouching = (currentlyTouchingDot == dotID)
        
        return NewDotView(
            isActive: isActive,
            isTouching: isTouching,
            paperColor: mainPaperColor,
            dotNumber: number
        )
        .frame(width: dotSize, height: dotSize)
        .background(
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        dotFrames[dotID] = geo.frame(in: .named("brailleLandscapeContainer"))
                    }
                    .preference(
                        key: DotFramePreferenceKey.self,
                        value: [dotID: geo.frame(in: .named("brailleLandscapeContainer"))]
                    )
            }
        )
        .scaleEffect(isTouching ? 1.15 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isTouching)
        .onPreferenceChange(DotFramePreferenceKey.self) { preferences in
            for (key, frame) in preferences {
                dotFrames[key] = frame
            }
        }
    }
    
    private func detectTouch(at location: CGPoint) {
        var foundDotID: String? = nil
        let touchRadius: CGFloat = 15.0
        
        for dotNum in 1...6 {
            let id = "\(currentJamoIndex)-\(dotNum)"
            guard let frame = dotFrames[id] else { continue }
            if frame.insetBy(dx: -touchRadius, dy: -touchRadius).contains(location) {
                foundDotID = id
                break
            }
        }
        
        if foundDotID != currentlyTouchingDot {
            currentlyTouchingDot = foundDotID
            if let id = foundDotID {
                let comps = id.split(separator: "-").compactMap { Int($0) }
                if comps.count == 2 {
                    let cellIdx = comps[0]
                    let dotNum = comps[1]
                    if currentLetter.cells.indices.contains(cellIdx) {
                        if currentLetter.cells[cellIdx].contains(dotNum) {
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

    private func setOrientation(_ orientation: UIInterfaceOrientationMask) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: orientation))
        }
    }
}

struct DotFramePreferenceKey: PreferenceKey {
    static let defaultValue: [String: CGRect] = [:]
    
    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue()) { $1 }
    }
}
