//
//  ContentView.swift
//  SAP 1.0.0
//
//  Created by Tomiwo Owoseje  on 22/12/2025.
//

import SwiftUI

struct HomeView: View {
    @Bindable var appState: AppState
    
    @State private var showAddSkill = false
    @State private var skillToEdit: Skill?
    @State private var selectedDate: Date = Date()
    
    // B-001: Time-based greeting
    private var timeBasedGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            return "Good Morning"
        case 12..<18:
            return "Good Afternoon"
        default:
            return "Good Evening"
        }
    }
    
    // B-006: Motivational message based on time of day
    private var motivationalMessage: String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 5..<12:
            return "Small steps this morning will add up to big wins."
        case 12..<18:
            return "Keep going—every focused session moves you forward."
        default:
            return "Great time to reflect and invest a little more in your skills."
        }
    }
    
    // Generate tasks from skills for today, grouped by category
    private var tasksByCategory: [SkillCategory: [Task]] {
        let tasks = appState.skills.map { skill in
            Task(
                name: skill.taskDescription,
                skillName: skill.name,
                isCompleted: appState.completedTaskIds.contains(skill.id),
                skillId: skill.id,
                category: skill.category
            )
        }
        
        return Dictionary(grouping: tasks) { $0.category }
    }
    
    // Get tasks for selected date (including rolled over tasks)
    private var tasksForSelectedDate: [Task] {
        let targetDate = Calendar.current.startOfDay(for: selectedDate)
        let isToday = Calendar.current.isDate(selectedDate, inSameDayAs: Date())
        
        return appState.skills.compactMap { skill in
            // Check if task should be shown (active or rolled over)
            let shouldShow = isToday ? 
                (appState.activeSkills.contains { $0.id == skill.id } || appState.rolledOverTasks[skill.id] != nil) :
                skill.isActive(on: targetDate)
            
            guard shouldShow else { return nil }
            
            // Get completion level for this date
            let completion = appState.dailyCompletions.first { completion in
                completion.skillId == skill.id && Calendar.current.isDate(completion.date, inSameDayAs: targetDate)
            }
            
            let isCompleted = completion?.isCompleted ?? false
            let completionLevel = completion?.completionLevel ?? .none
            let isRolledOver = appState.rolledOverTasks[skill.id] != nil
            
            return Task(
                name: skill.taskDescription,
                skillName: skill.name,
                isCompleted: isCompleted,
                completionLevel: completionLevel,
                skillId: skill.id,
                category: skill.category,
                canRollover: skill.allowsRollover,
                rolledOverFrom: isRolledOver ? appState.rolledOverTasks[skill.id] : nil
            )
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Top bar with logo
                    topBar
                    
                    // Header section with greeting
                    headerSection
                    
                    // Interactive Week Calendar
                    InteractiveCalendarView(selectedDate: $selectedDate)
                    
                    // Morning Routine Section
                    MorningRoutineView(appState: appState)
                    
                    // Tasks Section for selected date
                    tasksSection
                }
                .padding(.horizontal)
                .padding(.bottom, 100) // Space for bottom navigation
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddSkill = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showAddSkill) {
                AddSkillView(appState: appState) { newSkill in
                    addSkill(newSkill)
                }
            }
            .sheet(item: $skillToEdit) { skill in
                AddSkillView(appState: appState, editingSkill: skill) { updatedSkill in
                    updateSkill(updatedSkill)
                }
            }
        }
    }
    
    // Top bar with logo (removed login and notifications buttons)
    private var topBar: some View {
        HStack {
            // Logo
            HStack(spacing: 8) {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.9))
                    .font(.title3)
                Text("SkillTrack")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Spacer()
        }
        .padding(.top)
    }
    
    // Header section with greeting and question
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(timeBasedGreeting)
                .font(.system(size: 32, weight: .bold))
            
            Text(motivationalMessage)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // Tasks Section for selected date
    private var tasksSection: some View {
        let calendar = Calendar.current
        let isToday = calendar.isDate(selectedDate, inSameDayAs: Date())
        let sectionTitle = isToday ? "Today's Tasks" : dateFormatter.string(from: selectedDate)
        
        return VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(sectionTitle)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                // Quick add button
                Button(action: {
                    showAddSkill = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.9))
                }
            }
            
            if tasksForSelectedDate.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "checklist")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    Text("No tasks for this day")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Add a skill to get started")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                VStack(spacing: 12) {
                    ForEach(tasksForSelectedDate) { task in
                        TaskCardView(
                            task: task,
                            onToggle: {
                                toggleTaskCompletion(for: task.skillId)
                            },
                            onPartialComplete: {
                                // No longer used - same as toggle
                                toggleTaskCompletion(for: task.skillId)
                            },
                            onRollover: {
                                rolloverTask(task.skillId)
                            },
                            onEdit: {
                                editSkill(withId: task.skillId)
                            },
                            onDelete: {
                                deleteSkill(withId: task.skillId)
                            }
                        )
                    }
                }
            }
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
    
    // Task completion mechanism - simple toggle between done and not done
    private func toggleTaskCompletion(for skillId: UUID) {
        let currentLevel = appState.dailyCompletions.first { completion in
            completion.skillId == skillId && Calendar.current.isDate(completion.date, inSameDayAs: selectedDate)
        }?.completionLevel ?? .none
        
        // Simple toggle: none <-> full (no partial)
        let newLevel: CompletionLevel = currentLevel == .full ? .none : .full
        appState.updateCompletionLevel(skillId: skillId, level: newLevel, for: selectedDate)
    }
    
    // Toggle partial completion (no longer used, kept for compatibility)
    private func togglePartialCompletion(for skillId: UUID) {
        // Same as toggle - no partial completion
        toggleTaskCompletion(for: skillId)
    }
    
    // Rollover task to next day
    private func rolloverTask(_ skillId: UUID) {
        appState.rolloverTask(skillId: skillId)
    }
    
    // B-003: Add new skill
    private func addSkill(_ skill: Skill) {
        appState.skills.append(skill)
    }
    
    // B-002: Delete skill
    private func deleteSkill(withId id: UUID) {
        appState.skills.removeAll { $0.id == id }
        appState.completedTaskIds.remove(id)
    }
    
    // B-002: Edit skill
    private func editSkill(withId id: UUID) {
        if let skill = appState.skills.first(where: { $0.id == id }) {
            skillToEdit = skill
        }
    }
    
    // B-002: Update skill
    private func updateSkill(_ updatedSkill: Skill) {
        if let index = appState.skills.firstIndex(where: { $0.id == updatedSkill.id }) {
            appState.skills[index] = updatedSkill
        } else {
            // If not found, might be a new skill with same ID, just replace
            appState.skills.append(updatedSkill)
        }
        skillToEdit = nil
    }
}

// Keep ContentView for compatibility
struct ContentView: View {
    var body: some View {
        MainTabView()
    }
}

// Task Card View - simplified with single checkbox
struct TaskCardView: View {
    let task: Task
    let onToggle: () -> Void
    let onPartialComplete: () -> Void
    let onRollover: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    private var isCompleted: Bool {
        task.completionLevel == .full
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Category icon (colored square)
            RoundedRectangle(cornerRadius: 8)
                .fill(task.category.color.opacity(isCompleted ? 0.3 : 0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: task.category.icon)
                        .foregroundColor(isCompleted ? task.category.color : task.category.color.opacity(0.7))
                        .font(.system(size: 20))
                )
            
            // Task info
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(task.name)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(isCompleted ? .secondary : .primary)
                    
                    if task.rolledOverFrom != nil {
                        Image(systemName: "arrow.forward.circle.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                
                Text(task.category.name)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 4)
                            .cornerRadius(2)
                        
                        Rectangle()
                            .fill(isCompleted ? task.category.color : Color.gray.opacity(0.3))
                            .frame(width: isCompleted ? geometry.size.width : 0, height: 4)
                            .cornerRadius(2)
                            .animation(.linear, value: isCompleted)
                    }
                }
                .frame(height: 4)
            }
            
            Spacer()
            
            // Single checkbox - one click to toggle
            Button(action: onToggle) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(isCompleted ? task.category.color : .gray)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isCompleted ? task.category.color.opacity(0.1) : Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isCompleted ? task.category.color.opacity(0.3) : Color.clear, lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        .contextMenu {
            Button(action: onEdit) {
                Label("Edit", systemImage: "pencil")
            }
            
            if task.canRollover {
                Button(action: onRollover) {
                    Label("Rollover to tomorrow", systemImage: "arrow.right.circle")
                }
            }
            
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}


#Preview {
    ContentView()
}
