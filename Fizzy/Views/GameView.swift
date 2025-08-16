//
//  GameView.swift
//  Fizzy
//
//  Created by Brandon Gibbons on 8/14/25.
//

import SwiftUI

struct GameView: View {
    @StateObject private var viewModel: GameViewModel
    
    init(gameID: String) {
        _viewModel = StateObject(wrappedValue: GameViewModel(gameID: gameID))
    }
    
    var body: some View {
        if let session = viewModel.session {
            ZStack {
                Constants.promptBackground.opacity(0.8)
                    .ignoresSafeArea()
                
                VStack {
                    if viewModel.isLoadingPrompt {
                        ProgressView("Generating Card...")
                            .progressViewStyle(.circular)
                            .tint(.white)
                    } else {
                        // Card UI for prompt
                        CardView(prompt: viewModel.prompt)
                            .transition(.move(edge: .trailing))  // Fly away to right on change
                            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: viewModel.prompt)  // Smooth animation
                    }
                    
                    Button("New Prompt") {
                        Task { await viewModel.generateNewPrompt() }
                    }
                    .padding()
                    .background(Constants.accentColor)
                    .foregroundColor(.white)
                    
                    List {
                        ForEach(session.players.indices, id: \.self) { index in
                            HStack {
                                Text("\(session.players[index]): \(session.scores[index]) penalties")
                                Spacer()
                                Button("+1 Penalty") {
                                    Task { await viewModel.incrementPenalty(for: index) }
                                }
                                .foregroundColor(.white)
                                .background(Constants.penaltyColor)
                                .cornerRadius(5)
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)  // Transparent list for game feel
                }
                .padding()
            }
            .onAppear {
                AppDelegate.orientationMask = .landscape
                UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
                Task { await viewModel.generateNewPrompt() }
            }
            .onDisappear {
                // New: Reset to portrait
                AppDelegate.orientationMask = .portrait
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            }
            .alert("Error", isPresented: Binding(get: { viewModel.error != nil }, set: { _ in viewModel.error = nil })) {
                Button("OK") {}
            } message: {
                Text(viewModel.error?.localizedDescription ?? "Unknown error")
            }
        } else {
            ProgressView("Loading Game...")
        }
    }
}

#Preview {
    let gameId = "12345"
    GameView(gameID: gameId)
}
