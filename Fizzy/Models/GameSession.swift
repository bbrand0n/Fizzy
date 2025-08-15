//
//  GameSession.swift
//  Fizzy
//
//  Created by Brandon Gibbons on 8/14/25.
//

import Foundation

struct GameSession: Identifiable, Codable {
    let id: String
    var players: [String]
    var prompts: [String]
    var scores: [Int]
    var settings: GameSettings?
}
