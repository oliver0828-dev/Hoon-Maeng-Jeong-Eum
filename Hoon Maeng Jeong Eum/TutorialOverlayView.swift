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
                title: "Welcome to Grade 1 Braille",
                description: "Learn Korean braille from scratch. Starting with individual consonants and vowels, you'll build up to full syllables and words — one dot at a time."
            )
        case .yakja:
            return TutorialStep(
                systemImage: "books.vertical.fill",
                title: "Welcome to Grade 2 Braille",
                description: "Take your braille further with abbreviated Korean. Grade 2 uses shorthand symbols that compress common syllables and words into fewer cells for faster reading."
            )
        }
    }

    static let voiceOverTip = TutorialStep(
        systemImage: "hand.tap.fill",
        title: "VoiceOver & Touch Tips",
        description: "If you use VoiceOver, double-tap any button to activate it. For the braille dot grid, simply touch or drag with one finger — it responds directly without needing a double-tap."
    )

    static let settingsStep = TutorialStep(
        systemImage: "slider.horizontal.3",
        title: "Personalize Your Experience",
        description: "Set up how the app communicates with you before you begin. You can also change these anytime in Settings.",
        isSettingsStep: true
    )

    static let portraitTutorial: [TutorialStep] = [
        TutorialStep(
            systemImage: "chart.bar.fill",
            title: "Track Your Progress",
            description: "The counter at the top shows your position (e.g., 2 / 15). The blue bar fills as you advance through the level."
        ),
        TutorialStep(
            systemImage: "speaker.wave.3.fill",
            title: "Hear the Letter",
            description: "Tap the speaker icon to hear the Korean letter name and its braille dot numbers read aloud."
        ),
        TutorialStep(
            systemImage: "hand.draw.fill",
            title: "Explore the Dots",
            description: "Drag your finger across the dot grid. Yellow raised dots vibrate and play a sound. The number on each dot shows its position in the braille cell."
        ),
        TutorialStep(
            systemImage: "arrow.left.arrow.right",
            title: "Navigate Letters",
            description: "Use ← → arrows to move between letters. The letter name shows in the center. On the last letter, the right arrow becomes ✓ to complete the level."
        )
    ]

    static let landscapeTutorial: [TutorialStep] = [
        TutorialStep(
            systemImage: "sidebar.left",
            title: "Letter Info Panel",
            description: "The left panel shows the Korean letter, its English name, and which cell you're on (e.g., Page 1 of 2). Active braille dot numbers are listed below."
        ),
        TutorialStep(
            systemImage: "hand.draw.fill",
            title: "Explore the Dots",
            description: "Drag your finger over the dot grid on the right. Yellow raised dots vibrate and play a sound. Some letters span multiple cells — navigate with the arrows."
        ),
        TutorialStep(
            systemImage: "arrow.left.arrow.right",
            title: "Navigate Cells & Letters",
            description: "Use ← → arrows to move through cells within a letter, then advance to the next letter. On the last cell, the right arrow becomes ✓ to complete the level."
        ),
        TutorialStep(
            systemImage: "xmark.circle.fill",
            title: "Exit & Track Progress",
            description: "Tap the X in the top left to exit the level anytime. The progress bar at the bottom left tracks your position through all cells."
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
                        Button("Skip") {
                            onBegin()
                        }
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(inkColor.opacity(0.45))
                        .accessibilityLabel("Skip tutorial")
                        .accessibilityHint("Skip the tutorial and begin the lesson")
                    } else {
                        Color.clear.frame(width: 44, height: 20)
                    }

                    Spacer()

                    Text("\(currentStep + 1) of \(steps.count)")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(inkColor.opacity(0.35))
                        .accessibilityLabel("Step \(currentStep + 1) of \(steps.count)")
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
                        Text(step.title)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(inkColor)
                            .multilineTextAlignment(.center)

                        Text(step.description)
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
                                label: "Auto-Read Letters",
                                hint: "Speaks the letter name and braille numbers aloud when you move to a new letter",
                                isOn: $autoAnnounce
                            )
                            settingToggleRow(
                                icon: "waveform",
                                label: "Dot Sound",
                                hint: "Plays a tone when your finger touches an active braille dot",
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
                                Text("← Back")
                                    .font(.system(size: 19, weight: .semibold, design: .rounded))
                                    .foregroundStyle(inkColor.opacity(0.7))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 60)
                                    .background(inkColor.opacity(0.09))
                                    .clipShape(Capsule())
                            }
                            .accessibilityLabel("Back")
                            .accessibilityHint("Go to the previous tutorial step")

                            Button {
                                if isLastStep { onBegin() } else { advanceStep() }
                            } label: {
                                Text(isLastStep ? "Begin Lesson" : "Next →")
                                    .font(.system(size: 19, weight: .bold, design: .rounded))
                                    .foregroundStyle(.black)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 60)
                                    .background(themeInkColor)
                                    .clipShape(Capsule())
                            }
                            .accessibilityLabel(isLastStep ? "Begin Lesson" : "Next")
                            .accessibilityHint(isLastStep ? "Start the lesson" : "Go to step \(currentStep + 2) of \(steps.count)")
                        }
                    } else {
                        Button {
                            if isLastStep { onBegin() } else { advanceStep() }
                        } label: {
                            Text(isLastStep ? "Begin Lesson" : "Next →")
                                .font(.system(size: 19, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(themeInkColor)
                                .clipShape(Capsule())
                        }
                        .accessibilityLabel(isLastStep ? "Begin Lesson" : "Next")
                        .accessibilityHint(isLastStep ? "Start the lesson" : "Go to step \(currentStep + 2) of \(steps.count)")
                    }
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                announceStep()
            }
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

                Text(label)
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
        .accessibilityHint(hint)
    }

    // MARK: - VoiceOver announcement

    private func announceStep() {
        guard UIAccessibility.isVoiceOverRunning else { return }
        var text = "\(step.title). \(step.description)"
        if step.isSettingsStep {
            text += " Auto-Read Letters is \(autoAnnounce ? "on" : "off"). Dot Sound is \(activeBrailleSound ? "on" : "off")."
        }
        UIAccessibility.post(notification: .announcement, argument: text)
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
