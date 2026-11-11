//
//  HomeView.swift (CardView Section)
//  BrailleReaderAlpha
//
//  Created by Oliver Park on 12/27/25.
//

import SwiftUI

@available(iOS 16.0, *)
struct CardView: View {
    let level: BrailleLevel
    @State private var status: Bool = false
    @EnvironmentObject var viewModel: ContentViewModel
    
    private let cardColor = Color(white: 0.12)
    private let actionButtonColor = Color(white: 0.18)
    private let inkColor = Color(red: 1.0, green: 0.88, blue: 0.0)
    private let accentColor = Color(red: 1.0, green: 0.88, blue: 0.0)
    
    var body: some View {
        if #available(iOS 16.1, *) {
            Button {
                HapticManager.instance.triggerTransitionHaptic()
                viewModel.push(level)
            } label: {
                VStack(alignment: .leading, spacing: 20) {
                    headerSection
                    
                    Rectangle()
                        .frame(height: 2)
                        .foregroundStyle(inkColor.opacity(0.1))
                    
                    footerSection
                }
                .padding(24)
                .background(cardColor)
                .clipShape(RoundedRectangle(cornerRadius: 28))
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(status ? accentColor.opacity(0.35) : accentColor.opacity(0.12), lineWidth: 1.5)
                )
                .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 5)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .fontDesign(.rounded)
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityElement(children: .ignore)
            .koreanAccessibilityLabel("\(level.title), \(status ? "완료됨, 다시 학습하기" : "학습 시작")")
            .koreanAccessibilityHint("포함 글자: \(level.letters.map { $0.englishName }.joined(separator: ", ")). 두 번 탭하여 수업을 엽니다")
            .onAppear {
                status = UserDefaults.standard.bool(forKey: level.storageKey)
            }
        } else {
            EmptyView()
        }
    }
    
    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                koreanText(level.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(inkColor)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                koreanText(level.letters.map { $0.hangul }.joined(separator: "  "))
                    .font(.body)
                    .foregroundStyle(inkColor.opacity(0.7))
                    .lineLimit(1)
            }
            
            Spacer()
            
            Image(systemName: status ? "checkmark.circle.fill" : "circle.dashed")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundStyle(status ? accentColor : inkColor.opacity(0.3))
                .accessibilityHidden(true)
        }
    }
    
    private var footerSection: some View {
        HStack {
            koreanText(status ? "완료됨 · 다시 학습하기" : "학습 시작")
                .font(.title3)
                .fontWeight(.bold)
            Spacer()
            Image(systemName: status ? "arrow.clockwise" : "arrow.right")
                .font(.title3)
                .fontWeight(.bold)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
        .background(actionButtonColor)
        .foregroundStyle(status ? inkColor.opacity(0.85) : accentColor)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(accentColor.opacity(0.2), lineWidth: 1.5)
        )
    }
}
