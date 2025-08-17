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
    // Core Colors (Accents - kept consistent but with slight adaptation via opacity or variants)
    static let primaryColor = Color.blue  // Main accent for buttons/icons
    static let accentColor = Color.green  // Positive actions (e.g., start game)
    static let penaltyColor = Color.red   // Errors/penalties
    static let passColor = Color.gray     // Neutral/pass actions
    
    // Backgrounds and Surfaces (Fully adaptive to light/dark)
    static let background = Color(UIColor.systemBackground)  // Main app background
    static let secondaryBackground = Color(UIColor.secondarySystemBackground)  // Secondary surfaces
    static let cardBackground = Color(UIColor.tertiarySystemBackground).opacity(0.9)  // Cards/bubbles for depth
    static let promptBackground = Color.yellow.opacity(0.5)  // Softer for prompt cards (can adapt if needed)
    
    // Text and Labels (Adaptive)
    static let textPrimary = Color(UIColor.label)             // Primary text
    static let textSecondary = Color(UIColor.secondaryLabel)  // Secondary/subtext
    static let textTertiary = Color(UIColor.tertiaryLabel)    // Tertiary/hints
    static let placeholderText = Color(UIColor.placeholderText)  // Specifically for placeholders
    
    // Borders, Shadows, and Dividers (Adaptive)
    static let borderColor = Color(UIColor.separator)         // Borders/dividers
    static let shadowColor = Color(UIColor.label).opacity(0.1)  // Shadows (uses label for subtle adaptation)
    static let dividerColor = Color(UIColor.separator)        // Dividers/lines
    
    // Opacities (Static but tunable)
    static let backgroundOpacity = 0.2    // For blurred/overlaid backgrounds
    static let buttonOpacity = 0.9        // For buttons/cards
    static let secondaryOpacity = 0.4     // For disabled/secondary elements
    static let shadowOpacity = 0.1        // For shadows
    
    // Spacing and Sizing (Consistent across modes)
    static let smallSpacing: CGFloat = 8
    static let mediumSpacing: CGFloat = 16
    static let largeSpacing: CGFloat = 32
    static let horizontalLargeSpacing: CGFloat = 70
    static let cornerRadius: CGFloat = 16
    static let shadowRadius: CGFloat = 4.0
    
    // Fonts (System with design for consistency)
    static let titleFont = Font.system(.title, design: .rounded, weight: .semibold)
    static let bodyFont = Font.system(.body, design: .rounded)
    static let subheadlineFont = Font.system(.subheadline, design: .rounded)
    
    // Other UI Constants
    static let maxPlayers = 10            // Limit for player addition
    static let animationDuration = 0.3    // For transitions/animations
}
// Usage Notes:
// - Adaptive colors use UIColor.system* which automatically switch in light/dark modes (e.g., label is black in light, white in dark).
// - For custom accents (blue, green, etc.), they remain fixed for branding but can be used with adaptive opacities.
// - If more adaptation needed for accents, define in Assets.xcassets as Color Sets with light/dark variants.
// - Opacities ensure subtle transparency without losing visibility.
