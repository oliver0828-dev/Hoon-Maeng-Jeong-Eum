//
//  BrailleLandscapeView.swift
//  Braille_Read_1
//
//  Created by Oliver Park on 1/8/26.
//

import SwiftUI
import UIKit

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
        letters.indices.contains(currentIndex) ? letters[currentIndex] : BrailleLetter(hangul: "?", englishName: "오류", cells: [[]])
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
                return "없음"
            } else {
                return jamoDots.map(String.init).joined(separator: ", ")
            }
        }
        return "없음"
    }

    private var isLastJamoOfLastWord: Bool {
        (currentIndex == letters.count - 1) && (currentJamoIndex == currentLetter.cells.count - 1)
    }

    private var fullAnnouncementText: String {
        let cellCount = currentLetter.cells.count
        let cellText = cellCount > 1 ? ", \(cellCount)칸 중 \(currentJamoIndex + 1)번째 칸" : ""
        let dots = brailleNumbersTextLandscape
        let dotsAnnouncement = dots == "없음" ? "활성화된 점 없음" : "점자 번호: \(dots)"
        return "\(currentLetter.englishName)\(cellText). \(dotsAnnouncement)"
    }
    
    private var currentFramesReady: Bool {
        (1...6).allSatisfy { dotFrames["\(currentJamoIndex)-\($0)"] != nil }
    }
    
    var body: some View {
        GeometryReader { screen in
            let screenH = screen.size.height
            let isCompact = screenH < 400
            let leftWidth: CGFloat = isCompact ? 200 : 250
            
            let gridHeight = screenH * 0.78
            let dotSize: CGFloat = min(max(gridHeight / 3.4, 72), 104)
            let dotSpacing: CGFloat = dotSize * 0.48
            
            ZStack {
                mainPaperColor.ignoresSafeArea()
                
                HStack(spacing: 12) {
                    // LEFT SIDE: Tap-to-listen & Swipeable info panel
                    VStack(spacing: 0) {
                        HStack {
                            Button {
                                BrailleSpeechManager.shared.stop()
                                dismiss()
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 16, weight: .bold))
                                    koreanText("나가기")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                }
                                .foregroundStyle(inkColor.opacity(0.85))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Capsule().fill(cardPaperColor))
                            }
                            .koreanAccessibilityLabel("학습 나가기")
                            .koreanAccessibilityHint("현재 단계를 닫고 목록으로 돌아갑니다")
                            Spacer()
                        }
                        .padding(.leading, 12)
                        .padding(.top, 10)
                        
                        Spacer(minLength: 4)
                        
                        VStack(spacing: isCompact ? 6 : 10) {
                            koreanText(currentLetter.hangul)
                                .font(.system(size: isCompact ? 46 : 56, weight: .black, design: .rounded))
                                .foregroundStyle(themeInkColor)
                                .minimumScaleFactor(0.6)
                                .lineLimit(1)
                            
                            if currentLetter.cells.count > 1 {
                                koreanText("\(currentLetter.cells.count)칸 중 \(currentJamoIndex + 1)칸")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundStyle(mainPaperColor)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 3)
                                    .background(Capsule().fill(themeInkColor))
                            }
                            
                            koreanText(currentLetter.englishName)
                                .font(.system(size: isCompact ? 16 : 18, weight: .semibold, design: .rounded))
                                .foregroundStyle(inkColor.opacity(0.85))
                            
                            VStack(alignment: .center, spacing: 2) {
                                koreanText("점자 번호: \(brailleNumbersTextLandscape)")
                                    .font(.system(size: isCompact ? 19 : 22, weight: .bold, design: .rounded))
                                    .foregroundColor(themeInkColor)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.top, 2)

                            koreanText("탭하여 다시 듣기")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(inkColor.opacity(0.6))
                                .padding(.top, 2)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 22)
                                .fill(cardPaperColor)
                        )
                        .padding(.horizontal, 10)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            HapticManager.instance.triggerTransitionHaptic()
                            speakCurrentLetter(force: true)
                        }
                        .gesture(
                            DragGesture(minimumDistance: 30)
                                .onEnded { value in
                                    handleHorizontalSwipe(value)
                                }
                        )
                        .accessibilityElement(children: .ignore)
                        .koreanAccessibilityLabel("\(fullAnnouncementText), 전체 \(totalCells)칸 중 \(totalProgress)번째 칸")
                        .koreanAccessibilityHint("두 번 탭하면 음성을 다시 듣고, 위아래로 쓸어내리면 이전 또는 다음 점자 칸으로 이동합니다")
                        .accessibilityAddTraits(.isButton)
                        .accessibilityAdjustableAction { direction in
                            switch direction {
                            case .increment:
                                goToNextStep()
                            case .decrement:
                                goToPreviousStep()
                            @unknown default:
                                break
                            }
                        }
                        .accessibilityAction(named: koreanText("다음 칸 또는 글자")) {
                            goToNextStep()
                        }
                        .accessibilityAction(named: koreanText("이전 칸 또는 글자")) {
                            goToPreviousStep()
                        }
                        .accessibilityAction(named: koreanText("다시 듣기")) {
                            speakCurrentLetter(force: true)
                        }
                        
                        Spacer(minLength: 4)
                        
                        // Progress Bar
                        VStack(spacing: 4) {
                            koreanText("\(totalProgress) / \(totalCells)")
                                .font(.system(size: isCompact ? 15 : 17, weight: .bold, design: .rounded))
                                .foregroundStyle(inkColor)
                                .monospacedDigit()
                            
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(inkColor.opacity(0.15))
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
                        .padding(.horizontal, 14)
                        .padding(.bottom, 10)
                        .accessibilityHidden(true)
                    }
                    .frame(width: leftWidth)
                    
                    // RIGHT SIDE: Large Braille Tactile Area + Swipe Bar
                    VStack(spacing: 8) {
                        Spacer(minLength: 4)

                        singleBrailleGrid(cellIndex: currentJamoIndex, dotSize: dotSize, dotSpacing: dotSpacing)
                            .id("\(currentIndex)-\(currentJamoIndex)")
                            .padding(.horizontal, 28)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 28)
                                    .fill(cardPaperColor)
                            )
                            .coordinateSpace(name: "brailleLandscapeContainer")
                            .accessibilityElement(children: .ignore)
                            .koreanAccessibilityLabel("점자 촉각 영역, \(fullAnnouncementText)")
                            .koreanAccessibilityHint("한 손가락으로 문질러 1번부터 6번 점의 위치와 돌출 여부를 느끼고 들어보세요")
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

                        HStack(spacing: 8) {
                            Image(systemName: "hand.draw.fill")
                                .font(.system(size: 15, weight: .semibold))
                            koreanText(isLastJamoOfLastWord ? "왼쪽으로 스와이프하여 완료" : "좌우로 스와이프하여 다음·이전 칸 이동")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                        }
                        .foregroundStyle(inkColor.opacity(0.8))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            HapticManager.instance.triggerTransitionHaptic()
                            speakCurrentLetter(force: true)
                        }
                        .gesture(
                            DragGesture(minimumDistance: 30)
                                .onEnded { value in
                                    handleHorizontalSwipe(value)
                                }
                        )
                        .accessibilityHidden(true)

                        Spacer(minLength: 4)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .accessibilityScrollAction { edge in
            switch edge {
            case .trailing, .bottom:
                goToNextStep()
            case .leading, .top:
                goToPreviousStep()
            @unknown default:
                break
            }
        }
        .fullScreenCover(isPresented: $showTutorial) {
            TutorialIntroView(steps: [TutorialStep.courseIntro] + TutorialStep.landscapeTutorial) {
                hasSeenLandscapeTutorial = true
                showTutorial = false
                speakCurrentLetter(delay: 0.35)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            OrientationManager.rotateToLandscape()
            let savedIndex = UserDefaults.standard.integer(forKey: progressKey)
            let savedJamo = UserDefaults.standard.integer(forKey: jamoProgressKey)
            let newIndex = letters.indices.contains(savedIndex) ? savedIndex : 0
            let jamoCount = letters.indices.contains(newIndex) ? letters[newIndex].cells.count : 1
            let newJamo = savedJamo < jamoCount ? savedJamo : 0

            let stateWillChange = (newIndex != currentIndex) || (newJamo != currentJamoIndex)
            currentIndex = newIndex
            currentJamoIndex = newJamo

            if !hasSpokenInitial && hasSeenLandscapeTutorial {
                hasSpokenInitial = true
                if !stateWillChange {
                    speakCurrentLetter(delay: 0.6)
                }
            } else {
                hasSpokenInitial = true
            }
        }
        .onDisappear {
            BrailleSpeechManager.shared.stop()
            OrientationManager.rotateToPortrait()
            UserDefaults.standard.set(currentIndex, forKey: progressKey)
            UserDefaults.standard.set(currentJamoIndex, forKey: jamoProgressKey)
        }
        .onChange(of: currentIndex) { _ in
            if currentJamoIndex >= currentLetter.cells.count {
                currentJamoIndex = 0
            }
            dotFrames.removeAll()
            currentlyTouchingDot = nil
            speakCurrentLetter(delay: 0.1)
        }
        .onChange(of: currentJamoIndex) { _ in
            dotFrames.removeAll()
            currentlyTouchingDot = nil
            speakCurrentLetter(delay: 0.1)
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

    private func goToNextStep() {
        HapticManager.instance.triggerTransitionHaptic()
        if currentJamoIndex < currentLetter.cells.count - 1 {
            withAnimation(.easeInOut(duration: 0.25)) {
                currentJamoIndex += 1
            }
        } else if currentIndex < letters.count - 1 {
            withAnimation(.easeInOut(duration: 0.25)) {
                currentIndex += 1
                currentJamoIndex = 0
            }
        } else {
            HapticManager.instance.triggerCompletionHaptic()
            showCompletionScreen = true
        }
    }

    private func goToPreviousStep() {
        if currentJamoIndex > 0 {
            HapticManager.instance.triggerTransitionHaptic()
            withAnimation(.easeInOut(duration: 0.25)) {
                currentJamoIndex -= 1
            }
        } else if currentIndex > 0 {
            HapticManager.instance.triggerTransitionHaptic()
            let prevIndex = currentIndex - 1
            let prevCellCount = letters.indices.contains(prevIndex) ? max(letters[prevIndex].cells.count - 1, 0) : 0
            withAnimation(.easeInOut(duration: 0.25)) {
                currentIndex = prevIndex
                currentJamoIndex = prevCellCount
            }
        } else {
            HapticManager.instance.triggerBoundaryHaptic()
            BrailleSpeechManager.shared.speak("첫 번째 칸입니다. \(fullAnnouncementText)", language: "ko-KR")
        }
    }

    private func handleHorizontalSwipe(_ value: DragGesture.Value) {
        let horizontal = value.translation.width
        let vertical = value.translation.height
        guard abs(horizontal) > abs(vertical), abs(horizontal) > 40 else { return }
        if horizontal < 0 {
            goToNextStep()
        } else {
            goToPreviousStep()
        }
    }
    
    private func speakCurrentLetter(delay: TimeInterval = 0, force: Bool = false) {
        guard autoAnnounce || force else { return }
        BrailleSpeechManager.shared.speak(fullAnnouncementText, language: "ko-KR", delay: delay)
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
        .animation(.spring(response: 0.25, dampingFraction: 0.65), value: isTouching)
        .onPreferenceChange(DotFramePreferenceKey.self) { preferences in
            for (key, frame) in preferences {
                dotFrames[key] = frame
            }
        }
    }
    
    private func detectTouch(at location: CGPoint) {
        var foundDotID: String? = nil
        let touchRadius: CGFloat = 18.0
        
        for dotNum in 1...6 {
            let id = "\(currentJamoIndex)-\(dotNum)"
            guard let frame = dotFrames[id] else { continue }
            if frame.insetBy(dx: -touchRadius, dy: -touchRadius).contains(location) {
                foundDotID = id
                break
            }
        }
        
        if foundDotID != currentlyTouchingDot {
            let previousDot = currentlyTouchingDot
            currentlyTouchingDot = foundDotID
            if let id = foundDotID {
                let comps = id.split(separator: "-").compactMap { Int($0) }
                if comps.count == 2 {
                    let cellIdx = comps[0]
                    let dotNum = comps[1]
                    if currentLetter.cells.indices.contains(cellIdx) {
                        let isActive = currentLetter.cells[cellIdx].contains(dotNum)
                        if isActive {
                            HapticManager.instance.triggerActiveHaptic()
                        } else {
                            HapticManager.instance.triggerInactiveHaptic()
                        }
                        if activeBrailleSound {
                            BrailleSpeechManager.shared.speakDot(
                                dotNumber: dotNum,
                                isActive: isActive,
                                cellIndex: nil,
                                totalCells: 1
                            )
                        }
                    }
                }
            } else if previousDot != nil {
                HapticManager.instance.triggerBoundaryHaptic()
            }
        }
    }
}

struct DotFramePreferenceKey: PreferenceKey {
    static let defaultValue: [String: CGRect] = [:]
    
    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue()) { $1 }
    }
}
