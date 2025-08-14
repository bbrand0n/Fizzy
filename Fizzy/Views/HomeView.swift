//
//  HomeView.swift
//  Fizzy
//
//  Created by Brandon Gibbons on 8/14/25.
//

import SwiftUI
import FirebaseFirestore

struct HomeView: View {
    @State private var playerNames: [String] = ["Player 1"]
    @State private var gameSessionID: String?
    @State private var showGame = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Setup Your Game")
                    .font(.title)
                
                List {
                    ForEach(playerNames.indices, id: \.self) { index in
                        TextField("Player Name", text: $playerNames[index])
                    }
                    .onDelete { indices in
                        playerNames.remove(atOffsets: indices)
                    }
                    
                    Button("Add Player") {
                        playerNames.append("Player \(playerNames.count + 1)")
                    }
                }
                
                Button("Start Game") {
                    createGameSession()
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .navigationDestination(isPresented: $showGame) {
                if let id = gameSessionID {
                    GameView(gameID: id, players: playerNames)
                }
            }
        }
    }
    
    private func createGameSession() {
        let db = Firestore.firestore()
        let sessionData: [String: Any] = [
            "players": playerNames,
            "currentTurn": 0,
            "prompts": [],
            "scores": Array(repeating: 0, count: playerNames.count)
        ]
        
        var ref: DocumentReference? = nil
        ref = db.collection("games").addDocument(data: sessionData) { error in
            if let error = error {
                print("Error creating session: \(error)")
            } else {
                gameSessionID = ref?.documentID
                showGame = true
            }
        }
    }
}

#Preview {
    HomeView()
}
