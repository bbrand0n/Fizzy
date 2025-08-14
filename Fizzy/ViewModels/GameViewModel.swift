//
//  GameViewModel.swift
//  Fizzy
//
//  Created by Brandon Gibbons on 8/14/25.
//

import Foundation
import FirebaseFirestore

class GameViewModel: ObservableObject {
    @Published var session: GameSession?
    @Published var prompt: String = "Loading prompt..."
    @Published var error: Error?
    
    private var listener: ListenerRegistration?
    private let firebaseService = FirebaseService.shared
    private let aiService = AIService()
    
    init(gameID: String) {
        setupListener(for: gameID)
    }
    
    private func setupListener(for gameID: String) {
        listener = firebaseService.observeGameSession(id: gameID) { [weak self] session, error in
            DispatchQueue.main.async {
                self?.session = session
                self?.error = error
                if let lastPrompt = session?.prompts.last {
                    self?.prompt = lastPrompt
                }
            }
        }
    }
    
    func generateNewPrompt() async {
        prompt = await aiService.generatePrompt(context: "Party game for \(session?.players.count ?? 0) players")
        guard let id = session?.id else { return }
        await firebaseService.updateGameSession(id: id, data: ["prompts": FieldValue.arrayUnion([prompt])])
    }
    
    func acceptPenalty() async {
        guard var updatedSession = session else { return }
        updatedSession.scores[updatedSession.currentTurn] += 1
        await firebaseService.updateGameSession(id: updatedSession.id, data: ["scores": updatedSession.scores])
        await nextTurn()
    }
    
    func nextTurn() async {
        guard let updatedSession = session else { return }
        let nextTurn = (updatedSession.currentTurn + 1) % updatedSession.players.count
        await firebaseService.updateGameSession(id: updatedSession.id, data: ["currentTurn": nextTurn])
        await generateNewPrompt()
    }
    
    deinit {
        listener?.remove()
    }
}
