//
//  FirebaseService.swift
//  Fizzy
//
//  Created by Brandon Gibbons on 8/14/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class FirebaseService: ObservableObject {
    static let shared = FirebaseService()
    
    @Published var user: User?
    @Published var error: Error?
    
    private let db = Firestore.firestore()
    
    func signInAnonymously() async {
        do {
            let result = try await Auth.auth().signInAnonymously()
            user = result.user
        } catch {
            self.error = error
        }
    }
    
    func createGameSession(players: [String]) async -> String? {
        let session = GameSession(
            id: "",  // Will be set by Firestore
            players: players,
            currentTurn: 0,
            prompts: [],
            scores: Array(repeating: 0, count: players.count)
        )
        
        do {
            let ref = try await db.collection("games").addDocument(data: session.asDictionary())
            return ref.documentID
        } catch {
            self.error = error
            return nil
        }
    }
    
    func observeGameSession(id: String, completion: @escaping (GameSession?, Error?) -> Void) -> ListenerRegistration {
        return db.collection("games").document(id).addSnapshotListener { snapshot, error in
            guard let data = snapshot?.data() else {
                completion(nil, error)
                return
            }
            let session = GameSession.fromDictionary(id: id, data: data)
            completion(session, nil)
        }
    }
    
    func updateGameSession(id: String, data: [String: Any]) async {
        do {
            try await db.collection("games").document(id).updateData(data)
        } catch {
            self.error = error
        }
    }
}
