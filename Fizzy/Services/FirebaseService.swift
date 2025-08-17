//
//  FirebaseService.swift
//  Fizzy
//
//  Created by Brandon Gibbons on 8/14/25.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn

class FirebaseService: ObservableObject {
    static let shared = FirebaseService()
    private let db = Firestore.firestore()
    
    @Published var user: User?
    @Published var error: Error? {
        didSet {
            if error != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.error = nil  // Auto-reset after display
                }
            }
        }
    }
    
    private init() {
        if let currentUser = Auth.auth().currentUser {
            self.user = currentUser
        }
    }
    
    @MainActor
    func signInAnonymously() async {
        do {
            let result = try await Auth.auth().signInAnonymously()
            user = result.user
        } catch {
            self.error = error
        }
    }
    
    @MainActor
    func signInWithGoogle(presentingViewController: UIViewController) async -> Bool {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return false }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController)
            let idToken = result.user.idToken?.tokenString
            let accessToken = result.user.accessToken.tokenString
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken ?? "", accessToken: accessToken)
            
            let authResult = try await Auth.auth().signIn(with: credential)
            user = authResult.user
            return true
        } catch {
            self.error = error
            return false
        }
    }
    
    @MainActor
    func signOut() {
        do {
            GIDSignIn.sharedInstance.signOut()
            try Auth.auth().signOut()
            user = nil
        } catch {
            self.error = error
        }
    }
    
    @MainActor
    func createGameSession(players: [String]) async -> String? {
        let session = GameSession(
            id: "",
            players: players,
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
    
    @MainActor
    func observeGameSession(id: String, completion: @escaping (GameSession?, Error?) -> Void) -> ListenerRegistration {
        return db.collection("games").document(id).addSnapshotListener { snapshot, error in
            guard let data = snapshot?.data() else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let session = GameSession.fromDictionary(id: id, data: data)
            DispatchQueue.main.async {
                completion(session, nil)
            }
        }
    }
    
    @MainActor
    func updateGameSession(id: String, data: [String: Any]) async {
        do {
            try await db.collection("games").document(id).updateData(data)
        } catch {
            self.error = error
        }
    }
}
