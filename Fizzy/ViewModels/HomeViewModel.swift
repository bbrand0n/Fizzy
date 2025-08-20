//
//  HomeViewModel.swift
//  Fizzy
//
//  Created by Brandon Gibbons on 8/14/25.
//

import Foundation

@MainActor
class HomeViewModel: ObservableObject {
    @Published var playerNames: [String] = []
    @Published var gameSessionID: String?
    @Published var isStartingGame = false
    
    private let firebaseService = FirebaseService.shared
    
    init() {}
    
    func addPlayer() {
        playerNames.append("Player \(playerNames.count + 1)")
    }
    
    func removePlayer(at offsets: IndexSet) {
        playerNames.remove(atOffsets: offsets)
    }
    
    func startGame() async {
        playerNames = playerNames.filter { !$0.isEmpty }  // Validate: remove empty names
        if playerNames.isEmpty { return }
        isStartingGame = true
        gameSessionID = await firebaseService.createGameSession(players: playerNames)
        isStartingGame = false
    }
}
