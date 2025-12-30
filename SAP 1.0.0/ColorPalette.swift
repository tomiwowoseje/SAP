//
//  ColorPalette.swift
//  SAP 1.0.0
//
//  Created for HelloHabit-inspired design system
//

import SwiftUI

/// Color palette and gradient system for HelloHabit-inspired design
struct ColorPalette {
    
    // MARK: - Category Gradient Colors
    
    /// Personal Development: Purple gradient
    static let personalDevelopmentGradient = Gradient(colors: [
        Color(hex: 0xB57FFF), // #B57FFF
        Color(hex: 0x9966E6)  // #9966E6
    ])
    
    /// Fitness: Green gradient
    static let fitnessGradient = Gradient(colors: [
        Color(hex: 0x4CAF50), // #4CAF50
        Color(hex: 0x388E3C)  // #388E3C
    ])
    
    /// Learning: Orange gradient
    static let learningGradient = Gradient(colors: [
        Color(hex: 0xFF9800), // #FF9800
        Color(hex: 0xE68900)  // #E68900
    ])
    
    /// Health: Teal gradient
    static let healthGradient = Gradient(colors: [
        Color(hex: 0x40C4C4), // #40C4C4
        Color(hex: 0x2FA6A6)  // #2FA6A6
    ])
    
    /// Mindfulness: Blue gradient
    static let mindfulnessGradient = Gradient(colors: [
        Color(hex: 0x4D99FF), // #4D99FF
        Color(hex: 0x3377DD)  // #3377DD
    ])
    
    /// Creative: Pink gradient
    static let creativeGradient = Gradient(colors: [
        Color(hex: 0xE91E63), // #E91E63
        Color(hex: 0xC2185B)  // #C2185B
    ])
    
    /// Nutrition: Red gradient
    static let nutritionGradient = Gradient(colors: [
        Color(hex: 0xFF5252), // #FF5252
        Color(hex: 0xDD3333)  // #DD3333
    ])
    
    /// Hydration: Light Blue gradient
    static let hydrationGradient = Gradient(colors: [
        Color(hex: 0x42A5F5), // #42A5F5
        Color(hex: 0x1E88E5)  // #1E88E5
    ])
    
    /// Professional Growth: Orange gradient (using Learning colors as placeholder)
    static let professionalGrowthGradient = Gradient(colors: [
        Color(hex: 0xFF9800),
        Color(hex: 0xE68900)
    ])
    
    // MARK: - Get Gradient for Category
    
    /// Returns the appropriate gradient for a category name
    static func gradient(for categoryName: String) -> Gradient {
        switch categoryName.lowercased() {
        case "personal development":
            return personalDevelopmentGradient
        case "fitness":
            return fitnessGradient
        case "learning":
            return learningGradient
        case "health":
            return healthGradient
        case "mindfulness":
            return mindfulnessGradient
        case "creative", "creative skills":
            return creativeGradient
        case "nutrition":
            return nutritionGradient
        case "hydration":
            return hydrationGradient
        case "professional growth":
            return professionalGrowthGradient
        default:
            // Default to purple gradient for unknown categories
            return personalDevelopmentGradient
        }
    }
    
    /// Returns a LinearGradient for use in views
    static func linearGradient(for categoryName: String, startPoint: UnitPoint = .topLeading, endPoint: UnitPoint = .bottomTrailing) -> LinearGradient {
        LinearGradient(
            gradient: gradient(for: categoryName),
            startPoint: startPoint,
            endPoint: endPoint
        )
    }
    
    // MARK: - Get Base Color for Category (for icons, text, etc.)
    
    /// Returns the primary (darker) color from the gradient for a category
    static func primaryColor(for categoryName: String) -> Color {
        let gradient = gradient(for: categoryName)
        return gradient.stops.last?.color ?? gradient.stops.first?.color ?? .purple
    }
    
    /// Returns the secondary (lighter) color from the gradient for a category
    static func secondaryColor(for categoryName: String) -> Color {
        let gradient = gradient(for: categoryName)
        return gradient.stops.first?.color ?? .purple
    }
    
    // MARK: - Completion Level Colors
    
    /// Returns color based on completion level with category gradient
    /// - Parameters:
    ///   - level: Completion level (none, partial, medium, full)
    ///   - categoryColor: Base color from category gradient
    /// - Returns: Color adjusted for completion level
    static func color(for level: CompletionLevel, baseColor: Color) -> Color {
        switch level {
        case .none:
            return Color.gray.opacity(0.2)
        case .partial:
            // 30% saturation - light color
            return baseColor.opacity(0.3)
        case .full:
            // 100% saturation - full color
            return baseColor
        }
    }
    
    /// Returns color intensity based on completion level (for heatmaps)
    /// - Parameters:
    ///   - level: Completion level
    ///   - categoryColor: Base color from category gradient
    /// - Returns: Color with appropriate intensity
    static func intensityColor(for level: CompletionLevel, baseColor: Color) -> Color {
        switch level {
        case .none:
            return Color.gray.opacity(0.2)
        case .partial:
            // Light color for partial completion
            return baseColor.opacity(0.5)
        case .full:
            // Dark/saturated color for full completion
            return baseColor
        }
    }
}

// MARK: - Color Extension for Hex Support

extension Color {
    /// Initialize Color from hex value
    /// - Parameter hex: Hex color value (e.g., 0xFF0000 for red)
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }
}

// MARK: - Gradient Extension

extension Gradient {
    /// Access gradient stops
    var stops: [Gradient.Stop] {
        // Convert colors to stops (even distribution)
        let step = 1.0 / Double(max(colors.count - 1, 1))
        return colors.enumerated().map { index, color in
            Gradient.Stop(color: color, location: Double(index) * step)
        }
    }
}

