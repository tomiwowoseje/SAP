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
    
    // Calculate streak metrics (B-005 related)
    private var streakMetrics: (currentStreak: Int, tasksDone: Int, mastered: Int, completionPercentage: Double) {
        let allProgress = appState.getAllProgress()
        
        // Get the highest current streak from all skills
        let currentStreak = allProgress.map { $0.currentStreak }.max() ?? 0
        
        // Total tasks done (today's completed tasks)
        let tasksDone = appState.completedTaskIds.count
        
        // Skills with high completion percentage (mastered)
        let mastered = allProgress.filter { $0.completionPercentage >= 80 }.count
        
        // Overall completion percentage (total completed vs total skills)
        let totalSkills = appState.skills.count
        let completionPercentage = totalSkills > 0 ? (Double(tasksDone) / Double(totalSkills)) * 100 : 0
        
        return (currentStreak, tasksDone, mastered, completionPercentage)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Top bar with logo and user info
                    topBar
                    
                    // Header section with greeting
                    headerSection
                    
                    // Search bar
                    searchBar
                    
                    // Today's Tasks Section
                    todaysTasksSection
                    
                    // Your Streaks Section (using B-005 metrics)
                    streaksSection()
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
    
    // Top bar with logo and user icon
    private var topBar: some View {
        HStack {
            // Logo
            HStack(spacing: 8) {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.green)
                    .font(.title3)
                Text("SkillTrack")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Spacer()
            
            // Notification and user icons
            HStack(spacing: 16) {
                Button(action: {}) {
                    Image(systemName: "bell")
                        .font(.title3)
                }
                
                Button(action: {}) {
                    Circle()
                        .fill(Color.blue.opacity(0.3))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Text("U")
                                .font(.headline)
                                .foregroundColor(.blue)
                        )
                }
            }
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
    
    // Search bar
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            Text("Search skills...")
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    // Today's Tasks Section
    private var todaysTasksSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today's Tasks")
                .font(.title2)
                .fontWeight(.bold)
            
            if appState.activeSkills.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "checklist")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    Text("No tasks for today")
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
                    ForEach(appState.activeSkills) { skill in
                        TaskCardView(
                            task: Task(
                                name: skill.taskDescription,
                                skillName: skill.name,
                                isCompleted: appState.completedTaskIds.contains(skill.id),
                                skillId: skill.id,
                                category: skill.category
                            ),
                            onToggle: {
                                toggleTaskCompletion(for: skill.id)
                            },
                            onEdit: {
                                editSkill(withId: skill.id)
                            },
                            onDelete: {
                                deleteSkill(withId: skill.id)
                            }
                        )
                    }
                }
            }
        }
    }
    
    // Your Streaks Section
    private func streaksSection() -> some View {
        let metrics = streakMetrics
        
        return VStack(alignment: .leading, spacing: 16) {
            Text("Your Streaks")
                .font(.title2)
                .fontWeight(.bold)
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                StreakCardView(
                    icon: "flame.fill",
                    iconColor: .orange,
                    value: "\(metrics.currentStreak)",
                    label: "Day Streak"
                )
                
                StreakCardView(
                    icon: "checkmark.circle.fill",
                    iconColor: .green,
                    value: "\(metrics.tasksDone)",
                    label: "Tasks Done"
                )
                
                StreakCardView(
                    icon: "trophy.fill",
                    iconColor: .purple,
                    value: "\(metrics.mastered)",
                    label: "Mastered"
                )
                
                StreakCardView(
                    icon: "star.fill",
                    iconColor: .pink,
                    value: String(format: "%.0f%%", metrics.completionPercentage),
                    label: "Completion"
                )
            }
        }
    }
    
    // Task completion mechanism
    private func toggleTaskCompletion(for skillId: UUID) {
        if appState.completedTaskIds.contains(skillId) {
            appState.completedTaskIds.remove(skillId)
        } else {
            appState.completedTaskIds.insert(skillId)
        }
        // Ensure completions are saved
        appState.saveCompletions()
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

// Task Card View matching design
struct TaskCardView: View {
    let task: Task
    let onToggle: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Category icon (colored square)
            RoundedRectangle(cornerRadius: 8)
                .fill(task.category.color.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: task.category.icon)
                        .foregroundColor(task.category.color)
                        .font(.system(size: 20))
                )
            
            // Task info
            VStack(alignment: .leading, spacing: 6) {
                Text(task.name)
                    .font(.body)
                    .fontWeight(.medium)
                    .strikethrough(task.isCompleted)
                    .foregroundColor(task.isCompleted ? .secondary : .primary)
                
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
                            .fill(task.isCompleted ? Color.green : task.category.color)
                            .frame(width: task.isCompleted ? geometry.size.width : 0, height: 4)
                            .cornerRadius(2)
                            .animation(.linear, value: task.isCompleted)
                    }
                }
                .frame(height: 4)
            }
            
            Spacer()
            
            // Completion indicator and checkbox
            VStack(spacing: 4) {
                Text(task.isCompleted ? "1/1" : "0/1")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Button(action: {
                    onToggle()
                }) {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundColor(task.isCompleted ? .green : .gray)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        .contextMenu {
            Button(action: onEdit) {
                Label("Edit", systemImage: "pencil")
            }
            
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

// Streak Card View
struct StreakCardView: View {
    let icon: String
    let iconColor: Color
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(iconColor)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    ContentView()
}
