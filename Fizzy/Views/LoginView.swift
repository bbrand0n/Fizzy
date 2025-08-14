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
    @State private var errorMessage: String?
    
    var body: some View {
        VStack {
            Text("Party Card Game")
                .font(.largeTitle)
                .padding()
            
            Button("Start Game (Anonymous Login)") {
                Auth.auth().signInAnonymously { authResult, error in
                    if let error = error {
                        errorMessage = error.localizedDescription
                    } else {
                        isLoggedIn = true
                    }
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            if let error = errorMessage {
                Text(error).foregroundColor(.red)
            }
        }
    }
}

#Preview {
    @Previewable @State var isLoggedIn = false
    LoginView(isLoggedIn: $isLoggedIn)
}
