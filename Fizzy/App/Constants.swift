//
//  Constants.swift
//  Fizzy
//
//  Created by Brandon Gibbons on 8/14/25.
//

import Foundation
import SwiftUICore
import UIKit

enum Constants {
//    static let primaryColor = Color("Primary")
//    static let accentColor = Color("Accent")
//    static let backgroundColor = Color("Background")
//    static let secondaryColor = Color("Secondary")
//    static let textPrimaryColor = Color("TextPrimary")
//    static let textSecondaryColor = Color("TextSecondary")
//    
//    static let penaltyColor = Color("Accent")
//    static let passColor = Color("Secondary")
//    static let promptBackground = Color("Primary")
    
    static let primaryColor = Color.blue  // Existing: Accents/buttons
    static let accentColor = Color.green  // Existing: Positive actions
    static let penaltyColor = Color.red   // Existing: Penalties/errors
    static let passColor = Color.gray     // Existing: Neutral/pass
    static let promptBackground = Color.yellow.opacity(0.5)  // Existing: Softer for cards
    
    // New additions for modern, clean UI (adaptive to light/dark mode)
    static let background = Color(UIColor.systemBackground)  // Main bg, auto-adapts
    static let cardBackground = Color.white.opacity(0.9)     // Cards, semi-transparent for depth
    static let shadowColor = Color.black.opacity(0.1)        // Subtle shadows
    static let textPrimary = Color(UIColor.black)            // Main text, adapts
    static let textSecondary = Color(UIColor.lightGray) // Subtext, adapts
    static let borderColor = Color.gray.opacity(0.3)         // Borders/outlines
    static let cornerRadius: CGFloat = 16                    // Consistent rounding
}
