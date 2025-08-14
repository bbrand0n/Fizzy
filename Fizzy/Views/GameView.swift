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
            VStack {
                Text("Current Player: \(session.players[session.currentTurn])")
                    .font(.title2)
                    .padding()
                
                Text(viewModel.prompt)
                    .padding()
                    .background(Color.yellow)
                    .cornerRadius(10)
                    .multilineTextAlignment(.center)
                
                HStack {
                    Button("Accept Penalty (+1)") {
                        Task { await viewModel.acceptPenalty() }
                    }
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    
                    Button("Pass (Next Turn)") {
                        Task { await viewModel.nextTurn() }
                    }
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                }
                
                List {
                    ForEach(session.players.indices, id: \.self) { index in
                        Text("\(session.players[index]): \(session.scores[index]) penalties")
                    }
                }
            }
            .onAppear {
                Task { await viewModel.generateNewPrompt() }
            }
            .alert("Error", isPresented: Binding(get: { viewModel.error != nil }, set: { _ in })) {
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
