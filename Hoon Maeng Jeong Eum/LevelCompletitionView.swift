//
//  SwiftUIView.swift
//  Braille_Read
//
//  Created by Oliver Park on 1/10/26.
//

import SwiftUI
import Foundation

enum Path: Hashable, Equatable {
    case level(BrailleLevel)
    case complete(BrailleLevel)
}

class ContentViewModel: ObservableObject {
    @Published var path: [Path] = []
    
    func push(_ level: BrailleLevel) {
        path.append(.level(level))
    }
    
    func finish(_ level: BrailleLevel) {
        path.append(.complete(level))
    }
    
    func reset() {
        path.removeAll()
    }
    
    func replace(_ level: BrailleLevel) {
        path.removeAll()
        path.append(.level(level))
    }
}

@available(iOS 16.0, *)
struct LevelCompletionView: View {
    @EnvironmentObject var viewModel: ContentViewModel
    @AppStorage("selected_braille_type") private var selectedType: String = ""

    let levelTitle: String
    var nextLevel: BrailleLevel? = nil
    var showGrade2Advancement: Bool = false

    @State private var animateCircle = false
    @State private var showConfetti = false
    
    private let mainPaperColor = Color.black
    private let cardPaperColor = Color(white: 0.12)
    private let inkColor = Color(red: 1.0, green: 0.88, blue: 0.0)
    private let themeInkColor = Color(red: 1.0, green: 0.88, blue: 0.0)
    
    private var isNextLevelCompleted: Bool {
        guard let next = nextLevel else { return false }
        return UserDefaults.standard.bool(forKey: next.storageKey)
    }
    
    var body: some View {
        ZStack {
            mainPaperColor.ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                Text(levelTitle)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(inkColor)
                    .padding()
                
                ZStack {
                    Circle()
                        .stroke(cardPaperColor, lineWidth: 20)
                        .frame(width: 200, height: 200)
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                    
                    Circle()
                        .trim(from: 0, to: animateCircle ? 1.0 : 0)
                        .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round))
                        .foregroundStyle(themeInkColor)
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeOut(duration: 1.5), value: animateCircle)
                    
                    VStack {
                        Text("100%")
                            .font(.system(size: 50, weight: .black, design: .rounded))
                            .foregroundStyle(themeInkColor)
                        
                        Text("Completed")
                            .font(.headline)
                            .foregroundStyle(inkColor.opacity(0.6))
                    }
                }
                
                Spacer()
                
                VStack(spacing: 15) {
                    if showGrade2Advancement {
                        Text("You've completed Grade 1!")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(themeInkColor)
                            .padding(.bottom, 5)

                        Button {
                            saveProgress()
                            selectedType = BrailleType.yakja.rawValue
                            viewModel.reset()
                        } label: {
                            Text("Advance to Grade 2")
                                .font(.title3).fontWeight(.bold)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity).frame(height: 60)
                                .background(themeInkColor)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5)
                        }

                        Button {
                            saveProgress()
                            viewModel.reset()
                        } label: {
                            Text("Return Home")
                                .font(.title3).fontWeight(.bold)
                                .foregroundColor(themeInkColor)
                                .frame(maxWidth: .infinity).frame(height: 60)
                                .background(cardPaperColor)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5)
                        }
                    } else {
                        if let next = nextLevel {
                            if isNextLevelCompleted {
                                Text("You have already finished the next level!")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(themeInkColor)
                                    .padding(.bottom, 5)
                            } else {
                                Button {
                                    saveProgress()
                                    viewModel.replace(next)
                                } label: {
                                    Text("Next Level")
                                        .font(.title3).fontWeight(.bold)
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity).frame(height: 60)
                                        .background(themeInkColor)
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5)
                                }
                            }
                        }

                        Button {
                            saveProgress()
                            viewModel.reset()
                        } label: {
                            Text("Return Home")
                                .font(.title3).fontWeight(.bold)
                                .foregroundColor((nextLevel != nil && !isNextLevelCompleted) ? themeInkColor : .black)
                                .frame(maxWidth: .infinity).frame(height: 60)
                                .background((nextLevel != nil && !isNextLevelCompleted) ? cardPaperColor : themeInkColor)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5)
                        }
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
            
            if showConfetti {
                ConfettiView()
                    .allowsHitTesting(false)
            }
        }
        .onAppear {
            saveProgress()
            animateCircle = true
            showConfetti = true
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func saveProgress() {
        let typeRaw = UserDefaults.standard.string(forKey: "selected_braille_type") ?? BrailleType.jeongja.rawValue
        let brailleType = BrailleType(rawValue: typeRaw) ?? .jeongja
        let allLevels = BrailleData.sections(for: brailleType).flatMap { $0.levels }
        if let currentLevel = allLevels.first(where: { $0.title == levelTitle }) {
            UserDefaults.standard.set(true, forKey: currentLevel.storageKey)
            // Clear saved position since the level is complete
            UserDefaults.standard.removeObject(forKey: "\(currentLevel.storageKey)_progress")
            UserDefaults.standard.removeObject(forKey: "\(currentLevel.storageKey)_jamo_progress")
        }
    }
}

private struct ConfettiPiece {
    let emoji: String
    let size: CGFloat
    let xFraction: CGFloat
    let duration: Double
    let delay: Double
}

struct ConfettiView: View {
    @State private var animate = false
    @State private var pieces: [ConfettiPiece] = []

    private let emojis = ["🎉", "🎊", "⭐️", "✨", "🎈"]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<pieces.count, id: \.self) { i in
                    let piece = pieces[i]
                    Text(piece.emoji)
                        .font(.system(size: piece.size))
                        .position(
                            x: piece.xFraction * geo.size.width,
                            y: animate ? geo.size.height + 100 : -100
                        )
                        .animation(
                            .linear(duration: piece.duration)
                            .repeatForever(autoreverses: false)
                            .delay(piece.delay),
                            value: animate
                        )
                }
            }
        }
        .onAppear {
            pieces = (0..<50).map { _ in
                ConfettiPiece(
                    emoji: emojis.randomElement()!,
                    size: CGFloat.random(in: 20...40),
                    xFraction: CGFloat.random(in: 0...1),
                    duration: Double.random(in: 2...4),
                    delay: Double.random(in: 0...2)
                )
            }
            animate = true
        }
    }
}
