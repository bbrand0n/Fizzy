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
            "prompts": prompts,
            "scores": scores,
            "settings": settings?.asDictionary() ?? [:]
        ]
    }
    
    static func fromDictionary(id: String, data: [String: Any]) -> GameSession {
        GameSession(
            id: id,
            players: data["players"] as? [String] ?? [],
            prompts: data["prompts"] as? [String] ?? [],
            scores: data["scores"] as? [Int] ?? [],
            settings: GameSettings.fromDictionary(data: data["settings"] as? [String: Any] ?? [:])
        )
    }
}
