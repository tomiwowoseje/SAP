//
//  Models.swift
//  SAP 1.0.0
//
//  Created by Tomiwo Owoseje  on 22/12/2025.
//

import Foundation
import SwiftUI

// Completion level enum for partial completion tracking
enum CompletionLevel: String, Codable {
    case none
    case partial
    case full
}

// Skill Category with custom name support
struct SkillCategory: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let icon: String
    let colorName: String // Store color as string for Hashable
    let isCustom: Bool
    
    /// Base color for the category (returns primary color from gradient)
    var color: Color {
        return ColorPalette.primaryColor(for: name)
    }
    
    /// Gradient for the category (HelloHabit-style gradient)
    var gradient: LinearGradient {
        return ColorPalette.linearGradient(for: name)
    }
    
    /// Primary color from gradient (for icons, text, etc.)
    var primaryColor: Color {
        return ColorPalette.primaryColor(for: name)
    }
    
    /// Secondary color from gradient (lighter shade)
    var secondaryColor: Color {
        return ColorPalette.secondaryColor(for: name)
    }
    
    // Predefined categories
    static let personalDevelopment = SkillCategory(
        id: "personalDevelopment",
        name: "Personal Development",
        icon: "person.fill",
        colorName: "blue",
        isCustom: false
    )
    static let fitness = SkillCategory(
        id: "fitness",
        name: "Fitness",
        icon: "figure.run",
        colorName: "red",
        isCustom: false
    )
    static let learning = SkillCategory(
        id: "learning",
        name: "Learning",
        icon: "book.fill",
        colorName: "purple",
        isCustom: false
    )
    static let professionalGrowth = SkillCategory(
        id: "professionalGrowth",
        name: "Professional Growth",
        icon: "briefcase.fill",
        colorName: "orange",
        isCustom: false
    )
    static let health = SkillCategory(
        id: "health",
        name: "Health",
        icon: "heart.fill",
        colorName: "pink",
        isCustom: false
    )
    static let creativeSkills = SkillCategory(
        id: "creativeSkills",
        name: "Creative Skills",
        icon: "paintbrush.fill",
        colorName: "green",
        isCustom: false
    )
    static let mindfulness = SkillCategory(
        id: "mindfulness",
        name: "Mindfulness",
        icon: "leaf.fill",
        colorName: "mint",
        isCustom: false
    )
    static let nutrition = SkillCategory(
        id: "nutrition",
        name: "Nutrition",
        icon: "fork.knife",
        colorName: "red",
        isCustom: false
    )
    static let hydration = SkillCategory(
        id: "hydration",
        name: "Hydration",
        icon: "drop.fill",
        colorName: "cyan",
        isCustom: false
    )
    
    // Predefined categories list (matching HelloHabit requirements)
    static let predefinedCategories: [SkillCategory] = [
        .personalDevelopment,
        .fitness,
        .learning,
        .professionalGrowth,
        .health,
        .creativeSkills,
        .mindfulness,
        .nutrition,
        .hydration
    ]
    
    // Create custom category
    static func custom(name: String, icon: String = "tag.fill", colorName: String = "gray") -> SkillCategory {
        SkillCategory(
            id: UUID().uuidString,
            name: name,
            icon: icon,
            colorName: colorName,
            isCustom: true
        )
    }
}

// Skill frequency enum
enum SkillFrequency: String, CaseIterable, Codable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case openEnded = "Open-ended"
    
    var displayName: String {
        rawValue
    }
}

// Skill Time Frame
enum SkillTimeFrame: Hashable, Codable {
    case fixed(startDate: Date, endDate: Date)
    case recurring(frequency: SkillFrequency)
    case openEnded
    
    var displayName: String {
        switch self {
        case .fixed(let startDate, let endDate):
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
        case .recurring(let frequency):
            return frequency.displayName
        case .openEnded:
            return "No end date"
        }
    }
    
    // Custom Codable conformance for associated values
    private enum CodingKeys: String, CodingKey {
        case type
        case startDate
        case endDate
        case frequency
    }
    
    private enum FrameType: String, Codable {
        case fixed
        case recurring
        case openEnded
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(FrameType.self, forKey: .type)
        
        switch type {
        case .fixed:
            let start = try container.decode(Date.self, forKey: .startDate)
            let end = try container.decode(Date.self, forKey: .endDate)
            self = .fixed(startDate: start, endDate: end)
        case .recurring:
            let frequency = try container.decode(SkillFrequency.self, forKey: .frequency)
            self = .recurring(frequency: frequency)
        case .openEnded:
            self = .openEnded
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .fixed(let start, let end):
            try container.encode(FrameType.fixed, forKey: .type)
            try container.encode(start, forKey: .startDate)
            try container.encode(end, forKey: .endDate)
        case .recurring(let frequency):
            try container.encode(FrameType.recurring, forKey: .type)
            try container.encode(frequency, forKey: .frequency)
        case .openEnded:
            try container.encode(FrameType.openEnded, forKey: .type)
        }
    }
}

// Tracking Metrics
struct TrackingMetrics: Hashable, Codable {
    var dailyGoal: String = ""
    var weeklyGoal: String = ""
}

// Skill model
struct Skill: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var category: SkillCategory
    var frequency: SkillFrequency
    var taskDescription: String
    var timeFrame: SkillTimeFrame
    var trackingMetrics: TrackingMetrics
    var startDate: Date
    var endDate: Date?
    
    init(
        id: UUID = UUID(),
        name: String,
        category: SkillCategory,
        frequency: SkillFrequency = .daily,
        taskDescription: String,
        timeFrame: SkillTimeFrame = .openEnded,
        trackingMetrics: TrackingMetrics = TrackingMetrics(),
        startDate: Date = Date(),
        endDate: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.frequency = frequency
        self.taskDescription = taskDescription
        self.timeFrame = timeFrame
        self.trackingMetrics = trackingMetrics
        self.startDate = startDate
        self.endDate = endDate
    }
    
    // B-007: Helper to determine if a skill is currently active
    func isActive(on date: Date = Date()) -> Bool {
        switch timeFrame {
        case .fixed(let start, let end):
            return date >= start && date <= end
        case .recurring:
            if let endDate {
                return date >= startDate && date <= endDate
            } else {
                return date >= startDate
            }
        case .openEnded:
            if let endDate {
                return date <= endDate
            } else {
                return true
            }
        }
    }
    
    var isArchived: Bool {
        !isActive(on: Date())
    }
    
    // Support for task rollover
    var allowsRollover: Bool = false
}

// Memorable moment for tracking special achievements
struct MemorableMoment: Identifiable, Codable {
    let id: UUID
    let skillId: UUID?
    let date: Date
    let title: String
    let description: String
    let category: MomentCategory
    
    enum MomentCategory: String, Codable {
        case achievement = "Achievement"
        case milestone = "Milestone"
        case breakthrough = "Breakthrough"
        case personal = "Personal"
    }
    
    init(id: UUID = UUID(), skillId: UUID? = nil, date: Date = Date(), title: String, description: String, category: MomentCategory) {
        self.id = id
        self.skillId = skillId
        self.date = date
        self.title = title
        self.description = description
        self.category = category
    }
}

// Weight entry for tracking weight over time
struct WeightEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    let weight: Double // in kg
    
    init(id: UUID = UUID(), date: Date = Date(), weight: Double) {
        self.id = id
        self.date = Calendar.current.startOfDay(for: date)
        self.weight = weight
    }
    
    // Custom Codable to handle id properly
    enum CodingKeys: String, CodingKey {
        case id, date, weight
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        date = try container.decode(Date.self, forKey: .date)
        weight = try container.decode(Double.self, forKey: .weight)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(date, forKey: .date)
        try container.encode(weight, forKey: .weight)
    }
}

// Task model with rollover support
struct Task: Identifiable, Codable {
    let id: UUID
    let name: String
    let skillName: String
    var isCompleted: Bool = false
    var completionLevel: CompletionLevel = .none
    let skillId: UUID
    let category: SkillCategory
    var canRollover: Bool = false // Allow task to rollover to next day
    var rolledOverFrom: Date? // Date this task was rolled over from
    
    init(id: UUID = UUID(), name: String, skillName: String, isCompleted: Bool = false, completionLevel: CompletionLevel = .none, skillId: UUID, category: SkillCategory, canRollover: Bool = false, rolledOverFrom: Date? = nil) {
        self.id = id
        self.name = name
        self.skillName = skillName
        self.isCompleted = isCompleted
        self.completionLevel = completionLevel
        self.skillId = skillId
        self.category = category
        self.canRollover = canRollover
        self.rolledOverFrom = rolledOverFrom
    }
    
    // Custom Codable to handle id properly
    enum CodingKeys: String, CodingKey {
        case id, name, skillName, isCompleted, completionLevel, skillId, category, canRollover, rolledOverFrom
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        skillName = try container.decode(String.self, forKey: .skillName)
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        completionLevel = try container.decode(CompletionLevel.self, forKey: .completionLevel)
        skillId = try container.decode(UUID.self, forKey: .skillId)
        category = try container.decode(SkillCategory.self, forKey: .category)
        canRollover = try container.decode(Bool.self, forKey: .canRollover)
        rolledOverFrom = try container.decodeIfPresent(Date.self, forKey: .rolledOverFrom)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(skillName, forKey: .skillName)
        try container.encode(isCompleted, forKey: .isCompleted)
        try container.encode(completionLevel, forKey: .completionLevel)
        try container.encode(skillId, forKey: .skillId)
        try container.encode(category, forKey: .category)
        try container.encode(canRollover, forKey: .canRollover)
        try container.encodeIfPresent(rolledOverFrom, forKey: .rolledOverFrom)
    }
}

// Daily completion record for progress tracking with partial completion support
struct DailyCompletion: Identifiable, Hashable, Codable {
    let id: UUID
    let skillId: UUID
    let date: Date
    var isCompleted: Bool
    var completionLevel: CompletionLevel // none, partial, full
    
    init(id: UUID = UUID(), skillId: UUID, date: Date, isCompleted: Bool, completionLevel: CompletionLevel = .none) {
        self.id = id
        self.skillId = skillId
        self.date = Calendar.current.startOfDay(for: date)
        self.isCompleted = isCompleted
        self.completionLevel = completionLevel
    }
}

// Progress data for a skill
struct SkillProgress {
    let skillId: UUID
    let skillName: String
    var completions: [DailyCompletion]
    var currentStreak: Int
    var longestStreak: Int
    var completionPercentage: Double
    
    init(skillId: UUID, skillName: String, completions: [DailyCompletion] = []) {
        self.skillId = skillId
        self.skillName = skillName
        self.completions = completions
        self.currentStreak = SkillProgress.calculateCurrentStreak(completions)
        self.longestStreak = SkillProgress.calculateLongestStreak(completions)
        
        let totalDays = completions.count
        let completedDays = completions.filter { $0.isCompleted }.count
        self.completionPercentage = totalDays > 0 ? Double(completedDays) / Double(totalDays) * 100 : 0
    }
    
    static func calculateCurrentStreak(_ completions: [DailyCompletion]) -> Int {
        let sorted = completions.sorted { $0.date > $1.date }
        var streak = 0
        let calendar = Calendar.current
        var expectedDate = calendar.startOfDay(for: Date())
        
        for completion in sorted {
            if calendar.isDate(completion.date, inSameDayAs: expectedDate) {
                if completion.isCompleted {
                    streak += 1
                    expectedDate = calendar.date(byAdding: .day, value: -1, to: expectedDate) ?? expectedDate
                } else {
                    break
                }
            } else if completion.date < expectedDate {
                break
            }
        }
        return streak
    }
    
    static func calculateLongestStreak(_ completions: [DailyCompletion]) -> Int {
        let sorted = completions.sorted { $0.date < $1.date }
        var maxStreak = 0
        var currentStreak = 0
        
        // Handle empty or single-entry completion lists safely
        guard !sorted.isEmpty else { return 0 }
        
        for completion in sorted where completion.isCompleted {
            currentStreak += 1
            maxStreak = max(maxStreak, currentStreak)
        }
        
        // Reset streak if there's a gap.
        // Only run this logic when there are at least two entries to compare;
        // otherwise the range 1..<sorted.count would be invalid and crash.
        if sorted.count > 1 {
            for i in 1..<sorted.count {
                let daysDiff = Calendar.current.dateComponents([.day], from: sorted[i-1].date, to: sorted[i].date).day ?? 0
                if daysDiff > 1 || !sorted[i].isCompleted {
                    currentStreak = sorted[i].isCompleted ? 1 : 0
                }
            }
        }
        
        return maxStreak
    }
}

