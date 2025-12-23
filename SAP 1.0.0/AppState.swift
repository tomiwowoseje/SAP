//
//  AppState.swift
//  SAP 1.0.0
//
//  Created by Tomiwo Owoseje  on 22/12/2025.
//

import Foundation
import SwiftUI

// Shared app state for managing skills and progress
@Observable
class AppState {
    // MARK: - Storage keys
    private let skillsKey = "sap.skills"
    private let completionsKey = "sap.dailyCompletions"
    private let customCategoriesKey = "sap.customCategories"
    private let completedIdsKey = "sap.completedTaskIds"
    
    // MARK: - Persisted state
    var skills: [Skill] = [
        Skill(name: "Coding", category: .learning, frequency: .daily, taskDescription: "Practice coding for 30 minutes"),
        Skill(name: "Reading", category: .personalDevelopment, frequency: .daily, taskDescription: "Read a chapter of a book"),
        Skill(name: "Workout", category: .fitness, frequency: .daily, taskDescription: "Do a 20-minute workout"),
        Skill(name: "Guitar Practice", category: .creativeSkills, frequency: .daily, taskDescription: "Practice guitar chords"),
        Skill(name: "Language Learning", category: .learning, frequency: .daily, taskDescription: "Learn 10 new words")
    ] {
        didSet { saveSkills() }
    }
    
    // Track daily completions for progress
    var dailyCompletions: [DailyCompletion] = [] {
        didSet { saveDailyCompletions() }
    }
    
    // Custom categories
    var customCategories: [SkillCategory] = [] {
        didSet { saveCustomCategories() }
    }
    
    // Get all categories (predefined + custom)
    var allCategories: [SkillCategory] {
        SkillCategory.predefinedCategories + customCategories
    }
    
    // MARK: - Active / archived skills (B-007)
    var activeSkills: [Skill] {
        skills.filter { $0.isActive() }
    }
    
    var archivedSkills: [Skill] {
        skills.filter { $0.isArchived }
    }
    
    // MARK: - Init / persistence
    init() {
        loadState()
    }
    
    private func loadState() {
        let defaults = UserDefaults.standard
        let decoder = JSONDecoder()
        
        if let data = defaults.data(forKey: skillsKey),
           let decoded = try? decoder.decode([Skill].self, from: data) {
            skills = decoded
        }
        
        if let data = defaults.data(forKey: completionsKey),
           let decoded = try? decoder.decode([DailyCompletion].self, from: data) {
            dailyCompletions = decoded
        }
        
        if let data = defaults.data(forKey: customCategoriesKey),
           let decoded = try? decoder.decode([SkillCategory].self, from: data) {
            customCategories = decoded
        }
        
        if let data = defaults.data(forKey: completedIdsKey),
           let decoded = try? JSONDecoder().decode([UUID].self, from: data) {
            completedTaskIds = Set(decoded)
        } else {
            // Reconstruct today's completed IDs from daily completions if available
            let today = Calendar.current.startOfDay(for: Date())
            let todays = dailyCompletions.filter { Calendar.current.isDate($0.date, inSameDayAs: today) && $0.isCompleted }
            completedTaskIds = Set(todays.map { $0.skillId })
        }
    }
    
    private func saveSkills() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(skills) {
            UserDefaults.standard.set(data, forKey: skillsKey)
        }
    }
    
    private func saveDailyCompletions() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(dailyCompletions) {
            UserDefaults.standard.set(data, forKey: completionsKey)
        }
    }
    
    private func saveCustomCategories() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(customCategories) {
            UserDefaults.standard.set(data, forKey: customCategoriesKey)
        }
    }
    
    private func saveCompletedTaskIds() {
        let encoder = JSONEncoder()
        let array = Array(completedTaskIds)
        if let data = try? encoder.encode(array) {
            UserDefaults.standard.set(data, forKey: completedIdsKey)
        }
    }
    
    // Track completion for today
    var completedTaskIds: Set<UUID> = [] {
        didSet {
            // Save today's completion when changed
            saveTodayCompletions()
            saveCompletedTaskIds()
        }
    }
    
    // Save today's completions
    private func saveTodayCompletions() {
        let today = Calendar.current.startOfDay(for: Date())
        
        // Remove old completions for today for skills that exist
        dailyCompletions.removeAll { completion in
            Calendar.current.isDate(completion.date, inSameDayAs: today) &&
            skills.contains { $0.id == completion.skillId }
        }
        
        // Add completions for all skills for today
        for skill in skills {
            let isCompleted = completedTaskIds.contains(skill.id)
            let completion = DailyCompletion(skillId: skill.id, date: Date(), isCompleted: isCompleted)
            dailyCompletions.append(completion)
        }
    }
    
    // Manual save method to be called when completions change
    func saveCompletions() {
        saveTodayCompletions()
    }
    
    // Get progress for all skills
    func getAllProgress() -> [SkillProgress] {
        skills.map { skill in
            let skillCompletions = dailyCompletions.filter { $0.skillId == skill.id }
            return SkillProgress(skillId: skill.id, skillName: skill.name, completions: skillCompletions)
        }
    }
    
    // Get progress for a specific skill
    func getProgress(for skillId: UUID) -> SkillProgress? {
        guard let skill = skills.first(where: { $0.id == skillId }) else { return nil }
        let skillCompletions = dailyCompletions.filter { $0.skillId == skillId }
        return SkillProgress(skillId: skillId, skillName: skill.name, completions: skillCompletions)
    }
    
    // Add custom category
    func addCustomCategory(_ category: SkillCategory) {
        customCategories.append(category)
    }
    
    // MARK: - Export / Import (B-008)
    struct ExportPayload: Codable {
        let skills: [Skill]
        let dailyCompletions: [DailyCompletion]
        let customCategories: [SkillCategory]
    }
    
    func exportData() -> String? {
        let payload = ExportPayload(
            skills: skills,
            dailyCompletions: dailyCompletions,
            customCategories: customCategories
        )
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(payload) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    func importData(from json: String) throws {
        let decoder = JSONDecoder()
        guard let data = json.data(using: .utf8) else {
            throw NSError(domain: "AppState", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid text encoding"])
        }
        
        let payload = try decoder.decode(ExportPayload.self, from: data)
        
        // Replace current state with imported data
        skills = payload.skills
        dailyCompletions = payload.dailyCompletions
        customCategories = payload.customCategories
        
        // Rebuild today's completed IDs from imported completions
        let today = Calendar.current.startOfDay(for: Date())
        let todays = dailyCompletions.filter { Calendar.current.isDate($0.date, inSameDayAs: today) && $0.isCompleted }
        completedTaskIds = Set(todays.map { $0.skillId })
    }
}

