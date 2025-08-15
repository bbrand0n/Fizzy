//
//  ContentView.swift
//  Fizzy
//
//  Created by Brandon Gibbons on 8/14/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ContentView: View {
    @ObservedObject var firebaseService = FirebaseService.shared
    @State private var isLoggedIn = false
    
    var body: some View {
        Group {
            if isLoggedIn || firebaseService.user != nil {
                HomeView()
            } else {
                LoginView(isLoggedIn: $isLoggedIn)
            }
        }
        .alert("Error", isPresented: Binding(get: { firebaseService.error != nil }, set: { _ in firebaseService.error = nil })) {
            Button("OK") {}
        } message: {
            Text(firebaseService.error?.localizedDescription ?? "Unknown error")
        }
        .onAppear {
            if Auth.auth().currentUser != nil && firebaseService.user == nil {
                firebaseService.user = Auth.auth().currentUser
            }
        }
    }
}

#Preview {
    ContentView()
}
