//
//  TutorialOverlayView.swift
//  훈맹정음
//

import SwiftUI

struct TutorialStep {
    let systemImage: String
    let title: String
    let description: String
    var isSettingsStep: Bool = false
}

extension TutorialStep {
    static var courseIntro: TutorialStep {
        let typeRaw = UserDefaults.standard.string(forKey: "selected_braille_type") ?? BrailleType.jeongja.rawValue
        let brailleType = BrailleType(rawValue: typeRaw) ?? .jeongja
        switch brailleType {
        case .jeongja:
            return TutorialStep(
                systemImage: "text.book.closed.fill",
                title: "1급 점자에 오신 것을 환영합니다",
                description: "한글 점자를 기초부터 배워 보세요. 자음과 모음 하나하나부터 시작해 음절과 단어까지, 점 하나씩 차근차근 익힐 수 있습니다."
            )
        case .yakja:
            return TutorialStep(
                systemImage: "books.vertical.fill",
                title: "2급 점자에 오신 것을 환영합니다",
                description: "한글 약자로 점자 실력을 한 단계 높여 보세요. 2급에서는 자주 쓰는 음절과 단어를 더 적은 칸으로 줄인 약자를 익혀 더욱 빠르게 읽을 수 있습니다."
            )
        }
    }

    static let voiceOverTip = TutorialStep(
        systemImage: "hand.tap.fill",
        title: "VoiceOver 및 제스처 안내",
        description: "점자 촉각 영역은 두 번 탭할 필요 없이 한 손가락으로 문지르면 각 점의 번호와 돌출 여부를 음성과 진동으로 알려 줍니다. 다른 글자로 이동할 때는 좌우로 스와이프하거나 VoiceOver에서 위아래로 쓸어내리세요."
    )

    static let settingsStep = TutorialStep(
        systemImage: "slider.horizontal.3",
        title: "나에게 맞게 설정하기",
        description: "시작하기 전에 앱의 음성 안내 방식을 설정하세요. 이 항목은 언제든지 설정 탭에서 변경할 수 있습니다.",
        isSettingsStep: true
    )

    static let portraitTutorial: [TutorialStep] = [
        TutorialStep(
            systemImage: "speaker.wave.3.fill",
            title: "글자 정보와 다시 듣기",
            description: "상단 카드에는 현재 한글 글자, 점자 번호, 학습 진도가 표시됩니다. 상단이나 하단 영역을 탭하면 언제든 글자와 점자 번호 음성을 다시 들을 수 있습니다."
        ),
        TutorialStep(
            systemImage: "hand.draw.fill",
            title: "점자 만지고 위치 듣기",
            description: "중앙의 큰 점자 영역 위에서 손가락을 움직여 보세요. 돌출된 노란 점은 강한 진동과 함께 '1번'처럼 번호를 알려 주고, 빈 점은 약한 진동과 함께 '2번 빈 점'이라고 알려 주어 위치를 쉽게 파악할 수 있습니다."
        ),
        TutorialStep(
            systemImage: "hand.point.left.fill",
            title: "스와이프로 다음 점자 보기",
            description: "상단 카드나 하단 안내 바를 왼쪽으로 스와이프하면 다음 점자로, 오른쪽으로 스와이프하면 이전 점자로 이동하며 자동으로 음성이 재생됩니다."
        )
    ]

    static let landscapeTutorial: [TutorialStep] = [
        TutorialStep(
            systemImage: "sidebar.left",
            title: "글자 정보와 다시 듣기",
            description: "왼쪽 카드에는 한글 글자, 현재 점자 칸 위치(예: 2칸 중 1칸), 활성화된 점자 번호가 표시됩니다. 왼쪽 카드를 탭하면 언제든 음성을 다시 들을 수 있습니다."
        ),
        TutorialStep(
            systemImage: "hand.draw.fill",
            title: "점자 만지고 위치 듣기",
            description: "오른쪽 점자 영역 위에서 손가락을 문질러 보세요. 1번부터 6번 점의 위치와 돌출 여부를 강한 진동·약한 진동과 음성으로 즉시 알려 줍니다."
        ),
        TutorialStep(
            systemImage: "hand.point.left.fill",
            title: "스와이프로 칸과 글자 이동하기",
            description: "왼쪽이나 하단 영역을 좌우로 스와이프하면 한 글자 안의 다음 점자 칸과 다음 글자로 순서대로 이동하며, 이동할 때마다 음성이 계속 안내됩니다."
        )
    ]
}

struct TutorialIntroView: View {
    let steps: [TutorialStep]
    let onBegin: () -> Void

    @State private var currentStep = 0
    @State private var contentOpacity: Double = 1
    @State private var isTransitioning = false

    @AppStorage("autoAnnounce") private var autoAnnounce: Bool = true
    @AppStorage("activeBrailleSound") private var activeBrailleSound: Bool = true

    private let mainPaperColor = Color.black
    private let cardPaperColor = Color(white: 0.12)
    private let inkColor = Color(red: 1.0, green: 0.88, blue: 0.0)
    private let themeInkColor = Color(red: 1.0, green: 0.88, blue: 0.0)

    private var isLastStep: Bool { currentStep == steps.count - 1 }
    private var step: TutorialStep { steps[currentStep] }

    var body: some View {
        ZStack {
            mainPaperColor.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header row
                HStack {
                    if currentStep == 0 {
                        Button("건너뛰기") {
                            onBegin()
                        }
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(inkColor.opacity(0.45))
                        .koreanAccessibilityLabel("사용 안내 건너뛰기")
                        .koreanAccessibilityHint("사용 안내를 건너뛰고 학습을 시작합니다")
                    } else {
                        Color.clear.frame(width: 44, height: 20)
                    }

                    Spacer()

                    koreanText("\(steps.count)단계 중 \(currentStep + 1)단계")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(inkColor.opacity(0.35))
                        .koreanAccessibilityLabel("\(steps.count)단계 중 \(currentStep + 1)단계")
                }
                .padding(.horizontal, 28)
                .padding(.top, 24)

                Spacer()

                // Main content
                VStack(spacing: 24) {
                    Image(systemName: step.systemImage)
                        .font(.system(size: 72, weight: .semibold))
                        .foregroundStyle(themeInkColor)
                        .frame(height: 84)
                        .accessibilityHidden(true)

                    VStack(spacing: 12) {
                        koreanText(step.title)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(inkColor)
                            .multilineTextAlignment(.center)

                        koreanText(step.description)
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundStyle(inkColor.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 36)

                    // Settings toggles — shown only on the settings step
                    if step.isSettingsStep {
                        VStack(spacing: 12) {
                            settingToggleRow(
                                icon: "speaker.wave.2.fill",
                                label: "글자 자동 읽기",
                                hint: "새 글자로 이동하면 글자 이름과 점자 번호를 소리 내어 읽습니다",
                                isOn: $autoAnnounce
                            )
                            settingToggleRow(
                                icon: "waveform",
                                label: "점 위치 음성 안내",
                                hint: "손가락이 점자 점에 닿으면 몇 번 점인지 음성으로 알려 줍니다",
                                isOn: $activeBrailleSound
                            )
                        }
                        .padding(.horizontal, 28)
                        .padding(.top, 4)
                    }
                }
                .opacity(contentOpacity)

                Spacer()

                // Step indicator dots
                HStack(spacing: 8) {
                    ForEach(0..<steps.count, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(i == currentStep ? themeInkColor : inkColor.opacity(0.2))
                            .frame(width: i == currentStep ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentStep)
                    }
                }
                .accessibilityHidden(true)
                .padding(.bottom, 28)

                // Navigation buttons
                Group {
                    if currentStep > 0 {
                        HStack(spacing: 14) {
                            Button {
                                goBack()
                            } label: {
                                koreanText("← 이전")
                                    .font(.system(size: 19, weight: .semibold, design: .rounded))
                                    .foregroundStyle(inkColor.opacity(0.7))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 60)
                                    .background(inkColor.opacity(0.09))
                                    .clipShape(Capsule())
                            }
                            .koreanAccessibilityLabel("이전")
                            .koreanAccessibilityHint("이전 사용 안내 단계로 이동합니다")

                            Button {
                                if isLastStep {
                                    BrailleSpeechManager.shared.stop()
                                    onBegin()
                                } else {
                                    advanceStep()
                                }
                            } label: {
                                koreanText(isLastStep ? "학습 시작" : "다음 →")
                                    .font(.system(size: 19, weight: .bold, design: .rounded))
                                    .foregroundStyle(.black)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 60)
                                    .background(themeInkColor)
                                    .clipShape(Capsule())
                            }
                            .koreanAccessibilityLabel(isLastStep ? "학습 시작" : "다음")
                            .koreanAccessibilityHint(isLastStep ? "학습을 시작합니다" : "\(steps.count)단계 중 \(currentStep + 2)단계로 이동합니다")
                        }
                    } else {
                        Button {
                            if isLastStep {
                                BrailleSpeechManager.shared.stop()
                                onBegin()
                            } else {
                                advanceStep()
                            }
                        } label: {
                            koreanText(isLastStep ? "학습 시작" : "다음 →")
                                .font(.system(size: 19, weight: .bold, design: .rounded))
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(themeInkColor)
                                .clipShape(Capsule())
                        }
                        .koreanAccessibilityLabel(isLastStep ? "학습 시작" : "다음")
                        .koreanAccessibilityHint(isLastStep ? "학습을 시작합니다" : "\(steps.count)단계 중 \(currentStep + 2)단계로 이동합니다")
                    }
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 40)
            }
        }
        .gesture(
            DragGesture(minimumDistance: 30)
                .onEnded { value in
                    let horizontal = value.translation.width
                    let vertical = value.translation.height
                    guard abs(horizontal) > abs(vertical), abs(horizontal) > 40 else { return }
                    if horizontal < 0 {
                        if isLastStep {
                            BrailleSpeechManager.shared.stop()
                            onBegin()
                        } else {
                            advanceStep()
                        }
                    } else {
                        goBack()
                    }
                }
        )
        .onAppear {
            announceStep(delay: 0.45)
        }
    }

    // MARK: - Settings toggle row

    @ViewBuilder
    private func settingToggleRow(icon: String, label: String, hint: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(themeInkColor)
                    .frame(width: 28)
                    .accessibilityHidden(true)

                koreanText(label)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(inkColor)
            }
        }
        .tint(themeInkColor)
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(cardPaperColor)
        )
        .koreanAccessibilityHint(hint)
    }

    // MARK: - Voice & VoiceOver announcement

    private func announceStep(delay: TimeInterval = 0.15) {
        guard autoAnnounce || UIAccessibility.isVoiceOverRunning else { return }
        var text = "\(steps.count)단계 중 \(currentStep + 1)단계. \(step.title). \(step.description)"
        if step.isSettingsStep {
            text += " 글자 자동 읽기는 \(autoAnnounce ? "켜짐" : "꺼짐")입니다. 점 위치 음성 안내는 \(activeBrailleSound ? "켜짐" : "꺼짐")입니다."
        }
        BrailleSpeechManager.shared.speak(text, language: "ko-KR", delay: delay)
    }

    // MARK: - Navigation

    private func advanceStep() {
        guard !isTransitioning else { return }
        isTransitioning = true
        withAnimation(.easeOut(duration: 0.15)) {
            contentOpacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            currentStep += 1
            withAnimation(.easeIn(duration: 0.15)) {
                contentOpacity = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                isTransitioning = false
                announceStep()
            }
        }
    }

    private func goBack() {
        guard !isTransitioning, currentStep > 0 else { return }
        isTransitioning = true
        withAnimation(.easeOut(duration: 0.15)) {
            contentOpacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            currentStep -= 1
            withAnimation(.easeIn(duration: 0.15)) {
                contentOpacity = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                isTransitioning = false
                announceStep()
            }
        }
    }
}
