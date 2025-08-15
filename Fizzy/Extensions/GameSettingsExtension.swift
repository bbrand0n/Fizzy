//
//  GameSettingsExtension.swift
//  Fizzy
//
//  Created by Brandon Gibbons on 8/15/25.
//

import Foundation

extension GameSettings {
    func asDictionary() -> [String: Any] {
        ["explicitness": explicitness, "playerDetails": playerDetails, "theme": theme]
    }
    
    static func fromDictionary(data: [String: Any]) -> GameSettings {
        GameSettings(
            explicitness: data["explicitness"] as? Int ?? 1,
            playerDetails: data["playerDetails"] as? String ?? "",
            theme: data["theme"] as? String ?? "General"
        )
    }
}
