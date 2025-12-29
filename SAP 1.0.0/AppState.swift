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
    private let morningRoutineKey = "sap.morningRoutineCompletions"
    private let memorableMomentsKey = "sap.memorableMoments"
    private let rolledOverTasksKey = "sap.rolledOverTasks"
    
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
    
    // Morning routine completions [habitId_date: CompletionLevel]
    var morningRoutineCompletions: [String: CompletionLevel] = [:] {
        didSet { saveMorningRoutineCompletions() }
    }
    
    // Memorable moments
    var memorableMoments: [MemorableMoment] = [] {
        didSet { saveMemorableMoments() }
    }
    
    // Rolled over tasks [skillId: Date] - tasks that need to be shown on next day
    var rolledOverTasks: [UUID: Date] = [:] {
        didSet { saveRolledOverTasks() }
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
        
        if let data = defaults.data(forKey: morningRoutineKey),
           let decoded = try? JSONDecoder().decode([String: CompletionLevel].self, from: data) {
            morningRoutineCompletions = decoded
        }
        
        if let data = defaults.data(forKey: memorableMomentsKey),
           let decoded = try? JSONDecoder().decode([MemorableMoment].self, from: data) {
            memorableMoments = decoded
        }
        
        if let data = defaults.data(forKey: rolledOverTasksKey),
           let decoded = try? JSONDecoder().decode([String: Date].self, from: data) {
            // Convert [String: Date] to [UUID: Date]
            rolledOverTasks = decoded.compactMapKeys { UUID(uuidString: $0) }
        }
        
        // Process rolled over tasks on app start
        processRolledOverTasks()
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
    
    func saveMorningRoutineCompletions() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(morningRoutineCompletions) {
            UserDefaults.standard.set(data, forKey: morningRoutineKey)
        }
    }
    
    private func saveMemorableMoments() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(memorableMoments) {
            UserDefaults.standard.set(data, forKey: memorableMomentsKey)
        }
    }
    
    private func saveRolledOverTasks() {
        let encoder = JSONEncoder()
        // Convert [UUID: Date] to [String: Date] for encoding
        let stringDict = rolledOverTasks.mapKeys { $0.uuidString }
        if let data = try? encoder.encode(stringDict) {
            UserDefaults.standard.set(data, forKey: rolledOverTasksKey)
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
    
    // Save today's completions with partial completion support
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
            // Get completion level from existing completion or default
            let existingCompletion = dailyCompletions.first { completion in
                completion.skillId == skill.id && Calendar.current.isDate(completion.date, inSameDayAs: today)
            }
            let completionLevel = existingCompletion?.completionLevel ?? (isCompleted ? .full : .none)
            
            let completion = DailyCompletion(
                skillId: skill.id,
                date: Date(),
                isCompleted: isCompleted,
                completionLevel: completionLevel
            )
            dailyCompletions.append(completion)
        }
    }
    
    // Process rolled over tasks - move incomplete tasks from previous day to today
    private func processRolledOverTasks() {
        let today = Calendar.current.startOfDay(for: Date())
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today) ?? today
        
        // Check for tasks that were rolled over from yesterday
        for (skillId, rolloverDate) in rolledOverTasks {
            if Calendar.current.isDate(rolloverDate, inSameDayAs: yesterday) {
                // Task was rolled over from yesterday, ensure it's visible today
                // The task will appear in the active skills list
                rolledOverTasks[skillId] = today
            }
        }
        
        // Clean up old rollovers (older than yesterday)
        rolledOverTasks = rolledOverTasks.filter { _, date in
            date >= yesterday
        }
        
        saveRolledOverTasks()
    }
    
    // Roll over a task to the next day
    func rolloverTask(skillId: UUID) {
        let today = Calendar.current.startOfDay(for: Date())
        rolledOverTasks[skillId] = today
    }
    
    // Check if a task should be shown (including rolled over tasks)
    func shouldShowTask(skillId: UUID, for date: Date = Date()) -> Bool {
        let targetDate = Calendar.current.startOfDay(for: date)
        
        guard let skill = skills.first(where: { $0.id == skillId }) else { return false }
        
        // If it's a rolled over task, show it
        if let rolloverDate = rolledOverTasks[skillId],
           Calendar.current.isDate(rolloverDate, inSameDayAs: targetDate) {
            return true
        }
        
        // Otherwise, check if skill is active for this date
        return skill.isActive(on: targetDate)
    }
    
    // Update completion level for a skill
    func updateCompletionLevel(skillId: UUID, level: CompletionLevel, for date: Date = Date()) {
        let targetDate = Calendar.current.startOfDay(for: date)
        let today = Calendar.current.startOfDay(for: Date())
        
        // Update or create daily completion
        if let index = dailyCompletions.firstIndex(where: { completion in
            completion.skillId == skillId && Calendar.current.isDate(completion.date, inSameDayAs: targetDate)
        }) {
            dailyCompletions[index].completionLevel = level
            dailyCompletions[index].isCompleted = (level == .full)
        } else {
            let completion = DailyCompletion(
                skillId: skillId,
                date: targetDate,
                isCompleted: (level == .full),
                completionLevel: level
            )
            dailyCompletions.append(completion)
        }
        
        // Update completedTaskIds only for today
        if Calendar.current.isDate(targetDate, inSameDayAs: today) {
            if level == .full {
                completedTaskIds.insert(skillId)
            } else {
                completedTaskIds.remove(skillId)
            }
        }
        
        saveDailyCompletions()
    }
    
    // Add memorable moment
    func addMemorableMoment(_ moment: MemorableMoment) {
        memorableMoments.append(moment)
    }
    
    // Get memorable moments for a date range
    func getMemorableMoments(from startDate: Date, to endDate: Date) -> [MemorableMoment] {
        return memorableMoments.filter { moment in
            moment.date >= startDate && moment.date <= endDate
        }.sorted { $0.date > $1.date }
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
        let morningRoutineCompletions: [String: CompletionLevel]
        let memorableMoments: [MemorableMoment]
        let rolledOverTasks: [String: Date]
    }
    
    func exportData() -> String? {
        let stringDict = rolledOverTasks.mapKeys { $0.uuidString }
        let payload = ExportPayload(
            skills: skills,
            dailyCompletions: dailyCompletions,
            customCategories: customCategories,
            morningRoutineCompletions: morningRoutineCompletions,
            memorableMoments: memorableMoments,
            rolledOverTasks: stringDict
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
        morningRoutineCompletions = payload.morningRoutineCompletions
        memorableMoments = payload.memorableMoments
        
        // Convert [String: Date] back to [UUID: Date]
        rolledOverTasks = payload.rolledOverTasks.compactMapKeys { UUID(uuidString: $0) }
        
        // Rebuild today's completed IDs from imported completions
        let today = Calendar.current.startOfDay(for: Date())
        let todays = dailyCompletions.filter { Calendar.current.isDate($0.date, inSameDayAs: today) && $0.isCompleted }
        completedTaskIds = Set(todays.map { $0.skillId })
    }
}

// Helper extension for Dictionary
extension Dictionary {
    func mapKeys<T: Hashable>(_ transform: (Key) throws -> T) rethrows -> [T: Value] {
        var result: [T: Value] = [:]
        for (key, value) in self {
            result[try transform(key)] = value
        }
        return result
    }
    
    func compactMapKeys<T: Hashable>(_ transform: (Key) throws -> T?) rethrows -> [T: Value] {
        var result: [T: Value] = [:]
        for (key, value) in self {
            if let newKey = try transform(key) {
                result[newKey] = value
            }
        }
        return result
    }
}

