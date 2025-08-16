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
        VStack {
            Text(prompt)
                .font(.headline)
                .foregroundStyle(Constants.textPrimaryColor)
                .multilineTextAlignment(.center)
                .padding()
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(gradient: Gradient(colors: [Constants.primaryColor, Constants.primaryColor.opacity(0.5)]), startPoint: .top, endPoint: .bottom))
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
        )
        .padding()
    }
}

#Preview {
    CardView(prompt: "Hello, World!")
}
