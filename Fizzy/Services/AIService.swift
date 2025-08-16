//
//  AIService.swift
//  Fizzy
//
//  Created by Brandon Gibbons on 8/14/25.
//

import Foundation

class AIService {
    private let baseURL = "https://api.x.ai/v1"
    private var apiKey: String {
        if let key = Bundle.main.infoDictionary?["GrokAPIKey"] as? String {
            return key
        } else {
            return ""
        }
    }
    
    func generatePrompt(history: [[String: String]]) async -> String {
        let url = URL(string: "\(baseURL)/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": "grok-3-mini",
            "messages": history,
            "max_tokens": 1024,
            "temperature": 0.5,
            "reasoning_effort": "low"
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Enhanced logging: Print status and raw JSON
            if let httpResponse = response as? HTTPURLResponse {
//                print("API Status Code: \(httpResponse.statusCode)")
            }
            if let rawString = String(data: data, encoding: .utf8) {
//                print("Raw API Response: \(rawString)")
            } else {
//                print("Raw data not convertible to string.")
            }
            
            let decoded = try JSONDecoder().decode(GrokResponse.self, from: data)
            let content = decoded.choices[0].message.content.trimmingCharacters(in: .whitespacesAndNewlines)
            if content.isEmpty {
                print("API returned empty content.")
                return ""
            }
            return content
        } catch {
            print("Request/Decoding error: \(error.localizedDescription)")
            return ""
        }
    }
}

// Response struct (confirmed compatible)
struct GrokResponse: Decodable {
    let choices: [Choice]
    struct Choice: Decodable {
        let message: Message
        struct Message: Decodable {
            let content: String
        }
    }
}
