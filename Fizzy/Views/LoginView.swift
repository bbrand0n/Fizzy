//
//  LoginView.swift
//  Fizzy
//
//  Created by Brandon Gibbons on 8/14/25.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @Binding var isLoggedIn: Bool
    @State private var isLoggingIn = false
    
    var body: some View {
        VStack {
            Text("Fizzy Party Game")
                .font(.largeTitle)
                .padding()
            
            Button("Start (Anonymous Login)") {
                Task {
                    isLoggingIn = true
                    await FirebaseService.shared.signInAnonymously()
                    isLoggedIn = FirebaseService.shared.user != nil
                    isLoggingIn = false
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(isLoggingIn)
            
            if isLoggingIn {
                ProgressView()
            }
        }
    }
}

#Preview {
    LoginView(isLoggedIn: .constant(false))
}
