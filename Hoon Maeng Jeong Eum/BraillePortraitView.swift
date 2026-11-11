//
//  BraillePortraitView.swift
//  Braille_Read_1
//
//  Created by Oliver Park on 1/3/26.
//

import SwiftUI
import AVFoundation
import AVKit
import UIKit

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
            return BrailleLetter(hangul: "?", englishName: "오류", activeDots: [])
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
            return "활성화된 점 없음"
        } else if uniqueDots.count == 1 {
            return "점자 번호: \(uniqueDots.first!)"
        } else {
            return "점자 번호: \(uniqueDots.map(String.init).joined(separator: ", "))"
        }
    }

    private var fullAnnouncementText: String {
        "\(currentLetter.englishName). \(brailleNumbersText). 전체 \(letters.count)개 중 \(currentIndex + 1)번째 글자"
    }
    
    @State private var dotFrames: [String: CGRect] = [:]
    @State private var currentlyTouchingDot: String? = nil
    
    var body: some View {
        ZStack {
            mainPaperColor
                .ignoresSafeArea()
            
            VStack(spacing: 14) {
                headerInfoCard
                
                ZStack {
                    RoundedRectangle(cornerRadius: 30)
                        .fill(cardPaperColor)
                        .shadow(color: Color.black.opacity(0.1), radius: 15, x: 0, y: 8)
                    
                    VStack(spacing: 18) {
                        Spacer(minLength: 4)
                        
                        GeometryReader { geo in
                            let availableW = geo.size.width
                            let availableH = geo.size.height
                            let cellCount = max(currentCells.count, 1)
                            let maxDotH = (availableH - 96) / 3.0
                            let maxDotW = (availableW - CGFloat(cellCount - 1) * 32 - 56) / CGFloat(cellCount * 2)
                            let dotSize = min(max(min(maxDotH, maxDotW), 76), 112)
                            let hSpacing = min(max(dotSize * 0.48, 36), 56)
                            let vSpacing = min(max((availableH - dotSize * 3) / 2.6, 28), 48)
                            
                            HStack(spacing: 32) {
                                ForEach(0..<currentCells.count, id: \.self) { cellIndex in
                                    singleBrailleGrid(
                                        cellIndex: cellIndex,
                                        dotSize: dotSize,
                                        hSpacing: hSpacing,
                                        vSpacing: vSpacing
                                    )
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .coordinateSpace(name: "brailleContainer")
                        .accessibilityElement(children: .ignore)
                        .koreanAccessibilityLabel("점자 촉각 영역, \(currentLetter.englishName), \(brailleNumbersText)")
                        .koreanAccessibilityHint("한 손가락으로 문질러 1번부터 6번 점의 위치와 돌출 여부를 느끼고 들어보세요")
                        .accessibilityAddTraits(.allowsDirectInteraction)
                        .gesture(
                            DragGesture(minimumDistance: 0, coordinateSpace: .named("brailleContainer"))
                                .onChanged { value in
                                    detectTouch(at: value.location)
                                }
                                .onEnded { _ in
                                    if currentlyTouchingDot != nil {
                                        currentlyTouchingDot = nil
                                    }
                                }
                        )
                        
                        swipeGuideFooter
                    }
                    .padding(.vertical, 14)
                }
                .frame(maxWidth: 370)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .accessibilityScrollAction { edge in
            switch edge {
            case .trailing, .bottom:
                goToNextLetter()
            case .leading, .top:
                goToPreviousLetter()
            @unknown default:
                break
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
                announceCurrentLetter(delay: 0.35)
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .toolbarBackground(.hidden, for: .navigationBar)
        .onAppear {
            let saved = UserDefaults.standard.integer(forKey: progressKey)
            currentIndex = letters.indices.contains(saved) ? saved : 0
            if hasSeenCurrentGradeTutorial {
                announceCurrentLetter(delay: 0.45)
            }
        }
        .onDisappear {
            BrailleSpeechManager.shared.stop()
            UserDefaults.standard.set(currentIndex, forKey: progressKey)
        }
        .onChange(of: currentIndex) { _ in
            currentlyTouchingDot = nil
            announceCurrentLetter(delay: 0.1)
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

    private func announceCurrentLetter(delay: TimeInterval = 0, force: Bool = false) {
        guard autoAnnounce || force else { return }
        BrailleSpeechManager.shared.speak(fullAnnouncementText, language: "ko-KR", delay: delay)
    }

    private func goToNextLetter() {
        HapticManager.instance.triggerTransitionHaptic()
        if currentIndex < letters.count - 1 {
            withAnimation(.easeInOut(duration: 0.25)) {
                currentIndex += 1
            }
        } else {
            HapticManager.instance.triggerCompletionHaptic()
            showCompletionScreen = true
        }
    }

    private func goToPreviousLetter() {
        if currentIndex > 0 {
            HapticManager.instance.triggerTransitionHaptic()
            withAnimation(.easeInOut(duration: 0.25)) {
                currentIndex -= 1
            }
        } else {
            HapticManager.instance.triggerBoundaryHaptic()
            BrailleSpeechManager.shared.speak("첫 번째 글자입니다. \(fullAnnouncementText)", language: "ko-KR")
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
    
    private var headerInfoCard: some View {
        VStack(spacing: 10) {
            HStack(alignment: .center, spacing: 14) {
                koreanText(currentLetter.hangul)
                    .font(.system(size: 44, weight: .black, design: .rounded))
                    .foregroundStyle(themeInkColor)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        koreanText(currentLetter.englishName)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(inkColor)

                        Spacer()

                        koreanText("\(currentIndex + 1) / \(letters.count)")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(mainPaperColor)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(inkColor))
                            .monospacedDigit()
                    }

                    koreanText(brailleNumbersText)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundStyle(themeInkColor.opacity(0.9))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(inkColor.opacity(0.15))
                        .frame(height: 6)
                    
                    RoundedRectangle(cornerRadius: 3)
                        .fill(themeInkColor)
                        .frame(width: geometry.size.width * (CGFloat(currentIndex + 1) / CGFloat(max(letters.count, 1))), height: 6)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentIndex)
                }
            }
            .frame(height: 6)
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(cardPaperColor)
        )
        .frame(maxWidth: 370)
        .padding(.horizontal, 16)
        .padding(.top, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            HapticManager.instance.triggerTransitionHaptic()
            announceCurrentLetter(force: true)
        }
        .gesture(
            DragGesture(minimumDistance: 30)
                .onEnded { value in
                    handleHorizontalSwipe(value)
                }
        )
        .accessibilityElement(children: .ignore)
        .koreanAccessibilityLabel("\(currentLetter.englishName), \(brailleNumbersText), 전체 \(letters.count)개 중 \(currentIndex + 1)번째 글자")
        .koreanAccessibilityHint("두 번 탭하면 음성을 다시 듣고, 위아래로 쓸어내리면 이전 또는 다음 글자로 이동합니다")
        .accessibilityAddTraits(.isButton)
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment:
                goToNextLetter()
            case .decrement:
                goToPreviousLetter()
            @unknown default:
                break
            }
        }
        .accessibilityAction(named: koreanText("다음 점자")) {
            goToNextLetter()
        }
        .accessibilityAction(named: koreanText("이전 점자")) {
            goToPreviousLetter()
        }
        .accessibilityAction(named: koreanText("다시 듣기")) {
            announceCurrentLetter(force: true)
        }
    }
    
    private func singleBrailleGrid(cellIndex: Int, dotSize: CGFloat, hSpacing: CGFloat, vSpacing: CGFloat) -> some View {
        Grid(horizontalSpacing: hSpacing, verticalSpacing: vSpacing) {
            GridRow {
                dotView(cellIndex: cellIndex, number: 1, dotSize: dotSize)
                dotView(cellIndex: cellIndex, number: 4, dotSize: dotSize)
            }
            GridRow {
                dotView(cellIndex: cellIndex, number: 2, dotSize: dotSize)
                dotView(cellIndex: cellIndex, number: 5, dotSize: dotSize)
            }
            GridRow {
                dotView(cellIndex: cellIndex, number: 3, dotSize: dotSize)
                dotView(cellIndex: cellIndex, number: 6, dotSize: dotSize)
            }
        }
    }
    
    private var swipeGuideFooter: some View {
        VStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 20)
                .frame(height: 2)
                .foregroundStyle(inkColor.opacity(0.12))
                .padding(.horizontal, 20)

            HStack(spacing: 10) {
                Image(systemName: "hand.draw.fill")
                    .font(.system(size: 18, weight: .semibold))
                koreanText(currentIndex < letters.count - 1 ? "좌우로 스와이프하여 이동 · 탭하여 다시 듣기" : "왼쪽으로 스와이프하여 완료 · 탭하여 다시 듣기")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .multilineTextAlignment(.center)
            }
            .foregroundStyle(inkColor.opacity(0.8))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .contentShape(Rectangle())
            .onTapGesture {
                HapticManager.instance.triggerTransitionHaptic()
                announceCurrentLetter(force: true)
            }
            .gesture(
                DragGesture(minimumDistance: 30)
                    .onEnded { value in
                        handleHorizontalSwipe(value)
                    }
            )
            .accessibilityHidden(true)
        }
    }

    private func handleHorizontalSwipe(_ value: DragGesture.Value) {
        let horizontal = value.translation.width
        let vertical = value.translation.height
        guard abs(horizontal) > abs(vertical), abs(horizontal) > 40 else { return }
        if horizontal < 0 {
            goToNextLetter()
        } else {
            goToPreviousLetter()
        }
    }
    
    private func dotView(cellIndex: Int, number: Int, dotSize: CGFloat) -> some View {
        let isActive = currentCells[cellIndex].contains(number)
        let dotID = "\(cellIndex)-\(number)"
        let isTouching = (currentlyTouchingDot == dotID)
        
        return NewDotView(
            isActive: isActive,
            isTouching: isTouching,
            paperColor: cardPaperColor,
            dotNumber: number
        )
        .frame(width: dotSize, height: dotSize)
        .overlay(
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        dotFrames[dotID] = geo.frame(in: .named("brailleContainer"))
                    }
                    .onChange(of: geo.frame(in: .named("brailleContainer"))) { newFrame in
                        dotFrames[dotID] = newFrame
                    }
            }
        )
        .scaleEffect(isTouching ? 1.15 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.65), value: isTouching)
    }
    
    private func detectTouch(at location: CGPoint) {
        var foundDotID: String? = nil
        
        for (id, frame) in dotFrames {
            if frame.insetBy(dx: -18, dy: -18).contains(location) {
                foundDotID = id
                break
            }
        }
        
        if foundDotID != currentlyTouchingDot {
            let previousDot = currentlyTouchingDot
            currentlyTouchingDot = foundDotID
            
            if let id = foundDotID {
                let components = id.split(separator: "-").compactMap { Int($0) }
                
                if components.count == 2 {
                    let cellIndex = components[0]
                    let dotNumber = components[1]
                    
                    if currentCells.indices.contains(cellIndex) {
                        let isActive = currentCells[cellIndex].contains(dotNumber)
                        if isActive {
                            HapticManager.instance.triggerActiveHaptic()
                        } else {
                            HapticManager.instance.triggerInactiveHaptic()
                        }
                        if activeBrailleSound {
                            BrailleSpeechManager.shared.speakDot(
                                dotNumber: dotNumber,
                                isActive: isActive,
                                cellIndex: cellIndex,
                                totalCells: currentCells.count
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
                    .shadow(color: activeColor.opacity(isTouching ? 0.6 : 0.25), radius: isTouching ? 12 : 4)

                Circle()
                    .strokeBorder(isTouching ? Color.white : Color.black.opacity(0.25), lineWidth: isTouching ? 5 : 2)

                koreanText("\(dotNumber)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
            } else {
                Circle()
                    .fill(Color(white: 0.2))

                Circle()
                    .strokeBorder(
                        isTouching ? activeColor.opacity(0.85) : Color(white: 0.35),
                        style: StrokeStyle(lineWidth: isTouching ? 4 : 2, dash: isTouching ? [] : [6, 4])
                    )

                koreanText("\(dotNumber)")
                    .font(.system(size: 30, weight: .semibold, design: .rounded))
                    .foregroundColor(isTouching ? activeColor : Color(white: 0.5))
            }
        }
    }
}
