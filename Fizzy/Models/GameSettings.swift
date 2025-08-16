//
//  GameSettings.swift
//  Fizzy
//
//  Created by Brandon Gibbons on 8/15/25.
//

import Foundation

struct GameSettings: Codable {
    var explicitness: Int = 1       // 1: Clean, 5: Explicit
    var playerDetails: String = ""  // E.g., "Bob hates spiders"
    var theme: String = "General"   // E.g., "Party", "Holiday"
    var customInstructions: String = "" // E.g., "Make the pentalties harsh"
}
