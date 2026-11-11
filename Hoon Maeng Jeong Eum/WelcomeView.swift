import SwiftUI

struct WelcomeView: View {
    let onGetStarted: () -> Void

    private let mainBackgroundColor = Color.black
    private let inkColor = Color(red: 1.0, green: 0.88, blue: 0.0)
    private let accentColor = Color(red: 1.0, green: 0.88, blue: 0.0)

    var body: some View {
        if #available(iOS 16.1, *) {
            ZStack {
                mainBackgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    VStack(spacing: 20) {
                        Image("logo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 140)
                            .accessibilityHidden(true)
                        
                        koreanText("한글 점자\n배우기")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(inkColor)
                            .multilineTextAlignment(.center)
                    }
                    
                    Spacer()
                    
                    Button {
                        HapticManager.instance.triggerTransitionHaptic()
                        BrailleSpeechManager.shared.stop()
                        onGetStarted()
                    } label: {
                        koreanText("시작하기")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(accentColor)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .koreanAccessibilityLabel("시작하기")
                    .koreanAccessibilityHint("학습할 점자 유형을 선택합니다")
                    .padding(.horizontal, 32)
                    .padding(.bottom, 48)
                }
            }
            .fontDesign(.rounded)
            .onAppear {
                BrailleSpeechManager.shared.speak("훈맹정음, 한글 점자 배우기. 시작하기 버튼을 눌러 학습할 점자 급수를 선택하세요.", language: "ko-KR", delay: 0.45)
            }
        } else {
            ZStack {
                mainBackgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    VStack(spacing: 20) {
                        Image("logo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 140)
                            .accessibilityHidden(true)
                        
                        koreanText("한글 점자\n배우기")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(inkColor)
                            .multilineTextAlignment(.center)
                    }
                    
                    Spacer()
                    
                    Button {
                        onGetStarted()
                    } label: {
                        koreanText("시작하기")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(accentColor)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .koreanAccessibilityLabel("시작하기")
                    .koreanAccessibilityHint("학습할 점자 유형을 선택합니다")
                    .padding(.horizontal, 32)
                    .padding(.bottom, 48)
                }
            }
        }
    }
}

#Preview {
    WelcomeView(onGetStarted: {})
}
