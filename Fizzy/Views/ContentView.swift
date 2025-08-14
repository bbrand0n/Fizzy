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
    @State private var isLoggedIn = false
    
    var body: some View {
        if isLoggedIn || FirebaseService.shared.user != nil {
            HomeView()
        } else {
            LoginView(isLoggedIn: $isLoggedIn)
        }
            
    }
}

#Preview {
    ContentView()
}
