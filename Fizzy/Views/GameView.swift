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
        _viewModel = StateObject(wrappedValue: GameViewModel(gameID: gameID))  // No service param
    }
    
    var body: some View {
        if let session = viewModel.session {
            VStack {
                if viewModel.isLoadingPrompt {
                    ProgressView("Generating Prompt...")
                } else {
                    Text(viewModel.prompt)
                        .padding()
                        .background(Constants.promptBackground)
                        .cornerRadius(10)
                        .multilineTextAlignment(.center)
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
            }
            .onAppear {
                Task { await viewModel.generateNewPrompt() }
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
