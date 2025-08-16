//
//  GameSetupView.swift
//  Fizzy
//
//  Created by Brandon Gibbons on 8/15/25.
//

import SwiftUI

struct GameSetupView: View {
    let gameID: String
    let themes = ["General", "Party", "Holiday", "Romantic"]
    
    @FocusState private var isTextFieldFocused: Bool
    @State private var explicitness: Double = 3.0
    @State private var playerDetails: String = ""
    @State private var customInstructions: String = ""
    @State private var theme: String = "General"
    
    @State private var isSaving = false
    @State private var showGameView = false
    
    init(gameID: String) {
        self.gameID = gameID
        
        UISegmentedControl.appearance().layer.cornerRadius = Constants.cornerRadius
        UISegmentedControl.appearance().layer.masksToBounds = true
        UISegmentedControl.appearance().layer.borderWidth = 1.0
    }
    
    var body: some View {
        ZStack {
            Image("Background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .blur(radius: 4)
                .opacity(0.3)
            
            VStack(spacing: 32) {
                Text("Customize Your Game")
                    .font(.title)
                    .foregroundColor(Constants.textPrimary)
                    .padding(.top, 60)
                
                Spacer()
                
                VStack {
                    Text("Choose Your Spice Level:")
                        .font(.system(.body, design: .rounded))
                    
                    Slider(value: $explicitness, in: 1...5, step: 1) {
                        Text("Explicitness: \(Int(explicitness)) (1: Clean - 5: Wild)")
                            .foregroundColor(Constants.textSecondary)
                    }
                    .tint(Constants.primaryColor)  // Matched tint
                    .padding(.horizontal, 40)
                    
                    HStack {
                        Text("Spice Level: \(Int(explicitness))")
                            .font(.system(.caption, design: .rounded))
                        
                        Spacer()
                        
                        Text("1: Tame - 5: Spicy)")
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(Constants.textSecondary)
                    }
                    .padding()
                    .padding(.horizontal, 40)
                }
                
                Spacer()
                
                VStack {
                    Text("Stir the Pot:")
                        .font(.system(.body, design: .rounded))
                    
                    TextField("Player Fun Facts (e.g., Bob just got dumped, Alice is afraid of birds", text: $playerDetails, axis: .vertical)
                        .multilineTextAlignment(.leading)
                        .focused($isTextFieldFocused)
                        .font(.system(.body, design: .rounded))
                        .lineLimit(2...)
                        .textFieldStyle(.plain)
                        .padding(12)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(Constants.cornerRadius)
                        .shadow(color: Constants.shadowColor, radius: 4)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 40)
                        .shadow(color: Constants.shadowColor, radius: 4)
                }
                
                VStack {
                    Text("Custom Game Instructions:")
                        .font(.system(.body, design: .rounded))
                    
                    TextField("Custom prompt for game generation \n(e.g., Lots of trivia!)", text: $customInstructions, axis: .vertical)
                        .multilineTextAlignment(.leading)
                        .focused($isTextFieldFocused)
                        .font(.system(.body, design: .rounded))
                        .lineLimit(2...)
                        .textFieldStyle(.plain)
                        .padding(12)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(Constants.cornerRadius)
                        .shadow(color: Constants.shadowColor, radius: 4)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 40)
                        .shadow(color: Constants.shadowColor, radius: 4)
                }
                
                Spacer()
                
                VStack {
                    Text("Choose a Theme:")
                        .font(.system(.body, design: .rounded))
                    
                    Picker("Theme", selection: $theme) {
                        ForEach(themes, id: \.self) { Text($0) }
                    }
                    .pickerStyle(.segmented)
                    //                .background(Color.gray.opacity(0))
                    .cornerRadius(Constants.cornerRadius)
                    .shadow(color: Constants.shadowColor, radius: 4)
                    .padding(.horizontal, 40)
                }
                
                Spacer()
                
                Button("Start Game") {
                    Task {
                        isSaving = true
                        let settings = GameSettings(explicitness: Int(explicitness), playerDetails: playerDetails, theme: theme)
                        await saveSettings(to: gameID, settings: settings)
                        isSaving = false
                        showGameView = true
                    }
                }
                .font(.headline)
                .padding()
                .background(Constants.accentColor.opacity(0.9))
                .foregroundColor(.white)
                .cornerRadius(Constants.cornerRadius)
                .shadow(color: Constants.shadowColor, radius: 4)
                .disabled(isSaving)
                .frame(maxWidth: .infinity, alignment: .center)  // Centered like HomeView
                
                if isSaving {
                    ProgressView()
                        .tint(Constants.primaryColor)
                }
            }
            .padding()
            .padding(.horizontal, 40)
        }
        .navigationDestination(isPresented: $showGameView) {
            GameView(gameID: gameID)
        }
        .onTapGesture {
            isTextFieldFocused = false
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
