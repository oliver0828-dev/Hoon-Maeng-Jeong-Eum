import SwiftUI
import UIKit

func koreanText(_ string: String) -> Text {
    let attributed = NSAttributedString(
        string: string,
        attributes: [.accessibilitySpeechLanguage: "ko-KR"]
    )
    return Text(AttributedString(attributed))
}

extension View {
    func koreanAccessibilityLabel(_ label: String) -> some View {
        accessibilityLabel(koreanText(label))
    }

    func koreanAccessibilityHint(_ hint: String) -> some View {
        accessibilityHint(koreanText(hint))
    }
}
