//
//  AIService.swift
//  Fizzy
//
//  Created by Brandon Gibbons on 8/14/25.
//

import Foundation

class AIService {
    func generatePrompt(context: String) async -> String {
        // Mock for now; integrate real AI API here (e.g., OpenAI)
        let mocks = [
            "Tell an embarrassing story or take 2 penalties!",
            "Do 10 push-ups or accept a penalty.",
            "Impersonate a celebrity or drink up!"
        ]
        return mocks.randomElement() ?? "Fun prompt!"
    }
}
