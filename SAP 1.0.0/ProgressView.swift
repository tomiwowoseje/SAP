//
//  ProgressView.swift
//  SAP 1.0.0
//
//  Created by Tomiwo Owoseje  on 22/12/2025.
//

import SwiftUI

// B-005: Progress Tracking Screen - Redesigned to match HelloHabit style
struct ProgressTrackingView: View {
    @Bindable var appState: AppState
    @State private var selectedViewType: ViewType = .annual
    @State private var selectedYear: Int
    @State private var showingExportSheet = false
    @State private var exportText: String = ""
    @State private var showingImportSheet = false
    @State private var importText: String = ""
    @State private var importError: String?
    
    enum ViewType: String, CaseIterable {
        case weekly = "Week"
        case monthly = "Month"
        case annual = "Year"
    }
    
    init(appState: AppState) {
        self.appState = appState
        let calendar = Calendar.current
        _selectedYear = State(initialValue: calendar.component(.year, from: Date()))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom header - HelloHabit style (consistent across all views)
                customHeader
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                    .padding(.bottom, 16)
                
                // View type selector - HelloHabit style buttons (consistent across all views)
                viewTypeSelector
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                
                // Year navigation (only for Year view) - HelloHabit style
                if selectedViewType == .annual {
                    yearNavigationView
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                }
                
                // Progress content - consistent padding across all views
                ScrollView {
                    VStack(spacing: 24) {
                        // Skills progress list
                        skillsProgressList
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                    .padding(.bottom, 16)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .sheet(isPresented: $showingExportSheet) {
            NavigationStack {
                VStack(alignment: .leading) {
                    Text("Exported Data")
                        .font(.headline)
                        .padding(.bottom, 8)
                    
                    Text("Copy this JSON and save it somewhere safe. You can import it later on this or another device.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    
                    TextEditor(text: $exportText)
                        .font(.system(.footnote, design: .monospaced))
                        .padding(.top, 8)
                        .border(Color.secondary.opacity(0.2))
                }
                .padding()
                .navigationTitle("Export Data")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") {
                            showingExportSheet = false
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingImportSheet) {
            NavigationStack {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Import Data")
                        .font(.headline)
                    
                    Text("Paste previously exported JSON below, then tap Import.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    
                    TextEditor(text: $importText)
                        .font(.system(.footnote, design: .monospaced))
                        .frame(minHeight: 200)
                        .border(Color.secondary.opacity(0.2))
                    
                    if let error = importError {
                        Text(error)
                            .font(.footnote)
                            .foregroundColor(.red)
                    }
                    
                    Button {
                        do {
                            try appState.importData(from: importText)
                            showingImportSheet = false
                        } catch {
                            importError = "Failed to import data. Please check that the JSON is valid."
                        }
                    } label: {
                        Text("Import")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 8)
                }
                .padding()
                .navigationTitle("Import Data")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showingImportSheet = false
                        }
                    }
                }
            }
        }
    }
    
    // View type selector - HelloHabit style button row
    private var viewTypeSelector: some View {
        HStack(spacing: 8) {
            viewTypeButton(type: .weekly, icon: "list.bullet")
            viewTypeButton(type: .monthly, icon: "square.grid.3x3")
            viewTypeButton(type: .annual, icon: "square.grid.3x3")
        }
    }
    
    // Individual view type button - HelloHabit style
    private func viewTypeButton(type: ViewType, icon: String) -> some View {
        Button(action: {
            selectedViewType = type
        }) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                Text(type.rawValue)
                    .font(.system(size: 14, weight: .medium))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(selectedViewType == type ? Color(.systemGray2) : Color(.systemGray6))
            )
            .foregroundColor(selectedViewType == type ? .white : .primary)
        }
    }
    
    // Year navigation view - HelloHabit style
    private var yearNavigationView: some View {
        HStack(spacing: 8) {
            // Year display button
            Button(action: {}) {
                Text(String(selectedYear))
                    .font(.system(size: 14, weight: .medium))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray6))
                    )
                    .foregroundColor(.primary)
            }
            
            // Left arrow
            Button(action: {
                selectedYear -= 1
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .medium))
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray6))
                    )
                    .foregroundColor(.primary)
            }
            
            // Today button
            let calendar = Calendar.current
            let isCurrentYear = calendar.component(.year, from: Date()) == selectedYear
            Button(action: {
                selectedYear = calendar.component(.year, from: Date())
            }) {
                Text("Today")
                    .font(.system(size: 14, weight: .medium))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isCurrentYear ? Color(.systemGray2) : Color(.systemGray6))
                    )
                    .foregroundColor(isCurrentYear ? .white : .primary)
            }
            
            // Right arrow
            Button(action: {
                selectedYear += 1
            }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray6))
                    )
                    .foregroundColor(.primary)
            }
        }
    }
    
    // Custom header - HelloHabit style
    private var customHeader: some View {
        HStack {
            Button(action: {}) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                    .frame(width: 44, height: 44)
            }
            
            Spacer()
            
            Text("Habit Reports")
                .font(.system(size: 17, weight: .semibold))
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                    .frame(width: 44, height: 44)
            }
        }
    }
    
    // Skills progress list
    private var skillsProgressList: some View {
        let allProgress = appState.getAllProgress()
        
        return VStack(spacing: 24) {
            ForEach(allProgress) { progress in
                SkillProgressCard(
                    progress: progress,
                    viewType: selectedViewType,
                    selectedYear: selectedYear,
                    appState: appState
                )
            }
        }
    }
}

// Skill progress card with Git-style grid
// Uses exact skill category colors from app configuration for consistency
struct SkillProgressCard: View {
    let progress: SkillProgress
    let viewType: ProgressTrackingView.ViewType
    let selectedYear: Int
    let appState: AppState
    
    // Get skill for color and details
    private var skill: Skill? {
        appState.skills.first { $0.id == progress.skillId }
    }
    
    // Get skill color with fallback - ensures consistency across app
    // This color comes from the skill's category, which is set during task creation
    // and used consistently in: Home screen, Progress view, and all task displays
    private var skillColor: Color {
        // Use the exact category color from the skill
        // This ensures the same color appears in:
        // - Task cards on home screen
        // - Progress grid squares
        // - Checkmark icons
        // - All other skill-related UI elements
        skill?.category.color ?? .blue
    }
    
    // Calculate accurate completion percentage
    private var completionPercentage: Double {
        let dates = getDatesForViewType()
        let calendar = Calendar.current
        let now = Date()
        
        // Filter to only dates that have passed
        let pastDates = dates.filter { $0 <= now }
        guard !pastDates.isEmpty else { return 0 }
        
        // Count completions for the date range
        var completedDays = 0
        for date in pastDates {
            let completion = progress.completions.first { completion in
                calendar.isDate(completion.date, inSameDayAs: date)
            }
            if let completion = completion {
                // Count full as 1, partial as 0.5
                switch completion.completionLevel {
                case .full:
                    completedDays += 1
                case .partial:
                    completedDays += 1 // Count partial as full for percentage
                case .none:
                    break
                }
            }
        }
        
        return Double(completedDays) / Double(pastDates.count) * 100
    }
    
    // Get target/goal description
    private var targetDescription: String {
        guard let skill = skill else { return "" }
        if !skill.trackingMetrics.dailyGoal.isEmpty {
            return "\(skill.trackingMetrics.dailyGoal) per day"
        } else if !skill.trackingMetrics.weeklyGoal.isEmpty {
            return "\(skill.trackingMetrics.weeklyGoal) per week"
        } else {
            return skill.taskDescription
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Habit header - HelloHabit style: checkbox, name/goal, percentage
            // CONSISTENT layout across all view types
            HStack(alignment: .center, spacing: 12) {
                // Checkbox icon with skill color - fixed size
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(skillColor)
                    .font(.system(size: 20))
                    .frame(width: 22, height: 22)
                    .fixedSize()
                
                // Name and goal text - flexible, consistent spacing
                HStack(spacing: 4) {
                    Text(progress.skillName)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.primary)
                    
                    if !targetDescription.isEmpty {
                        Text("-")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Text(targetDescription)
                            .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.secondary)
            }
                }
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Percentage - right aligned, fixed width to prevent shifting
                Text("\(Int(completionPercentage))%")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .frame(minWidth: 45, alignment: .trailing)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            
            // Git-style progress grid - HelloHabit dense style
            // CONSISTENT grid layout across all view types
            progressGrid
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // Progress grid based on view type - HelloHabit exact style: very dense squares
    // CONSISTENT implementation across all view types
    private var progressGrid: some View {
        let dates = getDatesForViewType()
        let columns = getColumnsForViewType()
        let squareSize = getSquareSize()
        // Consistent minimal spacing for dense grid - HelloHabit style (1.5px for both rows and columns)
        let rowSpacing: CGFloat = 1.5
        
        return LazyVGrid(
            columns: columns,
            alignment: .leading,
            spacing: rowSpacing
        ) {
            ForEach(dates, id: \.self) { date in
                let color = getColorForDate(date, skillColor: skillColor)
                
                // Uniform square cells - HelloHabit style: dense, consistent sizing
                Rectangle()
                    .fill(color)
                    .frame(width: squareSize, height: squareSize)
                    .cornerRadius(1.5)
                    .fixedSize()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .animation(.none, value: viewType) // Disable animations to prevent layout shifts
    }
    
    // Get dates for the selected view type
    private func getDatesForViewType() -> [Date] {
        let calendar = Calendar.current
        let now = Date()
        var dates: [Date] = []
        
        switch viewType {
        case .weekly:
            let weekday = calendar.component(.weekday, from: now)
            let daysFromMonday = (weekday + 5) % 7
            let weekStart = calendar.date(byAdding: .day, value: -daysFromMonday, to: now) ?? now
            dates = (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
            
        case .monthly:
            let components = calendar.dateComponents([.year, .month], from: now)
            guard let monthStart = calendar.date(from: components) else {
            let startDate = calendar.date(byAdding: .day, value: -29, to: now) ?? now
                return (0..<30).compactMap { calendar.date(byAdding: .day, value: $0, to: startDate) }
            }
            
            let firstWeekday = calendar.component(.weekday, from: monthStart)
            let daysFromMonday = (firstWeekday + 5) % 7
            let calendarStart = calendar.date(byAdding: .day, value: -daysFromMonday, to: monthStart) ?? monthStart
            
            // Show 6 weeks (42 days)
            dates = (0..<42).compactMap { calendar.date(byAdding: .day, value: $0, to: calendarStart) }
            
        case .annual:
            // Show all days in the selected year - GitHub contribution graph style
            guard let yearStart = calendar.date(from: DateComponents(year: selectedYear, month: 1, day: 1)) else {
                return []
            }
            
            // Get the last day of the year (handles leap years properly)
            guard let nextYearStart = calendar.date(from: DateComponents(year: selectedYear + 1, month: 1, day: 1)),
                  let yearEnd = calendar.date(byAdding: .day, value: -1, to: nextYearStart) else {
                return []
            }
            
            // Calculate total days in year (handles leap years)
            // Use rangeIncludingEndDate to get inclusive count
            let daysInYear = calendar.dateComponents([.day], from: yearStart, to: yearEnd).day ?? 365
            
            // Generate all dates for the year
            // Note: daysInYear is the difference, so we need daysInYear + 1 total days
            dates = (0...daysInYear).compactMap { dayOffset in
                calendar.date(byAdding: .day, value: dayOffset, to: yearStart)
            }
            
            // Ensure we have exactly the right number of days
            // For a 53-column grid (52 weeks + 1), we need to pad or trim
            // GitHub style: 53 columns, each representing a week
            // We'll show all days, wrapping to next row as needed
        }
        
        return dates
    }
    
    // Get columns for grid - HelloHabit style: CONSISTENT spacing across all views
    private func getColumnsForViewType() -> [GridItem] {
        let columnSpacing: CGFloat = 1.5 // Consistent spacing across all views
        
        switch viewType {
        case .weekly:
            return Array(repeating: GridItem(.flexible(), spacing: columnSpacing), count: 7)
        case .monthly:
            return Array(repeating: GridItem(.flexible(), spacing: columnSpacing), count: 7)
        case .annual:
            // 53 columns for year view - HelloHabit style: consistent spacing
            return Array(repeating: GridItem(.flexible(), spacing: columnSpacing), count: 53)
        }
    }
    
    // Get square size based on view type - HelloHabit style: CONSISTENT sizing logic
    private func getSquareSize() -> CGFloat {
        switch viewType {
        case .weekly:
            return 10 // Slightly larger for weekly view
        case .monthly:
            return 9 // Medium size for monthly view
        case .annual:
            // HelloHabit style: very small squares for year view (like GitHub contribution graph)
            return 4.5 // Smaller for year view to fit all days
        }
    }
    
    // Get color for a specific date with Git-style color coding
    // Uses exact skill category color from app configuration
    private func getColorForDate(_ date: Date, skillColor: Color) -> Color {
        let calendar = Calendar.current
        let now = Date()
        
        // Future dates are gray/transparent
        if date > now {
            return Color.gray.opacity(0.1)
        }
        
        // Find completion for this date
        let completion = progress.completions.first { completion in
            calendar.isDate(completion.date, inSameDayAs: date)
        }
        
        let completionLevel = completion?.completionLevel ?? .none
        
        // Git-style color coding with skill-specific colors:
        // - Dark/saturated: Full completion (uses exact category color)
        // - Light (50% opacity): Partial completion (same color, lighter)
        // - Gray: No completion
        switch completionLevel {
        case .full:
            // Use exact skill category color for full completion
            return skillColor
        case .partial:
            // Use lighter version of skill color for partial completion
            return skillColor.opacity(0.5)
        case .none:
            // Gray for no completion
            return Color.gray.opacity(0.2)
        }
    }
}

// Make SkillProgress identifiable for ForEach
extension SkillProgress: Identifiable {
    var id: UUID { skillId }
}

#Preview {
    let appState = AppState()
    return ProgressTrackingView(appState: appState)
}

