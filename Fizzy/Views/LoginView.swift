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
        ZStack {
            Image("Background")  // Add consistent blurred background
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .blur(radius: Constants.shadowRadius)
                .opacity(Constants.backgroundOpacity)
            
            VStack(spacing: Constants.largeSpacing) {
                Spacer()
                
                // Optional: Add a logo or icon for branding (assuming an asset "AppIcon" exists; replace if needed)
                Image(systemName: "sparkles")
                    .font(.system(size: 60))
                    .foregroundColor(Constants.primaryColor)
                    .shadow(color: Constants.shadowColor, radius: Constants.shadowRadius / 2)
                
                Text("Fizzy Party Game")
                    .font(Constants.titleFont)
                    .foregroundColor(Constants.textPrimary)
                
                // Optional: Add a subtitle for better UX
                Text("Join the fun with friends!")
                    .font(Constants.subheadlineFont)
                    .foregroundColor(Constants.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Constants.mediumSpacing * 2)
                
                Button("Sign in with Google") {
                    Task {
                        guard let presentingVC = UIApplication.shared.windows.first?.rootViewController else { return }
                        _ = await FirebaseService.shared.signInWithGoogle(presentingViewController: presentingVC)
                        isLoggedIn = FirebaseService.shared.user != nil
                    }
                }
                .font(.headline)
                .padding(Constants.mediumSpacing)
                .background(Constants.primaryColor.opacity(Constants.buttonOpacity))
                .foregroundColor(Constants.textPrimary)
                .cornerRadius(Constants.cornerRadius)
                .shadow(color: Constants.shadowColor, radius: Constants.shadowRadius)
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
                .padding(Constants.mediumSpacing)
                .background(Constants.accentColor.opacity(Constants.buttonOpacity))
                .foregroundColor(Constants.textPrimary)
                .cornerRadius(Constants.cornerRadius)
                .shadow(color: Constants.shadowColor, radius: Constants.shadowRadius)
                .disabled(isLoggingIn)
                
                if isLoggingIn {
                    ProgressView()
                        .tint(Constants.primaryColor)
                        .scaleEffect(1.2)
                }
                
                Spacer()
            }
            .padding(Constants.mediumSpacing * 2)
        }
        .background(Constants.background)
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    LoginView(isLoggedIn: .constant(false))
}
