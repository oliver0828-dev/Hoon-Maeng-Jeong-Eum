//
//  ContentView.swift
//  Hoon Maeng Jeong Eum
//
//  Created by Oliver Park on 4/4/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            koreanText("안녕하세요!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
