//
//  MorningRoutineView.swift
//  SAP 1.0.0
//
//  Created by Tomiwo Owoseje  on 22/12/2025.
//

import SwiftUI
import UIKit

struct MorningRoutineView: View {
    @Bindable var appState: AppState
    @State private var selectedDate: Date = Date()
    @State private var showWeightInput = false
    @State private var weightInput: String = ""
    @State private var selectedWeightHabitId: UUID?
    @State private var habitToEdit: MorningHabit?
    @State private var showEditHabit = false
    @State private var showAddHabit = false
    @State private var showManageHabits = false
    
    // Get the "Track weight" habit ID
    private var trackWeightHabitId: UUID {
        appState.morningHabits.first { $0.name == "Track weight" }?.id ?? UUID()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            HStack {
                Image(systemName: "sunrise.fill")
                    .foregroundColor(.orange)
                    .font(.title3)
                
                Text("Morning Routine")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                // Manage button
                Button(action: {
                    showManageHabits = true
                }) {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.secondary)
                        .font(.title3)
                }
            }
            
            // Habits grid
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                ForEach(appState.morningHabits.sorted(by: { $0.order < $1.order })) { habit in
                    MorningHabitCard(
                        habit: habit,
                        isCompleted: isHabitCompleted(habit.id, for: selectedDate),
                        completionLevel: getCompletionLevel(habit.id, for: selectedDate),
                        currentWeight: habit.id == trackWeightHabitId ? appState.getWeight(for: selectedDate) : nil,
                        onToggle: {
                            if habit.id == trackWeightHabitId {
                                // Show weight input for track weight
                                if let existingWeight = appState.getWeight(for: selectedDate) {
                                    weightInput = String(format: "%.1f", existingWeight)
                                } else {
                                    weightInput = ""
                                }
                                selectedWeightHabitId = habit.id
                                showWeightInput = true
                            } else {
                                toggleHabit(habit.id, for: selectedDate)
                            }
                        },
                        onEdit: {
                            // Long press edit - for weight tracking, open weight input
                            if habit.id == trackWeightHabitId {
                                if let existingWeight = appState.getWeight(for: selectedDate) {
                                    weightInput = String(format: "%.1f", existingWeight)
                                } else {
                                    weightInput = ""
                                }
                                selectedWeightHabitId = habit.id
                                showWeightInput = true
                            } else {
                                // For other habits, open edit sheet
                                habitToEdit = habit
                            }
                        }
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .sheet(isPresented: $showWeightInput) {
            WeightInputView(
                weight: $weightInput,
                date: selectedDate,
                appState: appState,
                onSave: {
                    if let weight = Double(weightInput.replacingOccurrences(of: ",", with: ".")) {
                        appState.addWeightEntry(weight: weight, for: selectedDate)
                        // Mark as completed
                        let key = habitKey(habitId: trackWeightHabitId, date: selectedDate)
                        appState.morningRoutineCompletions[key] = .full
                        appState.saveMorningRoutineCompletions()
                    }
                    showWeightInput = false
                }
            )
        }
        .sheet(item: $habitToEdit) { habit in
            EditMorningHabitView(
                habit: habit,
                appState: appState,
                onSave: { updatedHabit in
                    if let index = appState.morningHabits.firstIndex(where: { $0.id == updatedHabit.id }) {
                        appState.morningHabits[index] = updatedHabit
                    }
                    habitToEdit = nil
                },
                onDelete: {
                    appState.morningHabits.removeAll { $0.id == habit.id }
                    habitToEdit = nil
                }
            )
        }
        .sheet(isPresented: $showAddHabit) {
            EditMorningHabitView(
                habit: nil,
                appState: appState,
                onSave: { newHabit in
                    var habit = newHabit
                    habit.order = appState.morningHabits.count
                    appState.morningHabits.append(habit)
                    showAddHabit = false
                },
                onDelete: nil
            )
        }
        .sheet(isPresented: $showManageHabits) {
            MorningRoutineManageView(appState: appState)
        }
    }
    
    private func isHabitCompleted(_ habitId: UUID, for date: Date) -> Bool {
        let key = habitKey(habitId: habitId, date: date)
        return appState.morningRoutineCompletions[key] == .full
    }
    
    private func getCompletionLevel(_ habitId: UUID, for date: Date) -> CompletionLevel {
        let key = habitKey(habitId: habitId, date: date)
        return appState.morningRoutineCompletions[key] ?? .none
    }
    
    private func toggleHabit(_ habitId: UUID, for date: Date) {
        let key = habitKey(habitId: habitId, date: date)
        let currentLevel = appState.morningRoutineCompletions[key] ?? .none
        
        // Simple toggle: none <-> full (no partial step)
        if currentLevel == .full {
            appState.morningRoutineCompletions[key] = CompletionLevel.none
        } else {
            appState.morningRoutineCompletions[key] = .full
        }
        
        appState.saveMorningRoutineCompletions()
    }
    
    private func habitKey(habitId: UUID, date: Date) -> String {
        let dateString = dateFormatter.string(from: date)
        return "\(habitId.uuidString)_\(dateString)"
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
}

struct MorningHabit: Identifiable, Codable {
    let id: UUID
    var name: String
    var icon: String
    var colorName: String // Store color as string name
    var goal: String // Goal/metric for the habit (e.g., "10 pages", "500ml", "30 min")
    var order: Int // Order for sorting
    
    // Computed property for Color (not Codable)
    var color: Color {
        switch colorName {
        case "purple": return .purple
        case "blue": return .blue
        case "indigo": return .indigo
        case "cyan": return .cyan
        case "green": return .green
        case "orange": return .orange
        case "red": return .red
        case "pink": return .pink
        case "teal": return .teal
        case "mint": return .mint
        case "yellow": return .yellow
        default: return .gray
        }
    }
    
    init(id: UUID = UUID(), name: String, icon: String, color: Color, goal: String = "", order: Int = 0) {
        self.id = id
        self.name = name
        self.icon = icon
        self.goal = goal
        self.order = order
        // Convert Color to string - check all available colors
        if color == .purple { self.colorName = "purple" }
        else if color == .blue { self.colorName = "blue" }
        else if color == .indigo { self.colorName = "indigo" }
        else if color == .cyan { self.colorName = "cyan" }
        else if color == .green { self.colorName = "green" }
        else if color == .orange { self.colorName = "orange" }
        else if color == .red { self.colorName = "red" }
        else if color == .pink { self.colorName = "pink" }
        else if color == .teal { self.colorName = "teal" }
        else if color == .mint { self.colorName = "mint" }
        else if color == .yellow { self.colorName = "yellow" }
        else { self.colorName = "gray" }
    }
}

struct MorningHabitCard: View {
    let habit: MorningHabit
    let isCompleted: Bool
    let completionLevel: CompletionLevel
    let currentWeight: Double?
    let onToggle: () -> Void
    let onEdit: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(habit.color.opacity(completionLevel == .full ? 0.3 : 0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: habit.icon)
                    .font(.title3)
                    .foregroundColor(completionLevel == .full ? habit.color : habit.color.opacity(0.6))
            }
            
            // Habit name
            Text(habit.name)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
                // Show weight if available, otherwise show goal or completion indicator
                if habit.name == "Track weight", let weight = currentWeight {
                    Text(String(format: "%.1f kg", weight))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(habit.color)
                } else if !habit.goal.isEmpty {
                    // Show goal if available
                    Text(habit.goal)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(habit.color.opacity(0.8))
                    
                    // Completion indicator below goal
                    HStack(spacing: 4) {
                        if completionLevel == .full {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(habit.color)
                                .font(.body)
                        } else {
                            Circle()
                                .stroke(habit.color.opacity(0.3), lineWidth: 2)
                                .frame(width: 20, height: 20)
                        }
                    }
                    .padding(.top, 2)
                } else {
                    // Completion indicator - only show Done or Not started (no partial)
                    HStack(spacing: 6) {
                        if completionLevel == .full {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(habit.color)
                                .font(.body)
                            Text("Done")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            Circle()
                                .stroke(habit.color.opacity(0.3), lineWidth: 2)
                                .frame(width: 20, height: 20)
                            Text("Not started")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(completionLevel == .full ? habit.color.opacity(0.1) : Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(completionLevel == .full ? habit.color.opacity(0.3) : Color.clear, lineWidth: 1)
                )
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onToggle()
        }
        .onLongPressGesture(minimumDuration: 0.5) {
            onEdit()
        }
    }
}

// Weight input view
struct WeightInputView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var weight: String
    let date: Date
    @Bindable var appState: AppState
    let onSave: () -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Enter Weight")) {
                    TextField("Weight (kg)", text: $weight)
                        .keyboardType(.decimalPad)
                        .font(.title2)
                        .multilineTextAlignment(.center)
                    
                    Text("Date: \(dateFormatter.string(from: date))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                
                if let existingWeight = appState.getWeight(for: date) {
                    Section(header: Text("Current Weight")) {
                        Text(String(format: "%.1f kg", existingWeight))
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .navigationTitle("Track Weight")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave()
                    }
                    .disabled(weight.isEmpty || Double(weight.replacingOccurrences(of: ",", with: ".")) == nil)
                }
            }
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
}

// Edit Morning Habit View
struct EditMorningHabitView: View {
    @Environment(\.dismiss) var dismiss
    let habit: MorningHabit?
    @Bindable var appState: AppState
    let onSave: (MorningHabit) -> Void
    let onDelete: (() -> Void)?
    
    @State private var habitName: String
    @State private var habitIcon: String
    @State private var selectedColorName: String // Track by name for reliable comparison
    @State private var habitGoal: String
    @State private var searchText: String = ""
    @State private var selectedIconCategory: IconCategory = .health
    
    // Computed property for selected color
    private var selectedColor: Color {
        availableColors.first(where: { $0.name == selectedColorName })?.color ?? .blue
    }
    
    // Available colors - expanded palette
    private let availableColors: [(name: String, color: Color)] = [
        ("purple", .purple),
        ("blue", .blue),
        ("indigo", .indigo),
        ("cyan", .cyan),
        ("green", .green),
        ("orange", .orange),
        ("red", .red),
        ("pink", .pink),
        ("teal", .teal),
        ("mint", .mint),
        ("yellow", .yellow)
    ]
    
    enum IconCategory: String, CaseIterable {
        case health = "Health"
        case fitness = "Fitness"
        case learning = "Learning"
        case lifestyle = "Lifestyle"
        case nature = "Nature"
    }
    
    // Categorized SF Symbols for habits - expanded with more options
    private var iconCategories: [IconCategory: [String]] {
        [
            .health: ["heart.fill", "cross.fill", "bandage.fill", "pills.fill", "stethoscope", "heart.circle.fill", "cross.case.fill"],
            .fitness: ["figure.flexibility", "figure.walk", "figure.run", "dumbbell.fill", "sportscourt.fill", "figure.strengthtraining.traditional", "figure.yoga", "figure.core.training", "figure.dance", "figure.mind.and.body"],
            .learning: ["book.fill", "brain.head.profile", "graduationcap.fill", "pencil", "bookmark.fill", "book.closed.fill", "textbook", "magazine.fill"],
            .lifestyle: ["sunrise.fill", "moon.fill", "drop.fill", "cup.and.saucer.fill", "bed.double.fill", "sun.max.fill", "moon.stars.fill", "cloud.sun.fill"],
            .nature: ["leaf.fill", "flame.fill", "sun.max.fill", "cloud.fill", "drop.fill", "tree.fill", "flower.fill", "sparkles"]
        ]
    }
    
    private var filteredIcons: [String] {
        let categoryIcons = iconCategories[selectedIconCategory] ?? []
        
        if searchText.isEmpty {
            return categoryIcons
        } else {
            return categoryIcons.filter { icon in
                icon.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    init(habit: MorningHabit?, appState: AppState, onSave: @escaping (MorningHabit) -> Void, onDelete: (() -> Void)? = nil) {
        self.habit = habit
        self.appState = appState
        self.onSave = onSave
        self.onDelete = onDelete
        
        if let habit = habit {
            _habitName = State(initialValue: habit.name)
            // Validate icon exists, use fallback if not (handles "figure.flexibility" and other icons)
            let validIcon = UIImage(systemName: habit.icon) != nil ? habit.icon : "star.fill"
            _habitIcon = State(initialValue: validIcon)
            // Use color name for reliable state tracking, with fallback
            let validColorName = habit.colorName.isEmpty ? "blue" : habit.colorName
            _selectedColorName = State(initialValue: validColorName)
            _habitGoal = State(initialValue: habit.goal)
        } else {
            _habitName = State(initialValue: "")
            _habitIcon = State(initialValue: "star.fill")
            _selectedColorName = State(initialValue: "blue") // Default to blue
            _habitGoal = State(initialValue: "")
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Habit Name")) {
                    TextField("Habit name", text: $habitName)
                }
                
                Section(header: Text("Goal/Metric")) {
                    TextField("e.g., 10 pages, 500ml, 30 min", text: $habitGoal)
                        .autocapitalization(.none)
                }
                
                Section(header: Text("Icon")) {
                    // Icon search
                    TextField("Search icons...", text: $searchText)
                        .autocapitalization(.none)
                    
                    // Category picker
                    Picker("Category", selection: $selectedIconCategory) {
                        ForEach(IconCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    // Icon grid - COMPLETELY ISOLATED from color selection state
                    IconSectionView(
                        icons: filteredIcons,
                        selectedIcon: $habitIcon
                    )
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("Color")) {
                    // Color grid with fixed layout to prevent shifting
                    LazyVGrid(columns: [
                        GridItem(.fixed(60), spacing: 16),
                        GridItem(.fixed(60), spacing: 16),
                        GridItem(.fixed(60), spacing: 16),
                        GridItem(.fixed(60), spacing: 16)
                    ], spacing: 16) {
                        ForEach(availableColors, id: \.name) { colorOption in
                            ColorSelectionButton(
                                colorOption: colorOption,
                                isSelected: selectedColorName == colorOption.name,
                                onSelect: {
                                    // Immediate state update with animation
                                    // Use transaction to prevent layout changes
                                    var transaction = Transaction(animation: .easeInOut(duration: 0.2))
                                    transaction.disablesAnimations = false
                                    withTransaction(transaction) {
                                        selectedColorName = colorOption.name
                                    }
                                }
                            )
                            .frame(width: 60, height: 60)
                            .fixedSize()
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle(habit == nil ? "New Habit" : "Edit Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                if let onDelete = onDelete, habit != nil {
                    ToolbarItem(placement: .destructiveAction) {
                        Button("Delete") {
                            onDelete()
                        }
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // Create habit with selected color using color name
                        let color = availableColors.first(where: { $0.name == selectedColorName })?.color ?? .blue
                        let updatedHabit = MorningHabit(
                            id: habit?.id ?? UUID(),
                            name: habitName,
                            icon: habitIcon,
                            color: color,
                            goal: habitGoal,
                            order: habit?.order ?? 0
                        )
                        onSave(updatedHabit)
                    }
                    .disabled(habitName.isEmpty || habitIcon.isEmpty)
                }
            }
        }
    }
}

// Morning Routine Management View
struct MorningRoutineManageView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var appState: AppState
    @State private var habitToEdit: MorningHabit?
    @State private var showEditHabit = false
    @State private var showAddHabit = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(appState.morningHabits.sorted(by: { $0.order < $1.order })) { habit in
                    HStack {
                        // Drag handle
                        Image(systemName: "line.3.horizontal")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        
                        // Habit preview
                        HStack(spacing: 12) {
                            Image(systemName: habit.icon)
                                .foregroundColor(habit.color)
                                .font(.title3)
                                .frame(width: 30)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(habit.name)
                                    .font(.headline)
                                
                                if !habit.goal.isEmpty {
                                    Text(habit.goal)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                        }
                        
                        // Edit button
                        Button(action: {
                            habitToEdit = habit
                            showEditHabit = true
                        }) {
                            Image(systemName: "pencil")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .onMove(perform: moveHabits)
                .onDelete(perform: deleteHabits)
            }
            .navigationTitle("Manage Morning Routine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        showAddHabit = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showEditHabit) {
            if let habit = habitToEdit {
                EditMorningHabitView(
                    habit: habit,
                    appState: appState,
                    onSave: { updatedHabit in
                        if let index = appState.morningHabits.firstIndex(where: { $0.id == updatedHabit.id }) {
                            appState.morningHabits[index] = updatedHabit
                        }
                        showEditHabit = false
                        habitToEdit = nil
                    },
                    onDelete: {
                        appState.morningHabits.removeAll { $0.id == habit.id }
                        showEditHabit = false
                        habitToEdit = nil
                    }
                )
            }
        }
        .sheet(isPresented: $showAddHabit) {
            EditMorningHabitView(
                habit: nil,
                appState: appState,
                onSave: { newHabit in
                    var habit = newHabit
                    habit.order = appState.morningHabits.count
                    appState.morningHabits.append(habit)
                    showAddHabit = false
                },
                onDelete: nil
            )
        }
    }
    
    private func moveHabits(from source: IndexSet, to destination: Int) {
        var sortedHabits = appState.morningHabits.sorted(by: { $0.order < $1.order })
        sortedHabits.move(fromOffsets: source, toOffset: destination)
        
        // Update order values
        for (index, habit) in sortedHabits.enumerated() {
            if let habitIndex = appState.morningHabits.firstIndex(where: { $0.id == habit.id }) {
                appState.morningHabits[habitIndex].order = index
            }
        }
    }
    
    private func deleteHabits(at offsets: IndexSet) {
        var sortedHabits = appState.morningHabits.sorted(by: { $0.order < $1.order })
        sortedHabits.remove(atOffsets: offsets)
        
        // Remove from appState and update orders
        for habit in sortedHabits {
            if let index = appState.morningHabits.firstIndex(where: { $0.id == habit.id }) {
                appState.morningHabits[index].order = sortedHabits.firstIndex(where: { $0.id == habit.id }) ?? 0
            }
        }
        
        // Remove deleted habits
        let sortedIndices = offsets.map { appState.morningHabits.sorted(by: { $0.order < $1.order })[$0].id }
        appState.morningHabits.removeAll { sortedIndices.contains($0.id) }
        
        // Reorder remaining habits
        let remainingHabits = appState.morningHabits.sorted(by: { $0.order < $1.order })
        for (index, habit) in remainingHabits.enumerated() {
            if let habitIndex = appState.morningHabits.firstIndex(where: { $0.id == habit.id }) {
                appState.morningHabits[habitIndex].order = index
            }
        }
    }
}

// Dedicated Color Selection Button Component
// Provides robust, glitch-free color selection with fixed layout
struct ColorSelectionButton: View {
    let colorOption: (name: String, color: Color)
    let isSelected: Bool
    let onSelect: () -> Void
    
    // Fixed dimensions to prevent layout shifts
    private let circleSize: CGFloat = 50
    private let outerRingSize: CGFloat = 56
    private let innerStrokeWidth: CGFloat = 3
    private let outerStrokeWidth: CGFloat = 2
    
    var body: some View {
        Button(action: {
            // Immediate action with haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            
            // Execute selection immediately
            onSelect()
        }) {
            ZStack {
                // Color circle with fixed size
                Circle()
                    .fill(colorOption.color)
                    .frame(width: circleSize, height: circleSize)
                    .overlay(
                        // Selection ring - fixed size, no layout impact
                        Circle()
                            .stroke(isSelected ? Color.white : Color.clear, lineWidth: innerStrokeWidth)
                            .frame(width: circleSize, height: circleSize)
                            .animation(.none, value: isSelected) // Prevent layout animation
                    )
                    .overlay(
                        // Outer selection indicator - fixed size
                        Circle()
                            .stroke(isSelected ? colorOption.color : Color.clear, lineWidth: outerStrokeWidth)
                            .frame(width: outerRingSize, height: outerRingSize)
                            .animation(.none, value: isSelected) // Prevent layout animation
                    )
                    .shadow(color: isSelected ? colorOption.color.opacity(0.5) : Color.clear, radius: 8, x: 0, y: 4)
                    .animation(.none, value: isSelected) // Prevent layout animation
                
                // Checkmark for selected state - fixed position
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        .font(.title3)
                        .frame(width: circleSize, height: circleSize)
                        .transition(.opacity)
                        .animation(.none, value: isSelected) // Prevent layout animation
                }
            }
            .frame(width: circleSize, height: circleSize)
            .fixedSize()
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle())
    }
}

// Icon Section View - COMPLETELY ISOLATED wrapper to prevent parent re-renders
// Uses @State to cache icons and only update when they actually change
struct IconSectionView: View {
    let icons: [String]
    @Binding var selectedIcon: String
    @State private var cachedIcons: [String] = []
    
    var body: some View {
        IconGridSelectionView(
            icons: cachedIcons.isEmpty ? icons : cachedIcons,
            selectedIcon: $selectedIcon,
            onIconSelect: {
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
            }
        )
        .onAppear {
            if cachedIcons != icons {
                cachedIcons = icons
            }
        }
        .onChange(of: icons) { oldValue, newIcons in
            // Only update cached icons when icons actually change
            if cachedIcons != newIcons {
                cachedIcons = newIcons
            }
        }
    }
}

// Icon Grid Selection View - COMPLETELY ISOLATED from color selection
struct IconGridSelectionView: View {
    let icons: [String]
    @Binding var selectedIcon: String
    let onIconSelect: () -> Void
    
    // Use flexible columns with NO spacing - spacing is handled by LazyVGrid
    // This ensures icons fill cells completely and don't rearrange
    private static let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 5)
    
    var body: some View {
        LazyVGrid(columns: Self.columns, spacing: 12) {
            ForEach(icons, id: \.self) { icon in
                IconButtonView(
                    icon: icon,
                    isSelected: selectedIcon == icon,
                    onSelect: {
                        onIconSelect()
                        selectedIcon = icon
                    }
                )
            }
        }
        .frame(maxWidth: .infinity) // Ensure full width to prevent layout shifts
    }
}

// Simple icon button - NO dependencies on external state
// FILLS GRID CELL COMPLETELY to prevent rearrangement
struct IconButtonView: View {
    let icon: String
    let isSelected: Bool
    let onSelect: () -> Void
    
    // Fixed dimensions - constants
    private let buttonSize: CGFloat = 44
    private let strokeWidth: CGFloat = 2
    
    var body: some View {
        Button(action: onSelect) {
            ZStack {
                Circle()
                    .fill(isSelected ? Color.blue.opacity(0.2) : Color(.systemGray6))
                    .frame(width: buttonSize, height: buttonSize)
                
                Group {
                    if UIImage(systemName: icon) != nil {
                        Image(systemName: icon)
                            .font(.title3)
                            .foregroundColor(isSelected ? .blue : .secondary)
                    } else {
                        Image(systemName: "star.fill")
                            .font(.title3)
                            .foregroundColor(isSelected ? .blue : .secondary)
                    }
                }
                .frame(width: buttonSize, height: buttonSize)
                
                if isSelected {
                    Circle()
                        .stroke(Color.blue, lineWidth: strokeWidth)
                        .frame(width: buttonSize, height: buttonSize)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .frame(height: 60) // Fixed height ensures consistent row height
        .aspectRatio(1, contentMode: .fill) // Fill cell completely, maintain square
    }
}

#Preview {
    let appState = AppState()
    return MorningRoutineView(appState: appState)
        .padding()
}

