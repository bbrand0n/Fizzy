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
    @State private var theme: String = "Party"
    
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
                .blur(radius: Constants.shadowRadius)
                .opacity(Constants.backgroundOpacity)
            
            VStack(spacing: Constants.largeSpacing) {
                Text("Customize Your Game")
                    .font(Constants.titleFont)
                    .foregroundColor(Constants.textPrimary)
                    .padding(.top, 60)
                
                VStack(spacing: Constants.smallSpacing) {
                    Text("Choose Your Spice Level")
                        .font(Constants.bodyFont)
                        .foregroundColor(Constants.textPrimary)
                    
                    Slider(value: $explicitness, in: 1...5, step: 1) {
                        Text("Explicitness: \(Int(explicitness)) (1: Clean - 5: Wild)")
                            .foregroundColor(Constants.textSecondary)
                    }
                    .tint(Constants.primaryColor)
                    .padding(.horizontal, Constants.mediumSpacing * 2)
                    
                    HStack {
                        Text("Tame")
                            .font(Constants.subheadlineFont)
                            .foregroundColor(Constants.textSecondary)
                        
                        Spacer()
                        
                        Text("Spicy")
                            .font(Constants.subheadlineFont)
                            .foregroundColor(Constants.textSecondary)
                    }
                    .padding(.horizontal, Constants.mediumSpacing * 2)
                }
                .padding()
                .background(Constants.secondaryBackground)
                .cornerRadius(Constants.cornerRadius)
                .shadow(color: Constants.shadowColor, radius: Constants.shadowRadius)
                .padding(.horizontal, Constants.mediumSpacing)
                
                VStack(spacing: Constants.smallSpacing) {
                    Text("Stir the Pot")
                        .font(Constants.bodyFont)
                        .foregroundColor(Constants.textPrimary)
                    
                    TextField("Player Fun Facts (e.g., Bob just got dumped, Alice is afraid of birds)", text: $playerDetails, axis: .vertical)
                        .multilineTextAlignment(.leading)
                        .focused($isTextFieldFocused)
                        .font(Constants.bodyFont)
                        .lineLimit(2...)
                        .textFieldStyle(.plain)
                        .padding(Constants.mediumSpacing)
                        .background(Constants.cardBackground)
                        .cornerRadius(Constants.cornerRadius)
                        .shadow(color: Constants.shadowColor, radius: Constants.shadowRadius)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, Constants.mediumSpacing * 2)
                        .foregroundColor(Constants.textPrimary)
                }
                
                VStack(spacing: Constants.smallSpacing) {
                    Text("Custom Game Instructions")
                        .font(Constants.bodyFont)
                        .foregroundColor(Constants.textPrimary)
                    
                    TextField("Custom prompt for game generation \n(e.g., Lots of trivia)", text: $customInstructions, axis: .vertical)
                        .multilineTextAlignment(.leading)
                        .focused($isTextFieldFocused)
                        .font(Constants.bodyFont)
                        .lineLimit(2...)
                        .textFieldStyle(.plain)
                        .padding(Constants.mediumSpacing)
                        .background(Constants.cardBackground)
                        .cornerRadius(Constants.cornerRadius)
                        .shadow(color: Constants.shadowColor, radius: Constants.shadowRadius)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, Constants.mediumSpacing * 2)
                        .foregroundColor(Constants.textPrimary)
                }
                
                
                VStack(spacing: Constants.smallSpacing) {
                    Text("Choose a Theme")
                        .font(Constants.bodyFont)
                        .foregroundColor(Constants.textPrimary)
                    
                    Picker("Theme", selection: $theme) {
                        ForEach(themes, id: \.self) { Text($0) }
                    }
                    .pickerStyle(.segmented)
                    .cornerRadius(Constants.cornerRadius)
                    .shadow(color: Constants.shadowColor, radius: Constants.shadowRadius)
                    .padding(.horizontal, Constants.mediumSpacing * 2)
                }
                
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
                .padding(Constants.mediumSpacing)
                .background(Constants.accentColor.opacity(Constants.buttonOpacity))
                .foregroundColor(Constants.textPrimary)
                .cornerRadius(Constants.cornerRadius)
                .shadow(color: Constants.shadowColor, radius: Constants.shadowRadius)
                .disabled(isSaving)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, Constants.mediumSpacing * 2)
                
                if isSaving {
                    ProgressView()
                        .tint(Constants.primaryColor)
                        .scaleEffect(1.2)
                }
            }
            .padding(.vertical, Constants.largeSpacing)
            .padding(.bottom, Constants.horizontalLargeSpacing)
            .padding(.horizontal, Constants.horizontalLargeSpacing)
            .ignoresSafeArea(.keyboard)
        }
        .background(Constants.background)
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
