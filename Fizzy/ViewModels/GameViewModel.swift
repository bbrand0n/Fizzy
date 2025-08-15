//
//  GameViewModel.swift
//  Fizzy
//
//  Created by Brandon Gibbons on 8/14/25.
//

import Foundation
import FirebaseFirestore

@MainActor
class GameViewModel: ObservableObject {
    @Published var session: GameSession?
    @Published var settings: GameSettings?
    @Published var prompt: String = "Loading prompt..."
    @Published var isLoadingPrompt = false
    @Published var error: Error?
    @Published var conversationHistory: [[String: String]] = []
    private var fixedInitialMessages: [[String: String]] = []
    
    private var listener: ListenerRegistration?
    private let aiService = AIService()
    
    init(gameID: String) {
        setupListener(for: gameID)
    }
    
    private func setupListener(for gameID: String) {
        listener = FirebaseService.shared.observeGameSession(id: gameID) { [weak self] session, error in
            DispatchQueue.main.async {
                self?.session = session
                self?.error = error
                self?.settings = session?.settings
                if let lastPrompt = session?.prompts.last {
                    self?.prompt = lastPrompt
                }
                
                if let settings = self?.settings, self?.conversationHistory.isEmpty ?? true {
                    self?.initializeConversationHistory(with: settings, players: session?.players ?? [])
                }
            }
        }
    }
    
    private func initializeConversationHistory(with settings: GameSettings, players: [String]) {
        let playerList = players.joined(separator: ", ")
        
        likedExamples.shuffle()
        
        fixedInitialMessages = [
            ["role": "system", "content": "You are a party game AI mimicking these example styles. Always generate similar unique, fun prompts with penalties. Base on these fixed settings: Explicitness level \(settings.explicitness)/5 (1: clean and wholesome; 5: wild and edgy). Theme: \(settings.theme). Randomly decide to include player details if relevant: \(settings.playerDetails). Players: \(playerList). Keep prompts creative, conversation-provoking, and interesting. Don't be afraid to use profanity or vulgarity if it adds humor or excitement to the prompt. Use the following examples as inspiration to generate new ones or select and adapt from them. Keep the prompts short and straight forward, under 30 words."],
        ]

        let exampleTypes = ["challenge", "voting game", "story", "targeting", "trivia", "role-play", "debate", "hypothetical", "mimicry"]
        var exampleIndex = 0
        for example in likedExamples.prefix(10) {
            let randomType = exampleTypes.randomElement() ?? "challenge"
            fixedInitialMessages.append(["role": "user", "content": "Generate a \(randomType) style prompt for \(players.count) players, explicitness \(settings.explicitness)."])
            fixedInitialMessages.append(["role": "assistant", "content": example])
            exampleIndex += 1
        }
    }
    
    func generateNewPrompt() async {
        guard let session = session else { return }
        isLoadingPrompt = true
        
        var newPrompt = ""
        var attempts = 0
        let maxAttempts = 3
        
        let targetPlayer = Bool.random()
        var targetPlayerName = "the whole group"
        if targetPlayer {
            targetPlayerName = "a random player: \(session.players.randomElement() ?? "")"
        }
        
        repeat {
            var tempHistory = fixedInitialMessages
            let truncatedDynamic = Array(conversationHistory.suffix(5))
            tempHistory += truncatedDynamic
            
            let randomType = PromptType.random().rawValue
            let userRequest = "Follow the example styles above. Generate a new \(randomType) style prompt for \(session.players.count) players. Target \(targetPlayerName). Avoid repeats from past prompts: \(session.prompts.joined(separator: "; ")). Tie into the initialized settings and examples. Keep the prompts short and straight forward, under 30 words."
            tempHistory.append(["role": "user", "content": userRequest])
            
            newPrompt = await aiService.generatePrompt(history: tempHistory)
            attempts += 1
            print("Attempt \(attempts) of \(maxAttempts): \(newPrompt)")
        } while session.prompts.contains(newPrompt) && attempts < maxAttempts
        
        // Failed, just randomly choose from list
        if newPrompt.isEmpty || session.prompts.contains(newPrompt) {
            newPrompt = likedExamples.randomElement() ?? "I'm sorry, I couldn't generate a new prompt."
            if newPrompt.contains("*name") {
                newPrompt = newPrompt.replacingOccurrences(of: "*name", with: session.players.randomElement() ?? "A random player")
            }
        }
        
        // Append AI response to history
        conversationHistory.append(["role": "assistant", "content": newPrompt])
        
        // Truncate history if too long (keep last 10 messages)
        if conversationHistory.count > 10 {
            conversationHistory = Array(conversationHistory.suffix(10))
        }
        
        prompt = newPrompt
        await FirebaseService.shared.updateGameSession(id: session.id, data: ["prompts": FieldValue.arrayUnion([newPrompt])])
        isLoadingPrompt = false
    }
    
    func incrementPenalty(for playerIndex: Int) async {
        guard var updatedSession = session else { return }
        if playerIndex < updatedSession.scores.count {
            updatedSession.scores[playerIndex] += 1
            await FirebaseService.shared.updateGameSession(id: updatedSession.id, data: ["scores": updatedSession.scores])
        }
    }
    
    deinit {
        listener?.remove()
    }
}
