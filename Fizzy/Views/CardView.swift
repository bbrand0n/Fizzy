//
//  CardView.swift
//  Fizzy
//
//  Created by Brandon Gibbons on 8/15/25.
//

import SwiftUI

struct CardView: View {
    let prompt: String
    
    var body: some View {
        Text(prompt)
            .font(.system(.title2, design: .rounded))
            .foregroundColor(Constants.textPrimary)
            .multilineTextAlignment(.center)
            .padding(24)
            .frame(maxWidth: .infinity, minHeight: 200)
            .background(
                Constants.cardBackground
                    .overlay(Constants.promptBackground)  // Blend with existing yellow for subtle tint
            )
            .cornerRadius(Constants.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                    .stroke(Constants.borderColor, lineWidth: 1)
            )
            .shadow(color: Constants.shadowColor, radius: 8)
    }
}

#Preview {
    CardView(prompt: "Hello, World!")
}
