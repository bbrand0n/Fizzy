//
//  GameSessionExtension.swift
//  Fizzy
//
//  Created by Brandon Gibbons on 8/14/25.
//

import Foundation

extension GameSession {
    func asDictionary() -> [String: Any] {
        [
            "players": players,
            "currentTurn": currentTurn,
            "prompts": prompts,
            "scores": scores
        ]
    }
    
    static func fromDictionary(id: String, data: [String: Any]) -> GameSession {
        GameSession(
            id: id,
            players: data["players"] as? [String] ?? [],
            currentTurn: data["currentTurn"] as? Int ?? 0,
            prompts: data["prompts"] as? [String] ?? [],
            scores: data["scores"] as? [Int] ?? []
        )
    }
}
