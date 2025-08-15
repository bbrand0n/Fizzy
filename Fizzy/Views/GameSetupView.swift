//
//  GameSetupView.swift
//  Fizzy
//
//  Created by Brandon Gibbons on 8/15/25.
//

import SwiftUI

struct GameSetupView: View {
    let gameID: String
    @State private var explicitness: Double = 1.0
    @State private var playerDetails: String = ""
    @State private var theme: String = "General"
    let themes = ["General", "Party", "Holiday", "Romantic"]
    
    @State private var isSaving = false
    @State private var showGameView = false
    
    var body: some View {
        VStack {
            Text("Customize the Game Vibe")
                .font(.title)
            
            Slider(value: $explicitness, in: 1...5, step: 1) {
                Text("Explicitness: \(Int(explicitness)) (1: Clean - 5: Wild)")
            }
            
            TextField("Player Fun Facts (optional)", text: $playerDetails)
                .padding()
                .background(Color.gray.opacity(0.2))
            
            Picker("Theme", selection: $theme) {
                ForEach(themes, id: \.self) { Text($0) }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            Button("Start Game") {
                Task {
                    isSaving = true
                    let settings = GameSettings(explicitness: Int(explicitness), playerDetails: playerDetails, theme: theme)
                    await saveSettings(to: gameID, settings: settings)
                    isSaving = false
                    showGameView = true
                }
            }
            .padding()
            .background(Constants.accentColor)
            .foregroundColor(.white)
            .disabled(isSaving)
            
            if isSaving { ProgressView() }
        }
        .padding()
        .navigationDestination(isPresented: $showGameView) {  // New: Navigate to GameView
            GameView(gameID: gameID)
        }
    }
    
    private func saveSettings(to gameID: String, settings: GameSettings) async {
        // Save to Firestore (e.g., as a field in session or subdoc)
        await FirebaseService.shared.updateGameSession(id: gameID, data: ["settings": settings.asDictionary()])
        
        
    }
}

#Preview {
    GameSetupView(gameID: "1234")
}
