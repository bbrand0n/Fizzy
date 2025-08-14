//
//  HomeView.swift
//  Fizzy
//
//  Created by Brandon Gibbons on 8/14/25.
//

import SwiftUI
import FirebaseFirestore

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Setup Your Game")
                    .font(.title)
                
                List {
                    ForEach(viewModel.playerNames.indices, id: \.self) { index in
                        TextField("Player Name", text: $viewModel.playerNames[index])
                    }
                    .onDelete(perform: viewModel.removePlayer)
                    
                    Button("Add Player") {
                        viewModel.addPlayer()
                    }
                }
                
                Button("Start Game") {
                    Task {
                        await viewModel.startGame()
                    }
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(viewModel.isStartingGame)
                
                if viewModel.isStartingGame {
                    ProgressView()
                }
            }
            .navigationDestination(isPresented: Binding(get: { viewModel.gameSessionID != nil }, set: { _ in })) {
                if let id = viewModel.gameSessionID {
                    GameView(gameID: id)
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
