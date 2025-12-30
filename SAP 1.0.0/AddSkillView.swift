//
//  AddSkillView.swift
//  SAP 1.0.0
//
//  Created by Tomiwo Owoseje  on 22/12/2025.
//

import SwiftUI

struct AddSkillView: View {
    @Environment(\.dismiss) var dismiss
    
    // For editing
    var editingSkill: Skill?
    var appState: AppState
    
    @State private var skillName: String = ""
    @State private var taskDescription: String = ""
    @State private var selectedCategory: SkillCategory = .personalDevelopment
    @State private var selectedFrequency: SkillFrequency = .daily
    @State private var timeFrameType: TimeFrameType = .openEnded
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
    @State private var dailyGoal: String = ""
    @State private var weeklyGoal: String = ""
    
    @State private var errorMessage: String = ""
    @State private var showError: Bool = false
    
    var onSave: (Skill) -> Void
    
    enum TimeFrameType: String, CaseIterable {
        case fixed = "Fixed Duration"
        case recurring = "Recurring"
        case openEnded = "Open-ended"
    }
    
    init(appState: AppState, editingSkill: Skill? = nil, onSave: @escaping (Skill) -> Void) {
        self.appState = appState
        self.editingSkill = editingSkill
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Skill Information")) {
                    TextField("Skill Name", text: $skillName)
                        .textInputAutocapitalization(.words)
                    
                    TextField("Task Description", text: $taskDescription, axis: .vertical)
                        .lineLimit(3...5)
                        .textInputAutocapitalization(.sentences)
                        .placeholder(when: taskDescription.isEmpty) {
                            Text("e.g., Practice for 30 minutes")
                                .foregroundColor(.secondary)
                        }
                }
                
                // B-003: Frequency Options
                Section(header: Text("Frequency")) {
                    Picker("Frequency", selection: $selectedFrequency) {
                        ForEach(SkillFrequency.allCases, id: \.self) { frequency in
                            Text(frequency.displayName).tag(frequency)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // B-003: Time Frame Setting
                Section(header: Text("Time Frame")) {
                    Picker("Time Frame Type", selection: $timeFrameType) {
                        ForEach(TimeFrameType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    if timeFrameType == .fixed {
                        DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                        DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                    } else if timeFrameType == .recurring {
                        // Recurring uses the frequency picker above
                        Text("Uses frequency setting above")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // B-003: Tracking Metrics
                Section(header: Text("Tracking Metrics")) {
                    TextField("Daily Goal (optional)", text: $dailyGoal)
                        .keyboardType(.default)
                    
                    TextField("Weekly Goal (optional)", text: $weeklyGoal)
                        .keyboardType(.default)
                }
                
                if showError {
                    Section {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text(errorMessage)
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
            .navigationTitle(editingSkill == nil ? "Add Skill" : "Edit Skill")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if let skill = editingSkill {
                    loadSkillData(skill)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveSkill()
                    }
                    .disabled(!isFormValid)
                }
            }
        }
    }
    
    private func loadSkillData(_ skill: Skill) {
        skillName = skill.name
        taskDescription = skill.taskDescription
        selectedCategory = skill.category
        selectedFrequency = skill.frequency
        startDate = skill.startDate
        endDate = skill.endDate ?? Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
        dailyGoal = skill.trackingMetrics.dailyGoal
        weeklyGoal = skill.trackingMetrics.weeklyGoal
        
        switch skill.timeFrame {
        case .fixed:
            timeFrameType = .fixed
        case .recurring:
            timeFrameType = .recurring
        case .openEnded:
            timeFrameType = .openEnded
        }
    }
    
    private var isFormValid: Bool {
        !skillName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !taskDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func saveSkill() {
        let trimmedSkillName = skillName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedTaskDescription = taskDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedSkillName.isEmpty else {
            showErrorMessage("Skill name cannot be empty")
            return
        }
        
        guard !trimmedTaskDescription.isEmpty else {
            showErrorMessage("Task description cannot be empty")
            return
        }
        
        // Determine time frame
        let timeFrame: SkillTimeFrame
        switch timeFrameType {
        case .fixed:
            timeFrame = .fixed(startDate: startDate, endDate: endDate)
        case .recurring:
            timeFrame = .recurring(frequency: selectedFrequency)
        case .openEnded:
            timeFrame = .openEnded
        }
        
        // Create tracking metrics
        let metrics = TrackingMetrics(
            dailyGoal: dailyGoal.trimmingCharacters(in: .whitespacesAndNewlines),
            weeklyGoal: weeklyGoal.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        let skillId = editingSkill?.id ?? UUID()
        let newSkill = Skill(
            id: skillId,
            name: trimmedSkillName,
            category: selectedCategory,
            frequency: selectedFrequency,
            taskDescription: trimmedTaskDescription,
            timeFrame: timeFrame,
            trackingMetrics: metrics,
            startDate: startDate,
            endDate: timeFrameType == .fixed ? endDate : nil
        )
        
        onSave(newSkill)
        dismiss()
    }
    
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
}

// Helper extension for placeholder text in TextField
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

#Preview {
    let appState = AppState()
    return AddSkillView(appState: appState) { skill in
        print("Added skill: \(skill.name)")
    }
}
