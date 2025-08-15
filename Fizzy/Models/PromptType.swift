//
//  PromptType.swift
//  Fizzy
//
//  Created by Brandon Gibbons on 8/15/25.
//

import Foundation

enum PromptType: String, CaseIterable {
    case votingGame = "voting game"  // E.g., "Vote on who is most likely to..."
    case challenge = "challenge"     // E.g., Physical/mental dares or tasks
    case story = "story"             // E.g., Collaborative storytelling or sharing
    case targeting = "targeting"     // E.g., Single out a player for a specific action
    case trivia = "trivia"           // E.g., Fun quizzes or facts
    case rolePlay = "role-play"      // E.g., Impersonate or act out scenarios
    case debate = "debate"           // E.g., Argue silly topics
    case mimicry = "mimicry"         // E.g., Imitate sounds, actions, or people
    
    // Add more cases as needed for expansion
    
    static func random() -> PromptType {
        return allCases.randomElement() ?? .challenge  // Fallback to challenge if needed
    }
}
