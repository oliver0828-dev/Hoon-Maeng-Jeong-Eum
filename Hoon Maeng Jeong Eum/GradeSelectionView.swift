//
//  GradeSelectionView.swift
//  Braille_Read
//
//  Created by Oliver Park on 2/16/26.
//

import SwiftUI

struct GradeSelectionView: View {
    @AppStorage("selected_braille_type") private var selectedType: String = ""

    private let mainBackgroundColor = Color.black
    private let cardColor = Color(white: 0.12)
    private let inkColor = Color(red: 1.0, green: 0.88, blue: 0.0)
    private let accentColor = Color(red: 1.0, green: 0.88, blue: 0.0)

    var body: some View {
        if #available(iOS 16.1, *) {
            ZStack {
                mainBackgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 36) {
                    Spacer()
                 
                    
                    VStack(spacing: 12) {
                      
                        
                        koreanText("점자 유형 선택")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(inkColor)
                            .accessibilityAddTraits(.isHeader)

                        koreanText("학습할 급수를 선택하세요")
                            .font(.title3)
                            .foregroundStyle(inkColor.opacity(0.6))
                    }
                    
                    VStack(spacing: 20) {
                        ForEach(BrailleType.allCases, id: \.self) { type in
                            gradeCard(type: type)
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                    Spacer()
                }
            }
            .fontDesign(.rounded)
            .onAppear {
                BrailleSpeechManager.shared.speak("점자 유형 선택. 1급 정자 점자 또는 2급 약자 점자를 선택하세요.", language: "ko-KR", delay: 0.35)
            }
        } else {
            ZStack {
                mainBackgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 36) {
                    Spacer()
                    
                    VStack(spacing: 12) {
                        koreanText("점자 유형 선택")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(inkColor)
                            .accessibilityAddTraits(.isHeader)

                        koreanText("학습할 급수를 선택하세요")
                            .font(.title3)
                            .foregroundStyle(inkColor.opacity(0.6))
                    }
                    
                    VStack(spacing: 20) {
                        ForEach(BrailleType.allCases, id: \.self) { type in
                            gradeCard(type: type)
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                    Spacer()
                }
            }
        }
    }

    private func gradeCard(type: BrailleType) -> some View {
        Button {
            HapticManager.instance.triggerTransitionHaptic()
            BrailleSpeechManager.shared.stop()
            selectedType = type.rawValue
        } label: {
            VStack(spacing: 12) {
                koreanText(type.displayName)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(inkColor)

                koreanText(type.subtitle)
                    .font(.body)
                    .foregroundStyle(inkColor.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
            .background(cardColor)
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 5)
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(accentColor.opacity(0.15), lineWidth: 1.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .koreanAccessibilityLabel("\(type.displayName), \(type.subtitle)")
        .koreanAccessibilityHint("두 번 탭하여 \(type.displayName) \(type.subtitle) 과정을 선택합니다")
    }
}

#Preview {
    GradeSelectionView()
}
