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
    @ObservedObject var firebaseService = FirebaseService.shared
    @State private var isLoggingIn = false
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Fizzy Party Game")
                .font(.largeTitle)
                .foregroundColor(Constants.textPrimary)
            
            Button("Sign in with Google") {
                Task {
                    guard let presentingVC = UIApplication.shared.windows.first?.rootViewController else { return }
                    _ = await FirebaseService.shared.signInWithGoogle(presentingViewController: presentingVC)
                    isLoggedIn = FirebaseService.shared.user != nil
                }
            }
            .font(.headline)
            .padding()
            .background(Constants.primaryColor)
            .foregroundColor(.white)
            .cornerRadius(Constants.cornerRadius)
            .shadow(color: Constants.shadowColor, radius: 4)
            .disabled(isLoggingIn)
            .disabled(isLoggingIn)
            
            Button("Start (Anonymous Login)") {
                Task {
                    isLoggingIn = true
                    await firebaseService.signInAnonymously()
                    isLoggedIn = firebaseService.user != nil
                    isLoggingIn = false
                }
            }
            .font(.headline)
            .padding()
            .background(Constants.accentColor)
            .foregroundColor(.white)
            .cornerRadius(Constants.cornerRadius)
            .shadow(color: Constants.shadowColor, radius: 4)
            .disabled(isLoggingIn)
            
            if isLoggingIn {
                ProgressView().tint(Constants.primaryColor)
            }
        }
        .padding()
        .background(Constants.background)
    }
}

#Preview {
    LoginView(isLoggedIn: .constant(false))
}
