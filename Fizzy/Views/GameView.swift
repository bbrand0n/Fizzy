//
//  GameView.swift
//  Fizzy
//
//  Created by Brandon Gibbons on 8/14/25.
//

import SwiftUI
import FirebaseFirestore

struct GameView: View {
    let gameID: String
    let players: [String]
    
    @State private var currentTurn: Int = 0
    @State private var prompt: String = "Loading prompt..."
    @State private var scores: [Int] = []
    @State private var listener: ListenerRegistration?
    
    var body: some View {
        VStack {
            Text("Current Player: \(players[currentTurn])")
                .font(.title2)
                .padding()
            
            Text(prompt)
                .padding()
                .background(Color.yellow)
                .cornerRadius(10)
                .multilineTextAlignment(.center)
            
            HStack {
                Button("Accept Penalty (+1)") {
                    updateScore(increase: true)
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                
                Button("Pass (Next Turn)") {
                    nextTurn()
                }
                .padding()
                .background(Color.gray)
                .foregroundColor(.white)
            }
            
            List {
                ForEach(players.indices, id: \.self) { index in
                    Text("\(players[index]): \(scores[index]) penalties")
                }
            }
        }
        .onAppear {
            setupListener()
            generatePrompt()
        }
        .onDisappear {
            listener?.remove()
        }
    }
    
    private func setupListener() {
        let db = Firestore.firestore()
        listener = db.collection("games").document(gameID).addSnapshotListener { snapshot, error in
            if let data = snapshot?.data() {
                currentTurn = data["currentTurn"] as? Int ?? 0
                scores = data["scores"] as? [Int] ?? Array(repeating: 0, count: players.count)
                if let prompts = data["prompts"] as? [String], !prompts.isEmpty {
                    prompt = prompts.last ?? "No prompt"
                }
            }
        }
    }
    
    private func generatePrompt() {
        // Mock AI generation for MVP; replace with real AI call in next steps
        let mockPrompts = [
            "Tell an embarrassing story or take 2 penalties!",
            "Do 10 push-ups or accept a penalty.",
            "Impersonate a celebrity or drink up!"
        ]
        prompt = mockPrompts.randomElement() ?? "Fun prompt!"
        
        // Update Firestore with new prompt
        let db = Firestore.firestore()
        db.collection("games").document(gameID).updateData([
            "prompts": FieldValue.arrayUnion([prompt])
        ])
    }
    
    private func updateScore(increase: Bool) {
        var newScores = scores
        if increase {
            newScores[currentTurn] += 1
        }
        let db = Firestore.firestore()
        db.collection("games").document(gameID).updateData([
            "scores": newScores
        ]) { _ in
            nextTurn()
        }
    }
    
    private func nextTurn() {
        let next = (currentTurn + 1) % players.count
        let db = Firestore.firestore()
        db.collection("games").document(gameID).updateData([
            "currentTurn": next
        ]) { _ in
            generatePrompt()
        }
    }
}
#Preview {
    let gameId = "12345"
    let players = ["Alice", "Bob"]
    GameView(gameID: gameId, players: players)
}
